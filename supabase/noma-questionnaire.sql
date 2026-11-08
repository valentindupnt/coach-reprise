
-- ---------------------------------------------------------------------
-- NOMA : questionnaire de départ (8 questions) et favoris. Additif, re-jouable.
-- ---------------------------------------------------------------------
create table if not exists public.athlete_questionnaire (
  athlete_id uuid primary key references public.athletes(id) on delete cascade,
  answers jsonb not null default '{}'::jsonb check (jsonb_typeof(answers) = 'object'),
  completed_at timestamptz,
  updated_at timestamptz not null default now()
);
alter table public.athlete_questionnaire enable row level security;

create table if not exists public.athlete_favorites (
  athlete_id uuid not null references public.athletes(id) on delete cascade,
  training_id text not null references public.trainings(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (athlete_id, training_id)
);
alter table public.athlete_favorites enable row level security;

-- Réponses : seules les clés envoyées changent ; p_complete = questionnaire terminé.
create or replace function public.athlete_save_questionnaire(p_token text, p_answers jsonb, p_complete boolean default false)
returns jsonb
language plpgsql volatile security definer
set search_path = public
as $$
declare
  a public.athletes;
  rec public.athlete_questionnaire;
begin
  a := public._athlete_by_token(p_token);
  if p_answers is null or jsonb_typeof(p_answers) <> 'object' or length(p_answers::text) > 8000 then
    raise exception 'invalid_questionnaire' using errcode = '22023';
  end if;
  insert into public.athlete_questionnaire (athlete_id, answers, completed_at, updated_at)
  values (a.id, p_answers, case when p_complete then now() end, now())
  on conflict (athlete_id) do update set
    answers = public.athlete_questionnaire.answers || excluded.answers,
    completed_at = case when p_complete then coalesce(public.athlete_questionnaire.completed_at, now())
                        else public.athlete_questionnaire.completed_at end,
    updated_at = now()
  returning * into rec;
  return jsonb_build_object('answers', rec.answers, 'completed_at', rec.completed_at);
end;
$$;

create or replace function public.athlete_get_questionnaire(p_token text)
returns jsonb
language plpgsql stable security definer
set search_path = public
as $$
declare
  a public.athletes;
  rec public.athlete_questionnaire;
begin
  a := public._athlete_by_token(p_token);
  select * into rec from public.athlete_questionnaire where athlete_id = a.id;
  if not found then
    return jsonb_build_object('answers', '{}'::jsonb, 'completed_at', null);
  end if;
  return jsonb_build_object('answers', rec.answers, 'completed_at', rec.completed_at);
end;
$$;

-- Favoris : p_on = true ajoute, false retire. Renvoie la liste des entraînements favoris.
create or replace function public.athlete_set_favorite(p_token text, p_training text, p_on boolean)
returns jsonb
language plpgsql volatile security definer
set search_path = public
as $$
declare
  a public.athletes;
begin
  a := public._athlete_by_token(p_token);
  if p_on then
    if not exists (select 1 from public.trainings t where t.id = p_training and t.approved) then
      raise exception 'not_found' using errcode = 'P0002';
    end if;
    insert into public.athlete_favorites (athlete_id, training_id) values (a.id, p_training) on conflict do nothing;
  else
    delete from public.athlete_favorites where athlete_id = a.id and training_id = p_training;
  end if;
  return coalesce((select jsonb_agg(f.training_id order by f.created_at) from public.athlete_favorites f where f.athlete_id = a.id), '[]'::jsonb);
end;
$$;

create or replace function public.athlete_get_favorites(p_token text)
returns jsonb
language plpgsql stable security definer
set search_path = public
as $$
declare
  a public.athletes;
begin
  a := public._athlete_by_token(p_token);
  return coalesce((select jsonb_agg(f.training_id order by f.created_at) from public.athlete_favorites f where f.athlete_id = a.id), '[]'::jsonb);
end;
$$;

grant execute on function public.athlete_save_questionnaire(text, jsonb, boolean) to anon, authenticated;
grant execute on function public.athlete_get_questionnaire(text) to anon, authenticated;
grant execute on function public.athlete_set_favorite(text, text, boolean) to anon, authenticated;
grant execute on function public.athlete_get_favorites(text) to anon, authenticated;
