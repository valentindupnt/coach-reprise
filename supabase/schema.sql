-- =====================================================================
-- Coach Reprise : schéma de base de données (Supabase / PostgreSQL)
-- À coller tel quel dans Supabase > SQL Editor > New query > Run.
-- Le script peut être relancé : il ne supprime aucune donnée.
-- =====================================================================

create extension if not exists pgcrypto;

-- ---------------------------------------------------------------------
-- Tables
-- ---------------------------------------------------------------------

-- Le ou les coachs (comptes Supabase Auth autorisés à tout voir)
create table if not exists public.coaches (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

-- Athlètes : uniquement le prénom (données minimales)
create table if not exists public.athletes (
  id uuid primary key default gen_random_uuid(),
  first_name text not null check (char_length(first_name) between 1 and 60),
  access_token text not null unique default encode(gen_random_bytes(24), 'hex'),
  start_date date not null default current_date,
  coach_message text check (char_length(coach_message) <= 1000),
  frozen boolean not null default false,
  frozen_at timestamptz,
  created_at timestamptz not null default now()
);

-- Catalogue d'exercices, partagé entre athlètes.
-- levels : tableau JSON de niveaux, du plus facile au plus dur.
--   [{"label": "Une jambe seule, le pied effleure le sol", "seconds": 45}, ...]
create table if not exists public.exercises (
  id text primary key check (id ~ '^[a-z0-9_]{2,40}$'),
  name text not null,
  kind text not null check (kind in ('force', 'gainage', 'mobilite', 'etirement', 'respiration')),
  illustration text,
  video_url text check (video_url is null or video_url ~ '^https://'),
  cues text[] not null default '{}',
  caution text,
  levels jsonb not null check (
    jsonb_typeof(levels) = 'array'
    and jsonb_array_length(levels) between 1 and 6
  ),
  created_at timestamptz not null default now()
);

-- Programme d'un athlète : quels exercices, dans quelle séance, à quel niveau
create table if not exists public.program_items (
  id uuid primary key default gen_random_uuid(),
  athlete_id uuid not null references public.athletes(id) on delete cascade,
  session_key text not null check (session_key in ('A', 'B', 'M')),
  exercise_id text not null references public.exercises(id),
  position int not null default 0,
  level int not null default 1 check (level >= 1),
  active boolean not null default true,
  unique (athlete_id, session_key, exercise_id)
);

-- Séances réalisées et retours de fin de séance
create table if not exists public.workouts (
  id uuid primary key default gen_random_uuid(),
  athlete_id uuid not null references public.athletes(id) on delete cascade,
  session_key text not null check (session_key in ('A', 'B', 'M', 'C')),
  client_id text unique check (client_id is null or char_length(client_id) <= 64),
  done_at timestamptz not null default now(),
  pain int not null check (pain between 0 and 10),
  neuro boolean not null,
  comment text check (comment is null or char_length(comment) <= 500),
  reviewed boolean not null default false
);
create index if not exists workouts_athlete_done_idx on public.workouts (athlete_id, done_at desc);

-- Ressenti par exercice
create table if not exists public.workout_items (
  id uuid primary key default gen_random_uuid(),
  workout_id uuid not null references public.workouts(id) on delete cascade,
  exercise_id text not null references public.exercises(id),
  level int not null,
  feeling text not null check (feeling in ('facile', 'bien', 'dur', 'douleur')),
  unique (workout_id, exercise_id)
);
create index if not exists workout_items_exercise_idx on public.workout_items (exercise_id);

-- Journal de tous les changements de niveau (automatiques ou coach)
create table if not exists public.level_changes (
  id uuid primary key default gen_random_uuid(),
  athlete_id uuid not null references public.athletes(id) on delete cascade,
  exercise_id text not null references public.exercises(id),
  from_level int not null,
  to_level int not null,
  source text not null check (source in ('auto', 'coach')),
  reason text check (reason is null or char_length(reason) <= 300),
  created_at timestamptz not null default now()
);
create index if not exists level_changes_athlete_idx on public.level_changes (athlete_id, created_at desc);

-- ---------------------------------------------------------------------
-- Sécurité : seul un coach connecté lit et écrit les tables.
-- L'athlète passe uniquement par les deux fonctions athlete_* ci-dessous,
-- qui exigent son lien secret.
-- ---------------------------------------------------------------------

create or replace function public.is_coach()
returns boolean
language sql stable security definer
set search_path = public
as $$
  select exists (select 1 from public.coaches where user_id = auth.uid());
$$;

alter table public.coaches enable row level security;
alter table public.athletes enable row level security;
alter table public.exercises enable row level security;
alter table public.program_items enable row level security;
alter table public.workouts enable row level security;
alter table public.workout_items enable row level security;
alter table public.level_changes enable row level security;

drop policy if exists coach_self on public.coaches;
create policy coach_self on public.coaches for select to authenticated
  using (user_id = auth.uid());

drop policy if exists coach_all on public.athletes;
create policy coach_all on public.athletes for all to authenticated
  using (public.is_coach()) with check (public.is_coach());

drop policy if exists coach_all on public.exercises;
create policy coach_all on public.exercises for all to authenticated
  using (public.is_coach()) with check (public.is_coach());

drop policy if exists coach_all on public.program_items;
create policy coach_all on public.program_items for all to authenticated
  using (public.is_coach()) with check (public.is_coach());

drop policy if exists coach_all on public.workouts;
create policy coach_all on public.workouts for all to authenticated
  using (public.is_coach()) with check (public.is_coach());

drop policy if exists coach_all on public.workout_items;
create policy coach_all on public.workout_items for all to authenticated
  using (public.is_coach()) with check (public.is_coach());

drop policy if exists coach_all on public.level_changes;
create policy coach_all on public.level_changes for all to authenticated
  using (public.is_coach()) with check (public.is_coach());

-- ---------------------------------------------------------------------
-- Fonctions côté athlète (lien secret)
-- ---------------------------------------------------------------------

create or replace function public._athlete_by_token(p_token text)
returns public.athletes
language plpgsql stable security definer
set search_path = public
as $$
declare
  a public.athletes;
begin
  if p_token is null or char_length(p_token) < 32 or char_length(p_token) > 128 then
    raise exception 'invalid_token' using errcode = '28000';
  end if;
  select * into a from public.athletes where access_token = p_token;
  if not found then
    raise exception 'invalid_token' using errcode = '28000';
  end if;
  return a;
end;
$$;

-- Tout ce dont l'app d'Alice a besoin, en un appel
create or replace function public.athlete_get(p_token text)
returns jsonb
language plpgsql stable security definer
set search_path = public
as $$
declare
  a public.athletes;
begin
  a := public._athlete_by_token(p_token);

  return jsonb_build_object(
    'athlete', jsonb_build_object(
      'first_name', a.first_name,
      'start_date', a.start_date,
      'coach_message', a.coach_message,
      'frozen', a.frozen
    ),
    'program', coalesce((
      select jsonb_agg(jsonb_build_object(
        'session_key', pi.session_key,
        'position', pi.position,
        'level', pi.level,
        'exercise', jsonb_build_object(
          'id', e.id,
          'name', e.name,
          'kind', e.kind,
          'illustration', e.illustration,
          'video_url', e.video_url,
          'cues', to_jsonb(e.cues),
          'caution', e.caution,
          'levels', e.levels
        )
      ) order by pi.session_key, pi.position)
      from public.program_items pi
      join public.exercises e on e.id = pi.exercise_id
      where pi.athlete_id = a.id and pi.active
    ), '[]'::jsonb),
    'workouts', coalesce((
      select jsonb_agg(jsonb_build_object(
        'session_key', w.session_key,
        'done_at', w.done_at,
        'pain', w.pain
      ) order by w.done_at desc)
      from (
        select * from public.workouts
        where athlete_id = a.id
        order by done_at desc
        limit 100
      ) w
    ), '[]'::jsonb),
    'recent_changes', coalesce((
      select jsonb_agg(jsonb_build_object(
        'exercise_id', lc.exercise_id,
        'from_level', lc.from_level,
        'to_level', lc.to_level,
        'source', lc.source,
        'created_at', lc.created_at
      ) order by lc.created_at desc)
      from (
        select * from public.level_changes
        where athlete_id = a.id and created_at > now() - interval '14 days'
        order by created_at desc
        limit 20
      ) lc
    ), '[]'::jsonb)
  );
end;
$$;

-- Enregistre une séance et applique les règles de sécurité :
--  * « douleur » sur un exercice  -> cet exercice descend d'un niveau (auto)
--  * fourmillements / faiblesse    -> programme gelé jusqu'à déblocage coach
-- La montée de niveau n'est JAMAIS automatique : voir coach_proposals().
create or replace function public.athlete_submit_workout(
  p_token text,
  p_client_id text,
  p_session text,
  p_pain int,
  p_neuro boolean,
  p_items jsonb,
  p_comment text default null
)
returns jsonb
language plpgsql volatile security definer
set search_path = public
as $$
declare
  a public.athletes;
  w_id uuid;
  it jsonb;
  item public.program_items;
  v_feeling text;
  regressed jsonb := '[]'::jsonb;
  today_count int;
begin
  a := public._athlete_by_token(p_token);

  if p_session is null or p_session not in ('A', 'B', 'M', 'C') then
    raise exception 'invalid_session' using errcode = '22023';
  end if;
  if p_pain is null or p_pain < 0 or p_pain > 10 then
    raise exception 'invalid_pain' using errcode = '22023';
  end if;
  if p_neuro is null then
    raise exception 'invalid_neuro' using errcode = '22023';
  end if;
  if p_items is null then
    p_items := '[]'::jsonb;
  end if;
  if jsonb_typeof(p_items) <> 'array' or jsonb_array_length(p_items) > 40 then
    raise exception 'invalid_items' using errcode = '22023';
  end if;
  if p_client_id is not null and char_length(p_client_id) > 64 then
    raise exception 'invalid_client_id' using errcode = '22023';
  end if;
  if p_comment is not null and char_length(p_comment) > 500 then
    p_comment := left(p_comment, 500);
  end if;

  -- Idempotence : un renvoi après coupure réseau ne crée pas de doublon
  if p_client_id is not null and exists (
    select 1 from public.workouts where client_id = p_client_id and athlete_id = a.id
  ) then
    return jsonb_build_object('status', 'duplicate', 'frozen', a.frozen, 'regressed', '[]'::jsonb);
  end if;

  -- Garde-fou anti-abus
  select count(*) into today_count
  from public.workouts
  where athlete_id = a.id and done_at > now() - interval '24 hours';
  if today_count >= 12 then
    raise exception 'too_many_workouts' using errcode = '54000';
  end if;

  insert into public.workouts (athlete_id, session_key, client_id, pain, neuro, comment)
  values (a.id, p_session, p_client_id, p_pain, p_neuro, nullif(trim(p_comment), ''))
  returning id into w_id;

  for it in select value from jsonb_array_elements(p_items) loop
    if jsonb_typeof(it) <> 'object' then
      raise exception 'invalid_items' using errcode = '22023';
    end if;
    v_feeling := it ->> 'feeling';
    if v_feeling is null or v_feeling not in ('facile', 'bien', 'dur', 'douleur') then
      raise exception 'invalid_feeling' using errcode = '22023';
    end if;

    select * into item
    from public.program_items
    where athlete_id = a.id and exercise_id = (it ->> 'exercise_id') and active
    order by position
    limit 1
    for update;
    if not found then
      continue; -- exercice retiré du programme entre-temps : ignoré
    end if;

    -- un seul ressenti par exercice et par séance
    if exists (select 1 from public.workout_items where workout_id = w_id and exercise_id = item.exercise_id) then
      continue;
    end if;

    insert into public.workout_items (workout_id, exercise_id, level, feeling)
    values (w_id, item.exercise_id, item.level, v_feeling);

    if v_feeling = 'douleur' and item.level > 1 then
      update public.program_items
      set level = item.level - 1
      where athlete_id = a.id and exercise_id = item.exercise_id;

      insert into public.level_changes (athlete_id, exercise_id, from_level, to_level, source, reason)
      values (a.id, item.exercise_id, item.level, item.level - 1, 'auto', 'Douleur signalée sur l''exercice');

      regressed := regressed || jsonb_build_array(
        jsonb_build_object('exercise_id', item.exercise_id, 'to_level', item.level - 1)
      );
    end if;
  end loop;

  if p_neuro then
    update public.athletes set frozen = true, frozen_at = now() where id = a.id;
  end if;

  return jsonb_build_object(
    'status', 'ok',
    'frozen', (p_neuro or a.frozen),
    'regressed', regressed
  );
end;
$$;

-- ---------------------------------------------------------------------
-- Fonctions côté coach
-- ---------------------------------------------------------------------

-- Propositions de montée de niveau : les 2 derniers ressentis sur l'exercice
-- sont « facile », au niveau actuel, avec douleur <= 3 et sans symptôme,
-- et aucun changement de niveau sur cet exercice depuis 7 jours.
create or replace function public.coach_proposals()
returns table (
  athlete_id uuid,
  first_name text,
  exercise_id text,
  exercise_name text,
  session_key text,
  level int,
  max_level int
)
language sql stable security definer
set search_path = public
as $$
  select pi.athlete_id, a.first_name, e.id, e.name, pi.session_key, pi.level,
         jsonb_array_length(e.levels)
  from public.program_items pi
  join public.athletes a on a.id = pi.athlete_id
  join public.exercises e on e.id = pi.exercise_id
  where public.is_coach()
    and pi.active
    and not a.frozen
    and pi.level < jsonb_array_length(e.levels)
    and not exists (
      select 1 from public.level_changes lc
      where lc.athlete_id = pi.athlete_id
        and lc.exercise_id = pi.exercise_id
        and lc.created_at > now() - interval '7 days'
    )
    and (
      select count(*) from (
        select wi.feeling, wi.level, w.pain, w.neuro
        from public.workout_items wi
        join public.workouts w on w.id = wi.workout_id
        where w.athlete_id = pi.athlete_id and wi.exercise_id = pi.exercise_id
        order by w.done_at desc
        limit 2
      ) last2
      where last2.feeling = 'facile'
        and last2.level = pi.level
        and last2.pain <= 3
        and not last2.neuro
    ) = 2
  order by a.first_name, pi.session_key, pi.position;
$$;

create or replace function public.coach_set_level(
  p_athlete uuid,
  p_exercise text,
  p_level int,
  p_reason text default null
)
returns void
language plpgsql volatile security definer
set search_path = public
as $$
declare
  cur int;
  maxl int;
begin
  if not public.is_coach() then
    raise exception 'forbidden' using errcode = '42501';
  end if;

  select pi.level, jsonb_array_length(e.levels) into cur, maxl
  from public.program_items pi
  join public.exercises e on e.id = pi.exercise_id
  where pi.athlete_id = p_athlete and pi.exercise_id = p_exercise
  limit 1;

  if not found then
    raise exception 'not_found' using errcode = 'P0002';
  end if;
  if p_level is null or p_level < 1 or p_level > maxl then
    raise exception 'invalid_level' using errcode = '22023';
  end if;
  if p_level = cur then
    return;
  end if;

  update public.program_items
  set level = p_level
  where athlete_id = p_athlete and exercise_id = p_exercise;

  insert into public.level_changes (athlete_id, exercise_id, from_level, to_level, source, reason)
  values (p_athlete, p_exercise, cur, p_level, 'coach', nullif(trim(left(p_reason, 300)), ''));
end;
$$;

-- Nouveau lien secret (l'ancien cesse immédiatement de fonctionner)
create or replace function public.coach_rotate_token(p_athlete uuid)
returns text
language plpgsql volatile security definer
set search_path = public
as $$
declare
  t text;
begin
  if not public.is_coach() then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  t := encode(gen_random_bytes(24), 'hex');
  update public.athletes set access_token = t where id = p_athlete;
  if not found then
    raise exception 'not_found' using errcode = 'P0002';
  end if;
  return t;
end;
$$;

-- ---------------------------------------------------------------------
-- Droits
-- ---------------------------------------------------------------------

revoke all on all tables in schema public from anon;
revoke execute on all functions in schema public from public, anon;

grant select, insert, update, delete on all tables in schema public to authenticated;

grant execute on function public.athlete_get(text) to anon, authenticated;
grant execute on function public.athlete_submit_workout(text, text, text, int, boolean, jsonb, text) to anon, authenticated;

grant execute on function public.is_coach() to authenticated;
grant execute on function public.coach_proposals() to authenticated;
grant execute on function public.coach_set_level(uuid, text, int, text) to authenticated;
grant execute on function public.coach_rotate_token(uuid) to authenticated;
