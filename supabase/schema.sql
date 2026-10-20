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
-- V2 : le coach peut interdire à l'athlète de remplacer des exercices
alter table public.athletes add column if not exists allow_swaps boolean not null default true;

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

-- V2 : la bibliothèque. Chaque exercice est décrit pour pouvoir proposer des remplacements.
--   zones     : zones travaillées (dos, epaules, abdos, obliques, lombaires, fessiers, cuisses,
--               ischios, mollets, hanches, thorax, bras, pectoraux, cou, respiration)
--   equipment : matériel (aucun, elastique, mini-band, chaise, mur, serviette, coussin)
--   intensity : 1 très léger à 5 soutenu, pour comparer des exercices entre eux
--   family    : famille de variantes (même intention, autre façon de faire)
--   pattern   : schéma de mouvement (tirage, anti-rotation, squat, pont, mobilite...)
--   max_sets  : nombre maximal de tours conseillé pour cet exercice (1 à 4)
--   approved  : validé par le coach, donc proposable à l'athlète
alter table public.exercises add column if not exists zones text[] not null default '{}';
alter table public.exercises add column if not exists equipment text[] not null default '{}';
alter table public.exercises add column if not exists intensity int not null default 2 check (intensity between 1 and 5);
alter table public.exercises add column if not exists family text;
alter table public.exercises add column if not exists pattern text;
alter table public.exercises add column if not exists max_sets int not null default 3 check (max_sets between 1 and 4);
alter table public.exercises add column if not exists approved boolean not null default false;
alter table public.exercises add column if not exists source text;

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
-- V2 : bloc de la séance (échauffement, circuit, retour au calme) et nombre de tours propre à l'exercice
alter table public.program_items add column if not exists block text not null default 'main'
  check (block in ('warmup', 'main', 'cooldown'));
alter table public.program_items add column if not exists sets int check (sets is null or sets between 1 and 4);

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
-- V2 : effort ressenti sur la séance (0 à 10) et durée réelle en minutes
alter table public.workouts add column if not exists rpe int check (rpe is null or rpe between 0 and 10);
alter table public.workouts add column if not exists duration_min int check (duration_min is null or duration_min between 0 and 240);
create index if not exists workouts_athlete_done_idx on public.workouts (athlete_id, done_at desc);

-- Ressenti par exercice
create table if not exists public.workout_items (
  id uuid primary key default gen_random_uuid(),
  workout_id uuid not null references public.workouts(id) on delete cascade,
  exercise_id text not null references public.exercises(id),
  level int not null,
  feeling text check (feeling in ('facile', 'bien', 'dur', 'douleur')),
  unique (workout_id, exercise_id)
);
-- V2 : un exercice fait mais non noté n'a pas de ressenti (plus de « bien » par défaut)
alter table public.workout_items alter column feeling drop not null;
-- V2 : « j'aime » ou « à changer » par exercice
alter table public.workout_items add column if not exists preference text check (preference is null or preference in ('aime', 'a_changer'));
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

-- V2 : journal des changements de programme (remplacement, ajout, retrait, nombre de tours)
create table if not exists public.program_changes (
  id uuid primary key default gen_random_uuid(),
  athlete_id uuid not null references public.athletes(id) on delete cascade,
  session_key text not null check (session_key in ('A', 'B', 'M')),
  kind text not null check (kind in ('swap', 'add', 'remove', 'sets')),
  from_exercise text,
  to_exercise text,
  source text not null check (source in ('athlete', 'coach')),
  reason text check (reason is null or char_length(reason) <= 300),
  created_at timestamptz not null default now()
);
create index if not exists program_changes_athlete_idx on public.program_changes (athlete_id, created_at desc);

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
alter table public.program_changes enable row level security;

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

drop policy if exists coach_all on public.program_changes;
create policy coach_all on public.program_changes for all to authenticated
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

-- ---------------------------------------------------------------------
-- V2 : fonctions communes (fiche d'un exercice, remplacements)
-- ---------------------------------------------------------------------

-- Fiche d'un exercice telle que l'app la reçoit
create or replace function public._exercise_json(e public.exercises)
returns jsonb
language sql immutable
set search_path = public
as $$
  select jsonb_build_object(
    'id', e.id,
    'name', e.name,
    'kind', e.kind,
    'illustration', e.illustration,
    'video_url', e.video_url,
    'cues', to_jsonb(e.cues),
    'caution', e.caution,
    'levels', e.levels,
    'zones', to_jsonb(e.zones),
    'equipment', to_jsonb(e.equipment),
    'intensity', e.intensity,
    'family', e.family,
    'pattern', e.pattern,
    'max_sets', e.max_sets
  );
$$;

-- Exercices qui peuvent en remplacer un autre dans une séance :
-- validés par le coach, du même type, d'intensité voisine (± 1), pas déjà dans la séance,
-- et pas signalés douloureux par l'athlète ces 14 derniers jours.
create or replace function public._swap_candidates(p_athlete uuid, p_session text, p_exercise text)
returns table (id text, gap int, is_variant boolean, other_zone boolean)
language sql stable security definer
set search_path = public
as $$
  select e.id,
         abs(e.intensity - o.intensity) as gap,
         (o.family is not null and e.family = o.family) as is_variant,
         not (e.zones && o.zones) as other_zone
  from public.exercises o
  join public.exercises e on e.id <> o.id
  where o.id = p_exercise
    and e.approved
    and e.kind = o.kind
    and abs(e.intensity - o.intensity) <= 1
    and not exists (
      select 1 from public.program_items pi
      where pi.athlete_id = p_athlete and pi.session_key = p_session
        and pi.exercise_id = e.id and pi.active
    )
    and not exists (
      select 1
      from public.workout_items wi
      join public.workouts w on w.id = wi.workout_id
      where w.athlete_id = p_athlete and wi.exercise_id = e.id
        and wi.feeling = 'douleur' and w.done_at > now() - interval '14 days'
    );
$$;

-- Les propositions : d'abord la meilleure variante (même famille), puis la meilleure
-- alternative qui travaille d'autres zones, puis les plus proches en intensité.
create or replace function public._swap_options(p_athlete uuid, p_session text, p_exercise text, p_limit int)
returns jsonb
language plpgsql stable security definer
set search_path = public
as $$
declare
  picked text[] := '{}';
  v text;
  result jsonb := '[]'::jsonb;
  lim int := greatest(1, least(coalesce(p_limit, 2), 4));
begin
  select c.id into v from public._swap_candidates(p_athlete, p_session, p_exercise) c
   where c.is_variant order by c.gap, c.id limit 1;
  if v is not null then
    picked := picked || v;
    result := result || jsonb_build_array(jsonb_build_object('why', 'variante',
      'exercise', (select public._exercise_json(e) from public.exercises e where e.id = v)));
  end if;

  if jsonb_array_length(result) < lim then
    select c.id into v from public._swap_candidates(p_athlete, p_session, p_exercise) c
     where c.other_zone and not (c.id = any(picked)) order by c.gap, c.id limit 1;
    if v is not null then
      picked := picked || v;
      result := result || jsonb_build_array(jsonb_build_object('why', 'autre_zone',
        'exercise', (select public._exercise_json(e) from public.exercises e where e.id = v)));
    end if;
  end if;

  for v in
    select c.id from public._swap_candidates(p_athlete, p_session, p_exercise) c
     where not (c.id = any(picked)) order by c.gap, c.id
  loop
    exit when jsonb_array_length(result) >= lim;
    result := result || jsonb_build_array(jsonb_build_object('why', 'proche',
      'exercise', (select public._exercise_json(e) from public.exercises e where e.id = v)));
  end loop;

  return result;
end;
$$;

-- Remplace un exercice dans une séance (le nouveau repart au niveau déjà atteint ailleurs, sinon 1)
create or replace function public._apply_swap(
  p_athlete uuid, p_session text, p_from text, p_to text, p_reason text, p_source text
)
returns void
language plpgsql volatile security definer
set search_path = public
as $$
declare
  a public.athletes;
  item public.program_items;
  ex_to public.exercises;
  ex_from public.exercises;
  lvl int;
begin
  select * into a from public.athletes where id = p_athlete;
  if not found then
    raise exception 'not_found' using errcode = 'P0002';
  end if;
  if p_session is null or p_session not in ('A', 'B', 'M') then
    raise exception 'invalid_session' using errcode = '22023';
  end if;
  if p_source = 'athlete' and not a.allow_swaps then
    raise exception 'swaps_locked' using errcode = '42501';
  end if;
  if p_from = p_to then
    raise exception 'invalid_swap' using errcode = '22023';
  end if;

  select * into item from public.program_items
   where athlete_id = p_athlete and session_key = p_session and exercise_id = p_from and active
   for update;
  if not found then
    raise exception 'not_found' using errcode = 'P0002';
  end if;
  select * into ex_from from public.exercises where id = p_from;
  select * into ex_to from public.exercises where id = p_to;
  if not found then
    raise exception 'not_found' using errcode = 'P0002';
  end if;
  if p_source = 'athlete' and (not ex_to.approved or ex_to.kind <> ex_from.kind) then
    raise exception 'invalid_swap' using errcode = '22023';
  end if;
  if exists (select 1 from public.program_items
              where athlete_id = p_athlete and session_key = p_session and exercise_id = p_to and active) then
    raise exception 'already_in_session' using errcode = '23505';
  end if;
  -- une ligne désactivée pour ce même exercice gênerait la contrainte d'unicité
  delete from public.program_items
   where athlete_id = p_athlete and session_key = p_session and exercise_id = p_to and not active;

  select coalesce(max(level), 1) into lvl from public.program_items
   where athlete_id = p_athlete and exercise_id = p_to and active;
  lvl := least(lvl, jsonb_array_length(ex_to.levels));

  update public.program_items
     set exercise_id = p_to, level = lvl, sets = null
   where id = item.id;

  insert into public.program_changes (athlete_id, session_key, kind, from_exercise, to_exercise, source, reason)
  values (p_athlete, p_session, 'swap', p_from, p_to, p_source, nullif(left(p_reason, 300), ''));
end;
$$;

-- Propositions de remplacement pour l'athlète (2 en séance, jusqu'à 4 au bilan)
create or replace function public.athlete_swap_options(
  p_token text, p_session text, p_exercise text, p_limit int default 2
)
returns jsonb
language plpgsql stable security definer
set search_path = public
as $$
declare
  a public.athletes;
begin
  a := public._athlete_by_token(p_token);
  if p_session is null or p_session not in ('A', 'B', 'M') then
    raise exception 'invalid_session' using errcode = '22023';
  end if;
  if not a.allow_swaps then
    return '[]'::jsonb;
  end if;
  return public._swap_options(a.id, p_session, p_exercise, p_limit);
end;
$$;

-- Bibliothèque consultable par l'athlète : uniquement les exercices validés par le coach
create or replace function public.athlete_library(p_token text)
returns jsonb
language plpgsql stable security definer
set search_path = public
as $$
declare
  a public.athletes;
begin
  a := public._athlete_by_token(p_token);
  return jsonb_build_object(
    'exercises', coalesce((
      select jsonb_agg(public._exercise_json(e) order by e.kind, e.name)
      from public.exercises e where e.approved
    ), '[]'::jsonb),
    'in_program', coalesce((
      select jsonb_agg(distinct pi.exercise_id)
      from public.program_items pi where pi.athlete_id = a.id and pi.active
    ), '[]'::jsonb)
  );
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
      'frozen', a.frozen,
      'allow_swaps', a.allow_swaps
    ),
    'program', coalesce((
      select jsonb_agg(jsonb_build_object(
        'session_key', pi.session_key,
        'block', pi.block,
        'position', pi.position,
        'level', pi.level,
        'sets', pi.sets,
        'exercise', public._exercise_json(e)
      ) order by pi.session_key,
                 case pi.block when 'warmup' then 0 when 'main' then 1 else 2 end,
                 pi.position)
      from public.program_items pi
      join public.exercises e on e.id = pi.exercise_id
      where pi.athlete_id = a.id and pi.active
    ), '[]'::jsonb),
    'workouts', coalesce((
      select jsonb_agg(jsonb_build_object(
        'session_key', w.session_key,
        'done_at', w.done_at,
        'pain', w.pain,
        'rpe', w.rpe,
        'duration_min', w.duration_min
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
-- V2 : date et durée réelles, effort ressenti (RPE), préférence par exercice
-- (« aime » / « à changer ») et remplacements demandés au bilan (p_swaps).
drop function if exists public.athlete_submit_workout(text, text, text, int, boolean, jsonb, text);
create or replace function public.athlete_submit_workout(
  p_token text,
  p_client_id text,
  p_session text,
  p_pain int,
  p_neuro boolean,
  p_items jsonb,
  p_comment text default null,
  p_done_at timestamptz default null,
  p_rpe int default null,
  p_duration_min int default null,
  p_swaps jsonb default '[]'::jsonb
)
returns jsonb
language plpgsql volatile security definer
set search_path = public
as $$
declare
  a public.athletes;
  w_id uuid;
  it jsonb;
  sw jsonb;
  item public.program_items;
  ex public.exercises;
  v_feeling text;
  v_pref text;
  v_done timestamptz;
  v_lvl int;
  regressed jsonb := '[]'::jsonb;
  swapped jsonb := '[]'::jsonb;
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
  if p_rpe is not null and (p_rpe < 0 or p_rpe > 10) then
    raise exception 'invalid_rpe' using errcode = '22023';
  end if;
  if p_items is null then
    p_items := '[]'::jsonb;
  end if;
  if jsonb_typeof(p_items) <> 'array' or jsonb_array_length(p_items) > 40 then
    raise exception 'invalid_items' using errcode = '22023';
  end if;
  if p_swaps is null then
    p_swaps := '[]'::jsonb;
  end if;
  if jsonb_typeof(p_swaps) <> 'array' or jsonb_array_length(p_swaps) > 10 then
    raise exception 'invalid_swaps' using errcode = '22023';
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
    return jsonb_build_object('status', 'duplicate', 'frozen', a.frozen,
                              'regressed', '[]'::jsonb, 'swapped', '[]'::jsonb);
  end if;

  -- Garde-fou anti-abus
  select count(*) into today_count
  from public.workouts
  where athlete_id = a.id and done_at > now() - interval '24 hours';
  if today_count >= 12 then
    raise exception 'too_many_workouts' using errcode = '54000';
  end if;

  -- Date réelle de la séance (utile hors ligne) : jamais dans le futur, pas plus de 14 jours dans le passé
  v_done := case
    when p_done_at is null then now()
    when p_done_at > now() + interval '5 minutes' then now()
    when p_done_at < now() - interval '14 days' then now()
    else p_done_at
  end;

  insert into public.workouts (athlete_id, session_key, client_id, done_at, pain, neuro, comment, rpe, duration_min)
  values (a.id, p_session, p_client_id, v_done, p_pain, p_neuro, nullif(trim(p_comment), ''),
          p_rpe, case when p_duration_min is null then null else greatest(0, least(p_duration_min, 240)) end)
  returning id into w_id;

  for it in select value from jsonb_array_elements(p_items) loop
    if jsonb_typeof(it) <> 'object' then
      raise exception 'invalid_items' using errcode = '22023';
    end if;
    v_feeling := it ->> 'feeling';
    if v_feeling is not null and v_feeling not in ('facile', 'bien', 'dur', 'douleur') then
      raise exception 'invalid_feeling' using errcode = '22023';
    end if;
    v_pref := it ->> 'preference';
    if v_pref is not null and v_pref not in ('aime', 'a_changer') then
      raise exception 'invalid_preference' using errcode = '22023';
    end if;

    select * into item
    from public.program_items
    where athlete_id = a.id and exercise_id = (it ->> 'exercise_id') and active
    order by position
    limit 1
    for update;
    if not found then
      -- exercice choisi en séance parmi les remplacements validés : on garde le ressenti,
      -- sans effet sur le programme
      select * into ex from public.exercises where id = (it ->> 'exercise_id') and approved;
      if found and not exists (select 1 from public.workout_items
                                where workout_id = w_id and exercise_id = ex.id) then
        select coalesce(max(level), 1) into v_lvl from public.program_items
         where athlete_id = a.id and exercise_id = ex.id and active;
        insert into public.workout_items (workout_id, exercise_id, level, feeling, preference)
        values (w_id, ex.id, least(v_lvl, jsonb_array_length(ex.levels)), v_feeling, v_pref);
      end if;
      continue; -- sinon : exercice retiré du programme entre-temps, ignoré
    end if;

    -- un seul ressenti par exercice et par séance
    if exists (select 1 from public.workout_items where workout_id = w_id and exercise_id = item.exercise_id) then
      continue;
    end if;

    insert into public.workout_items (workout_id, exercise_id, level, feeling, preference)
    values (w_id, item.exercise_id, item.level, v_feeling, v_pref);

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

  -- Remplacements demandés au bilan : un échec (exercice retiré, déjà remplacé...) n'annule pas la séance
  if not (p_neuro or a.frozen) then
    for sw in select value from jsonb_array_elements(p_swaps) loop
      begin
        perform public._apply_swap(a.id, sw ->> 'session', sw ->> 'from', sw ->> 'to',
                                   'Demandé par l''athlète au bilan de séance', 'athlete');
        swapped := swapped || jsonb_build_array(jsonb_build_object(
          'session', sw ->> 'session', 'from', sw ->> 'from', 'to', sw ->> 'to'));
      exception when others then
        null;
      end;
    end loop;
  end if;

  return jsonb_build_object(
    'status', 'ok',
    'frozen', (p_neuro or a.frozen),
    'regressed', regressed,
    'swapped', swapped
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
-- V2 : éditeur de programme et bibliothèque (coach)
-- ---------------------------------------------------------------------

create or replace function public.coach_swap_exercise(
  p_athlete uuid, p_session text, p_from text, p_to text, p_reason text default null
)
returns void
language plpgsql volatile security definer
set search_path = public
as $$
begin
  if not public.is_coach() then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  perform public._apply_swap(p_athlete, p_session, p_from, p_to, p_reason, 'coach');
end;
$$;

create or replace function public.coach_add_exercise(
  p_athlete uuid, p_session text, p_exercise text, p_block text default 'main'
)
returns void
language plpgsql volatile security definer
set search_path = public
as $$
declare
  ex public.exercises;
  existing public.program_items;
  lvl int;
  pos int;
begin
  if not public.is_coach() then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  if p_session is null or p_session not in ('A', 'B', 'M') then
    raise exception 'invalid_session' using errcode = '22023';
  end if;
  if p_block is null or p_block not in ('warmup', 'main', 'cooldown') then
    raise exception 'invalid_block' using errcode = '22023';
  end if;
  select * into ex from public.exercises where id = p_exercise;
  if not found then
    raise exception 'not_found' using errcode = 'P0002';
  end if;
  if not exists (select 1 from public.athletes where id = p_athlete) then
    raise exception 'not_found' using errcode = 'P0002';
  end if;

  select coalesce(max(level), 1) into lvl from public.program_items
   where athlete_id = p_athlete and exercise_id = p_exercise and active;
  lvl := least(lvl, jsonb_array_length(ex.levels));
  select coalesce(max(position), 0) + 1 into pos from public.program_items
   where athlete_id = p_athlete and session_key = p_session and block = p_block and active;

  select * into existing from public.program_items
   where athlete_id = p_athlete and session_key = p_session and exercise_id = p_exercise;
  if found then
    if existing.active then
      raise exception 'already_in_session' using errcode = '23505';
    end if;
    update public.program_items
       set active = true, block = p_block, position = pos, level = lvl, sets = null
     where id = existing.id;
  else
    insert into public.program_items (athlete_id, session_key, exercise_id, block, position, level)
    values (p_athlete, p_session, p_exercise, p_block, pos, lvl);
  end if;

  insert into public.program_changes (athlete_id, session_key, kind, to_exercise, source)
  values (p_athlete, p_session, 'add', p_exercise, 'coach');
end;
$$;

create or replace function public.coach_remove_exercise(p_athlete uuid, p_session text, p_exercise text)
returns void
language plpgsql volatile security definer
set search_path = public
as $$
begin
  if not public.is_coach() then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  update public.program_items set active = false
   where athlete_id = p_athlete and session_key = p_session and exercise_id = p_exercise and active;
  if not found then
    raise exception 'not_found' using errcode = 'P0002';
  end if;
  insert into public.program_changes (athlete_id, session_key, kind, from_exercise, source)
  values (p_athlete, p_session, 'remove', p_exercise, 'coach');
end;
$$;

-- Nombre de tours propre à un exercice (1 à 4, dans la limite conseillée pour cet exercice) ; null = selon la phase
create or replace function public.coach_set_sets(
  p_athlete uuid, p_session text, p_exercise text, p_sets int
)
returns void
language plpgsql volatile security definer
set search_path = public
as $$
declare
  item public.program_items;
  maxs int;
begin
  if not public.is_coach() then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  select pi.* into item from public.program_items pi
   where pi.athlete_id = p_athlete and pi.session_key = p_session and pi.exercise_id = p_exercise and pi.active;
  if not found then
    raise exception 'not_found' using errcode = 'P0002';
  end if;
  select max_sets into maxs from public.exercises where id = p_exercise;
  if p_sets is not null and (p_sets < 1 or p_sets > maxs) then
    raise exception 'invalid_sets' using errcode = '22023';
  end if;
  if item.sets is not distinct from p_sets then
    return;
  end if;
  update public.program_items set sets = p_sets where id = item.id;
  insert into public.program_changes (athlete_id, session_key, kind, from_exercise, to_exercise, source, reason)
  values (p_athlete, p_session, 'sets', p_exercise, p_exercise, 'coach',
          'Tours : ' || coalesce(item.sets::text, 'selon la phase') || ' → ' || coalesce(p_sets::text, 'selon la phase'));
end;
$$;

-- Monte (-1) ou descend (+1) un exercice à l'intérieur de son bloc
create or replace function public.coach_move_exercise(
  p_athlete uuid, p_session text, p_exercise text, p_dir int
)
returns void
language plpgsql volatile security definer
set search_path = public
as $$
declare
  item public.program_items;
  mine int;
  other uuid;
begin
  if not public.is_coach() then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  if p_dir is null or p_dir not in (-1, 1) then
    raise exception 'invalid_direction' using errcode = '22023';
  end if;
  select * into item from public.program_items
   where athlete_id = p_athlete and session_key = p_session and exercise_id = p_exercise and active;
  if not found then
    raise exception 'not_found' using errcode = 'P0002';
  end if;

  with ordered as (
    select id, row_number() over (order by position, id) as rn
    from public.program_items
    where athlete_id = p_athlete and session_key = p_session and block = item.block and active
  )
  update public.program_items pi set position = o.rn from ordered o where pi.id = o.id;

  select position into mine from public.program_items where id = item.id;
  select id into other from public.program_items
   where athlete_id = p_athlete and session_key = p_session and block = item.block and active
     and position = mine + p_dir;
  if other is null then
    return;
  end if;
  update public.program_items set position = mine where id = other;
  update public.program_items set position = mine + p_dir where id = item.id;
end;
$$;

-- Crée ou modifie un exercice du catalogue (le coach ne touche pas au SQL)
create or replace function public.coach_save_exercise(p_ex jsonb)
returns text
language plpgsql volatile security definer
set search_path = public
as $$
declare
  v_id text := p_ex ->> 'id';
begin
  if not public.is_coach() then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  if v_id is null or v_id !~ '^[a-z0-9_]{2,40}$' then
    raise exception 'invalid_id' using errcode = '22023';
  end if;
  if coalesce(trim(p_ex ->> 'name'), '') = '' then
    raise exception 'invalid_name' using errcode = '22023';
  end if;

  insert into public.exercises (id, name, kind, illustration, video_url, cues, caution, levels,
                                zones, equipment, intensity, family, pattern, max_sets, approved, source)
  values (
    v_id,
    trim(p_ex ->> 'name'),
    p_ex ->> 'kind',
    nullif(trim(p_ex ->> 'illustration'), ''),
    nullif(trim(p_ex ->> 'video_url'), ''),
    coalesce(array(select jsonb_array_elements_text(coalesce(p_ex -> 'cues', '[]'::jsonb))), '{}'),
    nullif(trim(p_ex ->> 'caution'), ''),
    p_ex -> 'levels',
    coalesce(array(select jsonb_array_elements_text(coalesce(p_ex -> 'zones', '[]'::jsonb))), '{}'),
    coalesce(array(select jsonb_array_elements_text(coalesce(p_ex -> 'equipment', '[]'::jsonb))), '{}'),
    coalesce((p_ex ->> 'intensity')::int, 2),
    nullif(trim(p_ex ->> 'family'), ''),
    nullif(trim(p_ex ->> 'pattern'), ''),
    coalesce((p_ex ->> 'max_sets')::int, 3),
    coalesce((p_ex ->> 'approved')::boolean, false),
    nullif(trim(p_ex ->> 'source'), '')
  )
  on conflict (id) do update set
    name = excluded.name,
    kind = excluded.kind,
    illustration = excluded.illustration,
    video_url = excluded.video_url,
    cues = excluded.cues,
    caution = excluded.caution,
    levels = excluded.levels,
    zones = excluded.zones,
    equipment = excluded.equipment,
    intensity = excluded.intensity,
    family = excluded.family,
    pattern = excluded.pattern,
    max_sets = excluded.max_sets,
    approved = excluded.approved,
    source = excluded.source;
  return v_id;
end;
$$;

-- ---------------------------------------------------------------------
-- Droits
-- ---------------------------------------------------------------------

revoke all on all tables in schema public from anon;
revoke execute on all functions in schema public from public, anon;

grant select, insert, update, delete on all tables in schema public to authenticated;

grant execute on function public.athlete_get(text) to anon, authenticated;
grant execute on function public.athlete_submit_workout(text, text, text, int, boolean, jsonb, text, timestamptz, int, int, jsonb) to anon, authenticated;
grant execute on function public.athlete_swap_options(text, text, text, int) to anon, authenticated;
grant execute on function public.athlete_library(text) to anon, authenticated;

grant execute on function public.is_coach() to authenticated;
grant execute on function public.coach_proposals() to authenticated;
grant execute on function public.coach_set_level(uuid, text, int, text) to authenticated;
grant execute on function public.coach_rotate_token(uuid) to authenticated;
grant execute on function public.coach_swap_exercise(uuid, text, text, text, text) to authenticated;
grant execute on function public.coach_add_exercise(uuid, text, text, text) to authenticated;
grant execute on function public.coach_remove_exercise(uuid, text, text) to authenticated;
grant execute on function public.coach_set_sets(uuid, text, text, int) to authenticated;
grant execute on function public.coach_move_exercise(uuid, text, text, int) to authenticated;
grant execute on function public.coach_save_exercise(jsonb) to authenticated;
