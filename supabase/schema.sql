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
-- V3 : semaine type personnalisée (7 jours, lundi en premier ; A, B, M, C, R = repos, AB = A ou B selon la semaine)
-- null = semaine par défaut de l'application
alter table public.athletes add column if not exists week_plan jsonb
  check (week_plan is null or (jsonb_typeof(week_plan) = 'array' and jsonb_array_length(week_plan) = 7));
-- V3 : qui valide la montée de niveau. 'coach' (par défaut) = proposition à valider par le coach ;
-- 'self' = l'athlète monte seule, avec les mêmes garde-fous que les propositions (voir athlete_submit_workout)
alter table public.athletes add column if not exists levelup_mode text not null default 'coach'
  check (levelup_mode in ('coach', 'self'));
-- Par défaut l'athlète choisit librement son niveau (même en séance) ; le coach peut repasser en 'coach'.
alter table public.athletes alter column levelup_mode set default 'self';

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
-- V3 : 'self' = montée de niveau validée automatiquement (réglage « l'athlète monte seule »)
do $$
begin
  alter table public.level_changes drop constraint if exists level_changes_source_check;
  alter table public.level_changes add constraint level_changes_source_check check (source in ('auto', 'coach', 'self'));
end $$;

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

-- =====================================================================
-- V5, bloc 1 : socle de données de l'app fitness (voir docs/CADRAGE-V5.md)
-- Tout est additif : aucune colonne ni table existante n'est supprimée.
-- =====================================================================

-- Fuseau de l'utilisateur, pour débloquer un jour de programme par jour calendaire
alter table public.athletes add column if not exists timezone text not null default 'Europe/Paris';

-- 1.1 Étiquettes des exercices
--   muscles_primary / muscles_secondary : muscles affichés sur la silhouette (couleur vive / atténuée)
--   areas      : zones du questionnaire et du démarrage rapide
--   goals      : objectifs servis par l'exercice
--   discipline : famille d'entraînement (sert aux filtres, aux préférences et aux remplacements)
--   impact     : true = avec sauts (exclus au départ si IMC >= 30)
--   mode       : 'time' (secondes) ou 'reps' (répétitions) ; default_value = valeur par défaut dans ce mode
--   met / met_code : valeur MET et code d'activité du Compendium 2024 (calcul des calories)
--   tutorial   : {"steps": [...], "breathing": "...", "mistakes": [...]}
alter table public.exercises add column if not exists muscles_primary text[] not null default '{}';
alter table public.exercises add column if not exists muscles_secondary text[] not null default '{}';
alter table public.exercises add column if not exists areas text[] not null default '{}';
alter table public.exercises add column if not exists goals text[] not null default '{}';
alter table public.exercises add column if not exists discipline text;
alter table public.exercises add column if not exists impact boolean not null default false;
alter table public.exercises add column if not exists mode text not null default 'time';
alter table public.exercises add column if not exists default_value int;
alter table public.exercises add column if not exists met numeric(4,1);
alter table public.exercises add column if not exists met_code text;
alter table public.exercises add column if not exists tutorial jsonb;
do $$
begin
  -- 'cardio' rejoint les types historiques (jumping jacks, montées de genoux...)
  alter table public.exercises drop constraint if exists exercises_kind_check;
  alter table public.exercises add constraint exercises_kind_check
    check (kind in ('force', 'gainage', 'mobilite', 'etirement', 'respiration', 'cardio'));
  alter table public.exercises drop constraint if exists exercises_areas_check;
  alter table public.exercises add constraint exercises_areas_check
    check (areas <@ array['bras', 'epaules', 'abdos', 'fessiers', 'jambes', 'dos', 'corps_entier']);
  alter table public.exercises drop constraint if exists exercises_goals_check;
  alter table public.exercises add constraint exercises_goals_check
    check (goals <@ array['renforcer', 'tonifier', 'mobilite', 'cardio', 'detente']);
  alter table public.exercises drop constraint if exists exercises_discipline_check;
  alter table public.exercises add constraint exercises_discipline_check
    check (discipline is null or discipline in ('renforcement', 'gainage', 'calisthenie', 'cardio', 'hiit',
                                                'yoga', 'etirement', 'pilates', 'meditation'));
  alter table public.exercises drop constraint if exists exercises_mode_check;
  alter table public.exercises add constraint exercises_mode_check check (mode in ('time', 'reps'));
  alter table public.exercises drop constraint if exists exercises_default_value_check;
  alter table public.exercises add constraint exercises_default_value_check
    check (default_value is null or default_value between 1 and 600);
  alter table public.exercises drop constraint if exists exercises_met_check;
  alter table public.exercises add constraint exercises_met_check check (met is null or met between 0.9 and 20);
  alter table public.exercises drop constraint if exists exercises_met_code_check;
  alter table public.exercises add constraint exercises_met_code_check check (met_code is null or met_code ~ '^[0-9]{5}$');
  alter table public.exercises drop constraint if exists exercises_tutorial_check;
  alter table public.exercises add constraint exercises_tutorial_check
    check (tutorial is null or jsonb_typeof(tutorial) = 'object');
end $$;

-- 1.2 Entraînements : une suite d'exercices en trois phases.
--   kind   : 'programme' (jour d'un programme), 'rapide' (démarrage rapide par zone),
--            'decouverte' (moments pour soi), 'express' (3 à 5 min sans matériel, gardé hors ligne)
--   level  : 1 débutant, 2 intermédiaire, 3 avancé
--   rounds : tours du corps de séance ; rest_seconds : pause entre deux exercices
create table if not exists public.trainings (
  id text primary key check (id ~ '^[a-z0-9_]{2,60}$'),
  title text not null check (char_length(title) between 1 and 80),
  description text check (description is null or char_length(description) <= 500),
  kind text not null check (kind in ('programme', 'rapide', 'decouverte', 'express')),
  level int not null default 1 check (level between 1 and 3),
  areas text[] not null default '{}'
    check (areas <@ array['bras', 'epaules', 'abdos', 'fessiers', 'jambes', 'dos', 'corps_entier']),
  discipline text,
  rounds int not null default 2 check (rounds between 1 and 6),
  rest_seconds int not null default 15 check (rest_seconds between 0 and 180),
  approved boolean not null default false,
  source text,
  created_at timestamptz not null default now()
);

-- value : durée (s) ou répétitions imposées pour cet exercice ; null = valeur du niveau ou de l'exercice
-- sets  : tours propres à l'exercice dans le corps de séance ; null = rounds de l'entraînement
create table if not exists public.training_items (
  id uuid primary key default gen_random_uuid(),
  training_id text not null references public.trainings(id) on delete cascade,
  phase text not null check (phase in ('warmup', 'main', 'cooldown')),
  position int not null check (position >= 1),
  exercise_id text not null references public.exercises(id),
  level int not null default 1 check (level >= 1),
  value int check (value is null or value between 1 and 600),
  sets int check (sets is null or sets between 1 and 6),
  unique (training_id, phase, position)
);
create index if not exists training_items_exercise_idx on public.training_items (exercise_id);

-- 1.3 Programmes : un entraînement par jour, débloqué jour après jour
create table if not exists public.programs (
  id text primary key check (id ~ '^[a-z0-9_]{2,60}$'),
  title text not null check (char_length(title) between 1 and 80),
  description text check (description is null or char_length(description) <= 500),
  goals text[] not null default '{}'
    check (goals <@ array['perdre_du_poids', 'renforcer', 'tonifier', 'garder_la_forme']),
  areas text[] not null default '{}'
    check (areas <@ array['bras', 'epaules', 'abdos', 'fessiers', 'jambes', 'dos', 'corps_entier']),
  level int not null default 1 check (level between 1 and 3),
  approved boolean not null default false,
  source text,
  created_at timestamptz not null default now()
);

create table if not exists public.program_days (
  program_id text not null references public.programs(id) on delete cascade,
  day int not null check (day between 1 and 120),
  training_id text not null references public.trainings(id),
  primary key (program_id, day)
);

-- Programme suivi par un utilisateur. Un seul programme actif à la fois.
--   unlocked_through : jour débloqué à la main depuis l'espace admin (0 = aucun)
create table if not exists public.athlete_programs (
  id uuid primary key default gen_random_uuid(),
  athlete_id uuid not null references public.athletes(id) on delete cascade,
  program_id text not null references public.programs(id),
  started_on date not null default current_date,
  status text not null default 'actif' check (status in ('actif', 'termine', 'abandonne')),
  unlocked_through int not null default 0 check (unlocked_through between 0 and 120),
  ended_at timestamptz,
  created_at timestamptz not null default now()
);
create unique index if not exists athlete_programs_one_active on public.athlete_programs (athlete_id) where status = 'actif';

-- Une séance peut désormais être un entraînement V5 (session_key 'T'), rattaché ou non à un jour de programme
do $$
begin
  alter table public.workouts drop constraint if exists workouts_session_key_check;
  alter table public.workouts add constraint workouts_session_key_check check (session_key in ('A', 'B', 'M', 'C', 'T'));
end $$;
alter table public.workouts add column if not exists training_id text references public.trainings(id);
alter table public.workouts add column if not exists athlete_program_id uuid references public.athlete_programs(id) on delete set null;
alter table public.workouts add column if not exists program_day int check (program_day is null or program_day between 1 and 120);
create unique index if not exists workouts_program_day_once
  on public.workouts (athlete_program_id, program_day) where athlete_program_id is not null and program_day is not null;

-- 1.4 Profil sportif : réponses du questionnaire et données corporelles. Tout est facultatif et modifiable.
create table if not exists public.athlete_profiles (
  athlete_id uuid primary key references public.athletes(id) on delete cascade,
  sex text check (sex in ('femme', 'homme')),
  goal text check (goal in ('perdre_du_poids', 'renforcer', 'tonifier', 'garder_la_forme')),
  areas text[] not null default '{}'
    check (areas <@ array['bras', 'epaules', 'abdos', 'fessiers', 'jambes', 'dos', 'corps_entier']),
  motivation text check (motivation in ('confiance', 'vitalite', 'douleurs', 'sommeil', 'bien_etre')),
  morphology text check (morphology in ('mince', 'moyenne', 'enveloppee', 'musclee')),
  height_cm int check (height_cm between 120 and 230),
  weight_kg numeric(5,1) check (weight_kg between 30 and 250),
  birth_year int check (birth_year between 1920 and 2016),
  target_weight_kg numeric(5,1) check (target_weight_kg between 30 and 250),
  last_fit text check (last_fit in ('en_ce_moment', 'moins_1_an', '1_3_ans', 'plus_3_ans', 'jamais')),
  level text check (level in ('debutant', 'intermediaire', 'avance')),
  activity text check (activity in ('sedentaire', 'peu_actif', 'actif', 'tres_actif')),
  sessions_per_week int check (sessions_per_week between 2 and 7),
  session_minutes int check (session_minutes in (10, 15, 20, 30)),
  equipment text[] not null default '{}'
    check (equipment <@ array['aucun', 'tapis', 'elastique', 'halteres', 'chaise', 'mur']),
  style text check (style in ('facile', 'transpiration_legere', 'intense')),
  disciplines text[] not null default '{}'
    check (disciplines <@ array['renforcement', 'etirement', 'pilates', 'yoga', 'hiit', 'calisthenie', 'danse', 'marche', 'meditation']),
  -- questionnaire d'adhésion : {"choisir": bool, "ennui": bool, "demotive": bool}
  adherence jsonb not null default '{}'::jsonb check (jsonb_typeof(adherence) = 'object'),
  reward text check (reward in ('vetements', 'cadeau', 'voyage', 'partager', 'autre')),
  feeling text check (feeling in ('heureux', 'en_forme', 'confiant', 'fier', 'energie', 'rassure')),
  completed_at timestamptz,
  updated_at timestamptz not null default now()
);

-- 1.4 bis Tampon « Ça fait mal » : l'exercice n'est plus proposé à cet utilisateur jusqu'à « until » (10 jours)
create table if not exists public.exercise_blocks (
  athlete_id uuid not null references public.athletes(id) on delete cascade,
  exercise_id text not null references public.exercises(id) on delete cascade,
  blocked_at timestamptz not null default now(),
  until timestamptz not null,
  primary key (athlete_id, exercise_id)
);

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

-- V5 : mêmes règles pour les nouvelles tables (l'utilisateur passe uniquement par les fonctions athlete_*)
do $$
declare
  t text;
begin
  foreach t in array array['trainings', 'training_items', 'programs', 'program_days',
                           'athlete_programs', 'athlete_profiles', 'exercise_blocks'] loop
    execute format('alter table public.%I enable row level security', t);
    execute format('drop policy if exists coach_all on public.%I', t);
    execute format('create policy coach_all on public.%I for all to authenticated
                      using (public.is_coach()) with check (public.is_coach())', t);
  end loop;
end $$;

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
    'max_sets', e.max_sets,
    -- V5 : étiquettes
    'muscles_primary', to_jsonb(e.muscles_primary),
    'muscles_secondary', to_jsonb(e.muscles_secondary),
    'areas', to_jsonb(e.areas),
    'goals', to_jsonb(e.goals),
    'discipline', e.discipline,
    'impact', e.impact,
    'mode', e.mode,
    'default_value', e.default_value,
    'met', e.met,
    'met_code', e.met_code,
    'tutorial', e.tutorial,
    'source', e.source
  );
$$;

-- V5 : tampon « Ça fait mal » actif sur cet exercice pour cet utilisateur
create or replace function public._is_blocked(p_athlete uuid, p_exercise text)
returns boolean
language sql stable security definer
set search_path = public
as $$
  select exists (
    select 1 from public.exercise_blocks b
    where b.athlete_id = p_athlete and b.exercise_id = p_exercise and b.until > now()
  );
$$;

-- Exercices qui peuvent en remplacer un autre dans une séance :
-- validés par le coach, du même type, d'intensité voisine (± 1), pas déjà dans la séance,
-- et sans tampon « Ça fait mal » en cours (V5 : 10 jours, remplace l'ancienne règle des 14 jours).
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
      select 1 from public.exercise_blocks b
      where b.athlete_id = p_athlete and b.exercise_id = e.id and b.until > now()
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
    ), '[]'::jsonb),
    -- V5 : tampons « Ça fait mal » en cours, avec leur date de fin (affichés sur la fiche de l'exercice)
    'blocks', public._blocks_json(a.id)
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
      'allow_swaps', a.allow_swaps,
      'week_plan', a.week_plan,
      'levelup_mode', a.levelup_mode,
      'workout_count', (select count(*) from public.workouts where athlete_id = a.id),
      'timezone', a.timezone
    ),
    -- V5 : profil sportif, programme suivi jour par jour, tampons « Ça fait mal » en cours
    'profile', public._profile_json(a.id),
    'plan', public._plan_json(a.id),
    'blocks', public._blocks_json(a.id),
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

-- Enregistre une séance et applique la règle de sécurité :
--  * V5 : « douleur » sur un exercice (bouton « Ça fait mal » ou bilan) : tampon de 10 jours sur l'exercice
--    pour cet utilisateur. Plus de baisse de niveau automatique, plus de gel du programme
--    (p_neuro est encore accepté pour les anciennes versions de l'app, sans effet sur le programme).
-- V2 : date et durée réelles, effort ressenti (RPE), préférence par exercice
-- (« aime » / « à changer ») et remplacements demandés au bilan (p_swaps).
drop function if exists public.athlete_submit_workout(text, text, text, int, boolean, jsonb, text);
drop function if exists public.athlete_submit_workout(text, text, text, int, boolean, jsonb, text, timestamptz, int, int, jsonb);
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
  p_swaps jsonb default '[]'::jsonb,
  p_levels jsonb default '[]'::jsonb
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
  leveled jsonb := '[]'::jsonb;
  blocked jsonb := '[]'::jsonb;
  v_until timestamptz;
  cand record;
  lv jsonb;
  cur_level int;
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
  if p_levels is null then
    p_levels := '[]'::jsonb;
  end if;
  if jsonb_typeof(p_levels) <> 'array' or jsonb_array_length(p_levels) > 40 then
    raise exception 'invalid_levels' using errcode = '22023';
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
                              'regressed', '[]'::jsonb, 'swapped', '[]'::jsonb,
                              'leveled_up', '[]'::jsonb, 'blocked', '[]'::jsonb);
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

  -- Niveaux choisis par l'athlète pendant la séance (plus dur / plus facile) : appliqués avant le ressenti,
  -- pour que celui-ci soit enregistré au niveau réellement fait. Sans effet si le coach garde la main.
  if a.levelup_mode = 'self' and not a.frozen then
    for lv in select value from jsonb_array_elements(p_levels) loop
      begin
        perform public._apply_level(a.id, lv ->> 'exercise_id', (lv ->> 'level')::int,
                                    'Niveau choisi par l''athlète pendant la séance');
      exception when others then
        null; -- exercice retiré entre-temps, niveau hors limites... : n'annule pas la séance
      end;
    end loop;
  end if;

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
        if v_feeling = 'douleur' then
          v_until := public._block_exercise(a.id, ex.id, v_done);
          blocked := blocked || jsonb_build_array(jsonb_build_object('exercise_id', ex.id, 'until', v_until));
        end if;
      end if;
      continue; -- sinon : exercice retiré du programme entre-temps, ignoré
    end if;

    -- un seul ressenti par exercice et par séance
    if exists (select 1 from public.workout_items where workout_id = w_id and exercise_id = item.exercise_id) then
      continue;
    end if;

    insert into public.workout_items (workout_id, exercise_id, level, feeling, preference)
    values (w_id, item.exercise_id, item.level, v_feeling, v_pref);

    -- V5 : tampon de 10 jours, sans toucher au niveau
    if v_feeling = 'douleur' then
      v_until := public._block_exercise(a.id, item.exercise_id, v_done);
      blocked := blocked || jsonb_build_array(jsonb_build_object('exercise_id', item.exercise_id, 'until', v_until));
    end if;
  end loop;

  -- V3 : montée de niveau autonome, uniquement si le coach a choisi « l'athlète monte seule ».
  -- Garde-fous : mêmes conditions que les propositions faites au coach (2 derniers ressentis « facile »
  -- au niveau actuel, douleur <= 3, aucun symptôme, pas de changement depuis 7 jours), plus :
  -- séance à douleur <= 3 sans symptôme, aucune douleur sur l'exercice depuis 14 jours,
  -- et au plus 2 exercices qui montent par séance.
  if a.levelup_mode = 'self' and not p_neuro and not a.frozen and p_pain <= 3 then
    for cand in
      select pi.exercise_id
      from public.program_items pi
      join public.exercises e on e.id = pi.exercise_id
      join public.workout_items cur on cur.workout_id = w_id and cur.exercise_id = pi.exercise_id
      where pi.athlete_id = a.id
        and pi.active
        and cur.feeling = 'facile'
        and cur.level = pi.level
        and pi.level < jsonb_array_length(e.levels)
        and not exists (
          select 1 from public.level_changes lc
          where lc.athlete_id = pi.athlete_id and lc.exercise_id = pi.exercise_id
            and lc.created_at > now() - interval '7 days'
        )
        and not exists (
          select 1 from public.workout_items wi
          join public.workouts w2 on w2.id = wi.workout_id
          where w2.athlete_id = pi.athlete_id and wi.exercise_id = pi.exercise_id
            and wi.feeling = 'douleur' and w2.done_at > now() - interval '14 days'
        )
        and (
          select count(*) from (
            select wi.feeling, wi.level, w3.pain, w3.neuro
            from public.workout_items wi
            join public.workouts w3 on w3.id = wi.workout_id
            where w3.athlete_id = pi.athlete_id and wi.exercise_id = pi.exercise_id
            order by w3.done_at desc
            limit 2
          ) last2
          where last2.feeling = 'facile' and last2.level = pi.level and last2.pain <= 3 and not last2.neuro
        ) = 2
      group by pi.exercise_id
      order by min(pi.session_key), min(pi.position)
      limit 2
    loop
      select level into cur_level from public.program_items
       where athlete_id = a.id and exercise_id = cand.exercise_id and active
       order by position limit 1;
      update public.program_items set level = level + 1
       where athlete_id = a.id and exercise_id = cand.exercise_id;
      insert into public.level_changes (athlete_id, exercise_id, from_level, to_level, source, reason)
      values (a.id, cand.exercise_id, cur_level, cur_level + 1, 'self',
              'Montée validée par l''athlète : 2 séances « trop facile », sans douleur ni symptôme');
      leveled := leveled || jsonb_build_array(
        jsonb_build_object('exercise_id', cand.exercise_id, 'to_level', cur_level + 1));
    end loop;
  end if;

  -- Remplacements demandés au bilan : un échec (exercice retiré, déjà remplacé...) n'annule pas la séance
  if not a.frozen then
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
    'frozen', a.frozen,
    'regressed', regressed,
    'swapped', swapped,
    'leveled_up', leveled,
    'blocked', blocked
  );
end;
$$;

-- V3 : changement de niveau choisi par l'athlète (dans les deux sens, sans condition).
-- Interne : journalise « self » et applique à toutes les lignes de l'exercice.
create or replace function public._apply_level(p_athlete uuid, p_exercise text, p_level int, p_reason text)
returns void
language plpgsql volatile
set search_path = public
as $$
declare
  cur int;
  maxl int;
begin
  select pi.level, jsonb_array_length(e.levels) into cur, maxl
  from public.program_items pi
  join public.exercises e on e.id = pi.exercise_id
  where pi.athlete_id = p_athlete and pi.exercise_id = p_exercise and pi.active
  order by pi.position
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
  update public.program_items set level = p_level where athlete_id = p_athlete and exercise_id = p_exercise;
  insert into public.level_changes (athlete_id, exercise_id, from_level, to_level, source, reason)
  values (p_athlete, p_exercise, cur, p_level, 'self', p_reason);
end;
$$;

create or replace function public.athlete_set_level(p_token text, p_exercise text, p_level int)
returns void
language plpgsql volatile security definer
set search_path = public
as $$
declare
  a public.athletes;
begin
  a := public._athlete_by_token(p_token);
  if a.frozen then
    raise exception 'program_frozen' using errcode = '42501';
  end if;
  if a.levelup_mode <> 'self' then
    raise exception 'level_by_coach' using errcode = '42501';
  end if;
  perform public._apply_level(a.id, p_exercise, p_level, 'Niveau choisi par l''athlète');
end;
$$;

-- V3 : l'athlète organise sa semaine type. Valeurs : A, B, M, C, R (repos), AB (A ou B selon la semaine).
-- Garde-fou : au plus 4 jours de renforcement (A, B ou AB) par semaine ; le coach peut aller au-delà.
-- p_plan null = retour à la semaine par défaut.
create or replace function public._valid_week_plan(p_plan jsonb, p_max_strength int)
returns void
language plpgsql immutable
as $$
declare
  v jsonb;
  strength int := 0;
begin
  if p_plan is null or p_plan = 'null'::jsonb then
    return;
  end if;
  if jsonb_typeof(p_plan) <> 'array' or jsonb_array_length(p_plan) <> 7 then
    raise exception 'invalid_week_plan' using errcode = '22023';
  end if;
  for v in select value from jsonb_array_elements(p_plan) loop
    if jsonb_typeof(v) <> 'string' or (v #>> '{}') not in ('A', 'B', 'M', 'C', 'R', 'AB') then
      raise exception 'invalid_week_plan' using errcode = '22023';
    end if;
    if (v #>> '{}') in ('A', 'B', 'AB') then
      strength := strength + 1;
    end if;
  end loop;
  if p_max_strength is not null and strength > p_max_strength then
    raise exception 'too_many_strength_days' using errcode = '22023';
  end if;
end;
$$;

create or replace function public.athlete_set_week_plan(p_token text, p_plan jsonb)
returns void
language plpgsql volatile security definer
set search_path = public
as $$
declare
  a public.athletes;
begin
  a := public._athlete_by_token(p_token);
  perform public._valid_week_plan(p_plan, 4);
  update public.athletes set week_plan = nullif(p_plan, 'null'::jsonb) where id = a.id;
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
  -- V5 : un exercice créé sans étiquettes reçoit celles déduites de son type et de ses zones
  perform public._v5_backfill_exercise_tags();
  return v_id;
end;
$$;

-- V3 : semaine type et mode de montée de niveau, côté coach
create or replace function public.coach_set_week_plan(p_athlete uuid, p_plan jsonb)
returns void
language plpgsql volatile security definer
set search_path = public
as $$
begin
  if not public.is_coach() then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  perform public._valid_week_plan(p_plan, null);
  update public.athletes set week_plan = nullif(p_plan, 'null'::jsonb) where id = p_athlete;
end;
$$;

create or replace function public.coach_set_levelup_mode(p_athlete uuid, p_mode text)
returns void
language plpgsql volatile security definer
set search_path = public
as $$
begin
  if not public.is_coach() then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  if p_mode is null or p_mode not in ('coach', 'self') then
    raise exception 'invalid_mode' using errcode = '22023';
  end if;
  update public.athletes set levelup_mode = p_mode where id = p_athlete;
end;
$$;

-- =====================================================================
-- V5, bloc 1 : fonctions (voir docs/CADRAGE-V5.md et docs/MODELE-V5.md)
-- =====================================================================

-- Décision du 26/10/2026 : plus de gel du programme. Les utilisateurs gelés auparavant sont libérés.
update public.athletes set frozen = false, frozen_at = null where frozen;

-- 1.1 Étiquettes déduites des descriptions V2 pour les exercices pas encore étiquetés.
-- MET (Compendium 2024) : renfo poids du corps 02056 = 3,0 ; gainage léger 02024 = 2,8 ;
-- étirements doux 02101 = 2,3 ; méditation 07075 = 1,0 ; effort intense 02020 = 7,5.
-- Relançable : ne touche qu'aux exercices sans discipline.
create or replace function public._v5_backfill_exercise_tags()
returns void
language sql volatile
set search_path = public
as $$
  update public.exercises e set
    discipline = case e.kind
      when 'force' then 'renforcement' when 'gainage' then 'gainage' when 'mobilite' then 'etirement'
      when 'etirement' then 'etirement' when 'respiration' then 'meditation' when 'cardio' then 'cardio' end,
    goals = case when e.goals <> '{}' then e.goals else case e.kind
      when 'force' then array['renforcer', 'tonifier'] when 'gainage' then array['renforcer', 'tonifier']
      when 'mobilite' then array['mobilite'] when 'etirement' then array['mobilite', 'detente']
      when 'respiration' then array['detente'] when 'cardio' then array['cardio'] end end,
    areas = case when e.areas <> '{}' then e.areas else coalesce((
      select array_agg(distinct m.a order by m.a)
      from unnest(e.zones) z
      cross join lateral (select case z
        when 'dos' then 'dos' when 'lombaires' then 'dos' when 'thorax' then 'dos' when 'cou' then 'dos'
        when 'epaules' then 'epaules' when 'bras' then 'bras' when 'pectoraux' then 'bras'
        when 'abdos' then 'abdos' when 'obliques' then 'abdos'
        when 'fessiers' then 'fessiers' when 'hanches' then 'fessiers'
        when 'cuisses' then 'jambes' when 'ischios' then 'jambes' when 'mollets' then 'jambes' end as a) m
      where m.a is not null
    ), array['corps_entier']) end,
    muscles_primary = case when e.muscles_primary <> '{}' then e.muscles_primary else e.zones end,
    met = coalesce(e.met, case e.kind when 'force' then 3.0 when 'gainage' then 2.8 when 'mobilite' then 2.3
      when 'etirement' then 2.3 when 'respiration' then 1.0 when 'cardio' then 7.5 end),
    met_code = coalesce(e.met_code, case e.kind when 'force' then '02056' when 'gainage' then '02024'
      when 'mobilite' then '02101' when 'etirement' then '02101' when 'respiration' then '07075'
      when 'cardio' then '02020' end)
  where e.discipline is null;
$$;
select public._v5_backfill_exercise_tags();

-- ---------------------------------------------------------------------
-- 1.4 bis Tampon « Ça fait mal »
-- ---------------------------------------------------------------------

-- Pose (ou prolonge) un tampon de 10 jours à partir du moment de la douleur
create or replace function public._block_exercise(p_athlete uuid, p_exercise text, p_from timestamptz default now())
returns timestamptz
language plpgsql volatile security definer
set search_path = public
as $$
declare
  v_until timestamptz;
begin
  insert into public.exercise_blocks (athlete_id, exercise_id, blocked_at, until)
  values (p_athlete, p_exercise, coalesce(p_from, now()), coalesce(p_from, now()) + interval '10 days')
  on conflict (athlete_id, exercise_id) do update
    set blocked_at = greatest(public.exercise_blocks.blocked_at, excluded.blocked_at),
        until = greatest(public.exercise_blocks.until, excluded.until)
  returning until into v_until;
  return v_until;
end;
$$;

create or replace function public._blocks_json(p_athlete uuid)
returns jsonb
language sql stable security definer
set search_path = public
as $$
  select coalesce(jsonb_agg(jsonb_build_object('exercise_id', b.exercise_id, 'until', b.until)
                            order by b.until), '[]'::jsonb)
  from public.exercise_blocks b
  where b.athlete_id = p_athlete and b.until > now();
$$;

-- Bouton « Ça fait mal » en séance (en ligne) : tampon immédiat. Hors ligne, le bilan le pose à l'envoi.
create or replace function public.athlete_flag_pain(p_token text, p_exercise text)
returns jsonb
language plpgsql volatile security definer
set search_path = public
as $$
declare
  a public.athletes;
  v_until timestamptz;
begin
  a := public._athlete_by_token(p_token);
  if not exists (select 1 from public.exercises where id = p_exercise) then
    raise exception 'not_found' using errcode = 'P0002';
  end if;
  v_until := public._block_exercise(a.id, p_exercise, now());
  return jsonb_build_object('exercise_id', p_exercise, 'until', v_until);
end;
$$;

-- Remplaçant d'un exercice tamponné dans un entraînement : validé, même type, intensité ± 1,
-- sans tampon, pas déjà dans l'entraînement, matériel disponible (si le profil le précise).
-- Préférence : même famille, puis mêmes zones, puis intensité la plus proche.
create or replace function public._substitute_exercise(p_athlete uuid, p_exercise text, p_exclude text[])
returns text
language sql stable security definer
set search_path = public
as $$
  select e.id
  from public.exercises o
  join public.exercises e on e.id <> o.id
  left join public.athlete_profiles p on p.athlete_id = p_athlete
  where o.id = p_exercise
    and e.approved
    and e.kind = o.kind
    and abs(e.intensity - o.intensity) <= 1
    and not (e.id = any(coalesce(p_exclude, '{}')))
    and not public._is_blocked(p_athlete, e.id)
    and (p.equipment is null or p.equipment = '{}' or e.equipment <@ (p.equipment || array['aucun']))
  order by (o.family is not null and e.family = o.family) desc,
           (e.areas && o.areas) desc,
           abs(e.intensity - o.intensity),
           e.id
  limit 1;
$$;

-- ---------------------------------------------------------------------
-- 1.2 Entraînements
-- ---------------------------------------------------------------------

-- Durée d'une exécution d'un exercice, en secondes.
-- Temps : valeur imposée, sinon secondes du niveau, sinon valeur par défaut, sinon 45 s (comme le lecteur).
-- Répétitions : 3 s par répétition (tempo moyen retenu pour estimer la durée).
create or replace function public._item_seconds(e public.exercises, p_level int, p_value int)
returns int
language sql immutable
set search_path = public
as $$
  select case when e.mode = 'reps' then
    3 * coalesce(p_value,
                 (e.levels -> (least(greatest(coalesce(p_level, 1), 1), jsonb_array_length(e.levels)) - 1) ->> 'reps')::int,
                 e.default_value, 12)
  else
    coalesce(p_value,
             (e.levels -> (least(greatest(coalesce(p_level, 1), 1), jsonb_array_length(e.levels)) - 1) ->> 'seconds')::int,
             e.default_value, 45)
  end;
$$;

-- Durée totale, MET-minutes (pour les calories : kcal = met_minutes x poids / 60), matériel et impact.
-- Échauffement et retour au calme : 1 passage ; corps de séance : sets de l'exercice, sinon rounds.
-- Pauses comptées à 1 MET.
create or replace function public._training_stats(p_training text)
returns jsonb
language plpgsql stable security definer
set search_path = public
as $$
declare
  t public.trainings;
  r record;
  n int;
  sec int;
  active int := 0;
  execs int := 0;
  met_sec numeric := 0;
  rest int;
begin
  select * into t from public.trainings where id = p_training;
  if not found then
    return null;
  end if;
  for r in
    select ti.phase, ti.sets, ti.level, ti.value, e as ex
    from public.training_items ti
    join public.exercises e on e.id = ti.exercise_id
    where ti.training_id = p_training
  loop
    n := case when r.phase = 'main' then coalesce(r.sets, t.rounds) else 1 end;
    sec := public._item_seconds(r.ex, r.level, r.value);
    active := active + n * sec;
    execs := execs + n;
    met_sec := met_sec + n * sec * coalesce((r.ex).met, 3.0);
  end loop;
  rest := greatest(execs - 1, 0) * t.rest_seconds;
  return jsonb_build_object(
    'duration_min', ceil((active + rest) / 60.0)::int,
    'active_seconds', active,
    'rest_seconds_total', rest,
    'met_minutes', round(met_sec / 60.0 + rest / 60.0, 1),
    'exercise_count', (select count(distinct ti.exercise_id) from public.training_items ti where ti.training_id = p_training),
    'equipment', coalesce((
      select jsonb_agg(distinct q order by q)
      from public.training_items ti
      join public.exercises e on e.id = ti.exercise_id
      cross join unnest(e.equipment) q
      where ti.training_id = p_training and q <> 'aucun'
    ), '[]'::jsonb),
    'impact', coalesce((
      select bool_or(e.impact) from public.training_items ti
      join public.exercises e on e.id = ti.exercise_id where ti.training_id = p_training
    ), false)
  );
end;
$$;

create or replace function public._training_summary(p_training text)
returns jsonb
language sql stable security definer
set search_path = public
as $$
  select jsonb_build_object(
    'id', t.id, 'title', t.title, 'description', t.description, 'kind', t.kind, 'level', t.level,
    'areas', to_jsonb(t.areas), 'discipline', t.discipline, 'rounds', t.rounds, 'rest_seconds', t.rest_seconds
  ) || coalesce(public._training_stats(t.id), '{}'::jsonb)
  from public.trainings t where t.id = p_training;
$$;

-- Entraînement complet. Avec un utilisateur : chaque exercice tamponné est remplacé à l'ouverture
-- (replaced_from = exercice d'origine) ; sans remplaçant possible, il est retiré de la séance.
create or replace function public._training_json(p_training text, p_athlete uuid default null)
returns jsonb
language plpgsql stable security definer
set search_path = public
as $$
declare
  base jsonb;
  r record;
  ex public.exercises;
  sub text;
  used text[];
  items jsonb := '[]'::jsonb;
begin
  base := public._training_summary(p_training);
  if base is null then
    return null;
  end if;
  select array_agg(ti.exercise_id) into used from public.training_items ti where ti.training_id = p_training;
  for r in
    select ti.* from public.training_items ti
    where ti.training_id = p_training
    order by case ti.phase when 'warmup' then 0 when 'main' then 1 else 2 end, ti.position
  loop
    select * into ex from public.exercises where id = r.exercise_id;
    if p_athlete is not null and public._is_blocked(p_athlete, ex.id) then
      sub := public._substitute_exercise(p_athlete, ex.id, used);
      if sub is null then
        continue;
      end if;
      used := used || sub;
      items := items || jsonb_build_array(jsonb_build_object(
        'phase', r.phase, 'position', r.position, 'sets', r.sets, 'value', null,
        'level', least(r.level, (select jsonb_array_length(levels) from public.exercises where id = sub)),
        'replaced_from', ex.id,
        'exercise', (select public._exercise_json(e) from public.exercises e where e.id = sub)));
    else
      items := items || jsonb_build_array(jsonb_build_object(
        'phase', r.phase, 'position', r.position, 'sets', r.sets, 'value', r.value,
        'level', least(r.level, jsonb_array_length(ex.levels)),
        'replaced_from', null,
        'exercise', public._exercise_json(ex)));
    end if;
  end loop;
  return base || jsonb_build_object('items', items);
end;
$$;

-- ---------------------------------------------------------------------
-- 1.3 Programmes
-- ---------------------------------------------------------------------

create or replace function public._program_summary(p_program text)
returns jsonb
language sql stable security definer
set search_path = public
as $$
  select jsonb_build_object(
    'id', p.id, 'title', p.title, 'description', p.description, 'goals', to_jsonb(p.goals),
    'areas', to_jsonb(p.areas), 'level', p.level,
    'days', (select count(*) from public.program_days d where d.program_id = p.id),
    'min_minutes', (select min((public._training_stats(d.training_id) ->> 'duration_min')::int)
                      from public.program_days d where d.program_id = p.id),
    'max_minutes', (select max((public._training_stats(d.training_id) ->> 'duration_min')::int)
                      from public.program_days d where d.program_id = p.id)
  )
  from public.programs p where p.id = p_program;
$$;

-- Dernier jour débloqué d'un programme suivi, vu depuis la date locale p_ref.
-- Règle : le jour suivant se débloque le lendemain (date locale) du dernier jour fait.
-- Le jour 1 est toujours ouvert. L'espace admin peut débloquer plus loin (unlocked_through).
create or replace function public._unlocked_through(p_ap uuid, p_ref date)
returns int
language plpgsql stable security definer
set search_path = public
as $$
declare
  ap public.athlete_programs;
  tz text;
  maxd int;
  last_date date;
  total int;
  base int;
begin
  select * into ap from public.athlete_programs where id = p_ap;
  if not found then
    return 0;
  end if;
  select a.timezone into tz from public.athletes a where a.id = ap.athlete_id;
  select max(w.program_day), max((w.done_at at time zone coalesce(tz, 'Europe/Paris'))::date)
    into maxd, last_date
  from public.workouts w where w.athlete_program_id = p_ap and w.program_day is not null;
  select count(*) into total from public.program_days d where d.program_id = ap.program_id;
  base := case
    when maxd is null then 1
    when last_date < p_ref then maxd + 1
    else maxd
  end;
  return least(greatest(base, ap.unlocked_through), total);
end;
$$;

-- Le programme suivi, jour par jour : fait, disponible ou verrouillé
create or replace function public._plan_json(p_athlete uuid)
returns jsonb
language plpgsql stable security definer
set search_path = public
as $$
declare
  ap public.athlete_programs;
  tz text;
  today date;
  unlocked int;
  days jsonb;
begin
  select * into ap from public.athlete_programs where athlete_id = p_athlete and status = 'actif';
  if not found then
    return null;
  end if;
  select a.timezone into tz from public.athletes a where a.id = p_athlete;
  today := (now() at time zone coalesce(tz, 'Europe/Paris'))::date;
  unlocked := public._unlocked_through(ap.id, today);
  select jsonb_agg(jsonb_build_object(
           'day', d.day,
           'status', case when w.id is not null then 'fait' when d.day <= unlocked then 'disponible' else 'verrouille' end,
           'done_at', w.done_at,
           'training', jsonb_build_object(
             'id', t.id, 'title', t.title, 'areas', to_jsonb(t.areas), 'level', t.level,
             'duration_min', (public._training_stats(t.id) ->> 'duration_min')::int)
         ) order by d.day)
    into days
  from public.program_days d
  join public.trainings t on t.id = d.training_id
  left join public.workouts w on w.athlete_program_id = ap.id and w.program_day = d.day
  where d.program_id = ap.program_id;
  return jsonb_build_object(
    'athlete_program_id', ap.id,
    'program', public._program_summary(ap.program_id),
    'started_on', ap.started_on,
    'unlocked_through', unlocked,
    'today_day', (select min((x ->> 'day')::int) from jsonb_array_elements(coalesce(days, '[]'::jsonb)) x
                   where x ->> 'status' = 'disponible'),
    'done_count', (select count(*) from jsonb_array_elements(coalesce(days, '[]'::jsonb)) x where x ->> 'status' = 'fait'),
    'days', coalesce(days, '[]'::jsonb)
  );
end;
$$;

-- Catalogue : programmes et entraînements hors programme (démarrage rapide, découverte, express), validés
create or replace function public.athlete_catalog(p_token text)
returns jsonb
language plpgsql stable security definer
set search_path = public
as $$
declare
  a public.athletes;
begin
  a := public._athlete_by_token(p_token);
  return jsonb_build_object(
    'programs', coalesce((
      select jsonb_agg(public._program_summary(p.id) order by p.level, p.title)
      from public.programs p
      where p.approved and exists (select 1 from public.program_days d where d.program_id = p.id)
    ), '[]'::jsonb),
    'trainings', coalesce((
      select jsonb_agg(public._training_summary(t.id) order by t.kind, t.level, t.title)
      from public.trainings t where t.approved and t.kind <> 'programme'
    ), '[]'::jsonb)
  );
end;
$$;

-- Un entraînement prêt à lancer, exercices tamponnés déjà remplacés
create or replace function public.athlete_training(p_token text, p_training text)
returns jsonb
language plpgsql stable security definer
set search_path = public
as $$
declare
  a public.athletes;
begin
  a := public._athlete_by_token(p_token);
  if not exists (select 1 from public.trainings where id = p_training and approved) then
    raise exception 'not_found' using errcode = 'P0002';
  end if;
  return public._training_json(p_training, a.id);
end;
$$;

-- Démarre un programme (le programme en cours, s'il y en a un, est marqué abandonné)
create or replace function public.athlete_start_program(p_token text, p_program text)
returns jsonb
language plpgsql volatile security definer
set search_path = public
as $$
declare
  a public.athletes;
begin
  a := public._athlete_by_token(p_token);
  if not exists (select 1 from public.programs p where p.id = p_program and p.approved
                   and exists (select 1 from public.program_days d where d.program_id = p.id)) then
    raise exception 'not_found' using errcode = 'P0002';
  end if;
  update public.athlete_programs set status = 'abandonne', ended_at = now()
   where athlete_id = a.id and status = 'actif';
  insert into public.athlete_programs (athlete_id, program_id, started_on)
  values (a.id, p_program, (now() at time zone a.timezone)::date);
  return public._plan_json(a.id);
end;
$$;

-- Enregistre un entraînement V5 (programme, démarrage rapide, découverte ou express).
-- Rattaché au jour de programme s'il correspond au programme suivi, n'est pas déjà fait et est débloqué
-- à la date de la séance ; sinon la séance est enregistrée quand même, sans rattachement.
-- « douleur » sur un exercice : tampon de 10 jours.
create or replace function public.athlete_submit_training(
  p_token text,
  p_client_id text,
  p_training text,
  p_program_day int default null,
  p_items jsonb default '[]'::jsonb,
  p_done_at timestamptz default null,
  p_rpe int default null,
  p_duration_min int default null,
  p_comment text default null
)
returns jsonb
language plpgsql volatile security definer
set search_path = public
as $$
declare
  a public.athletes;
  ap public.athlete_programs;
  w_id uuid;
  it jsonb;
  ex public.exercises;
  v_feeling text;
  v_pref text;
  v_done timestamptz;
  v_until timestamptz;
  blocked jsonb := '[]'::jsonb;
  linked boolean := false;
  today_count int;
  total int;
  done int;
begin
  a := public._athlete_by_token(p_token);
  if not exists (select 1 from public.trainings where id = p_training) then
    raise exception 'not_found' using errcode = 'P0002';
  end if;
  if p_rpe is not null and (p_rpe < 0 or p_rpe > 10) then
    raise exception 'invalid_rpe' using errcode = '22023';
  end if;
  if p_items is null then
    p_items := '[]'::jsonb;
  end if;
  if jsonb_typeof(p_items) <> 'array' or jsonb_array_length(p_items) > 60 then
    raise exception 'invalid_items' using errcode = '22023';
  end if;
  if p_client_id is not null and char_length(p_client_id) > 64 then
    raise exception 'invalid_client_id' using errcode = '22023';
  end if;

  if p_client_id is not null and exists (
    select 1 from public.workouts where client_id = p_client_id and athlete_id = a.id
  ) then
    return jsonb_build_object('status', 'duplicate', 'linked', false, 'blocked', '[]'::jsonb,
                              'plan', public._plan_json(a.id));
  end if;

  select count(*) into today_count from public.workouts
   where athlete_id = a.id and done_at > now() - interval '24 hours';
  if today_count >= 12 then
    raise exception 'too_many_workouts' using errcode = '54000';
  end if;

  v_done := case
    when p_done_at is null then now()
    when p_done_at > now() + interval '5 minutes' then now()
    when p_done_at < now() - interval '14 days' then now()
    else p_done_at
  end;

  if p_program_day is not null then
    select * into ap from public.athlete_programs where athlete_id = a.id and status = 'actif';
    if found
       and exists (select 1 from public.program_days d
                    where d.program_id = ap.program_id and d.day = p_program_day and d.training_id = p_training)
       and not exists (select 1 from public.workouts w
                        where w.athlete_program_id = ap.id and w.program_day = p_program_day)
       and p_program_day <= public._unlocked_through(ap.id, (v_done at time zone a.timezone)::date) then
      linked := true;
    end if;
  end if;

  insert into public.workouts (athlete_id, session_key, client_id, done_at, pain, neuro, comment, rpe, duration_min,
                               training_id, athlete_program_id, program_day)
  values (a.id, 'T', p_client_id, v_done, 0, false, nullif(trim(left(p_comment, 500)), ''), p_rpe,
          case when p_duration_min is null then null else greatest(0, least(p_duration_min, 240)) end,
          p_training, case when linked then ap.id end, case when linked then p_program_day end)
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
    select * into ex from public.exercises where id = (it ->> 'exercise_id');
    if not found or exists (select 1 from public.workout_items where workout_id = w_id and exercise_id = ex.id) then
      continue;
    end if;
    insert into public.workout_items (workout_id, exercise_id, level, feeling, preference)
    values (w_id, ex.id,
            least(greatest(coalesce((it ->> 'level')::int, 1), 1), jsonb_array_length(ex.levels)),
            v_feeling, v_pref);
    if v_feeling = 'douleur' then
      v_until := public._block_exercise(a.id, ex.id, v_done);
      blocked := blocked || jsonb_build_array(jsonb_build_object('exercise_id', ex.id, 'until', v_until));
    end if;
  end loop;

  -- Programme terminé quand tous les jours sont faits
  if linked then
    select count(*) into total from public.program_days where program_id = ap.program_id;
    select count(*) into done from public.workouts where athlete_program_id = ap.id and program_day is not null;
    if done >= total then
      update public.athlete_programs set status = 'termine', ended_at = now() where id = ap.id;
    end if;
  end if;

  return jsonb_build_object('status', 'ok', 'linked', linked, 'blocked', blocked, 'plan', public._plan_json(a.id));
end;
$$;

-- ---------------------------------------------------------------------
-- 1.4 Profil sportif
-- ---------------------------------------------------------------------

create or replace function public._profile_json(p_athlete uuid)
returns jsonb
language sql stable security definer
set search_path = public
as $$
  select (to_jsonb(p) - 'athlete_id') || jsonb_build_object(
    'bmi', case when p.height_cm is not null and p.weight_kg is not null
                then round(p.weight_kg / ((p.height_cm / 100.0) ^ 2), 1) end)
  from public.athlete_profiles p where p.athlete_id = p_athlete;
$$;

-- Enregistre tout ou partie du profil : seules les clés envoyées changent (null efface une réponse).
-- {"complete": true} marque le questionnaire comme terminé.
create or replace function public.athlete_save_profile(p_token text, p_profile jsonb)
returns jsonb
language plpgsql volatile security definer
set search_path = public
as $$
declare
  a public.athletes;
  allowed text[] := array['sex', 'goal', 'areas', 'motivation', 'morphology', 'height_cm', 'weight_kg', 'birth_year',
                          'target_weight_kg', 'last_fit', 'level', 'activity', 'sessions_per_week', 'session_minutes',
                          'equipment', 'style', 'disciplines', 'adherence', 'reward', 'feeling'];
  k text;
  cur jsonb;
  merged jsonb;
  rec public.athlete_profiles;
begin
  a := public._athlete_by_token(p_token);
  if p_profile is null or jsonb_typeof(p_profile) <> 'object' then
    raise exception 'invalid_profile' using errcode = '22023';
  end if;
  for k in select jsonb_object_keys(p_profile) loop
    if k <> 'complete' and not (k = any(allowed)) then
      raise exception 'invalid_profile_field' using errcode = '22023', detail = k;
    end if;
  end loop;
  if p_profile ? 'adherence' and jsonb_typeof(p_profile -> 'adherence') <> 'null' then
    if jsonb_typeof(p_profile -> 'adherence') <> 'object'
       or exists (select 1 from jsonb_each(p_profile -> 'adherence') x
                   where x.key not in ('choisir', 'ennui', 'demotive') or jsonb_typeof(x.value) <> 'boolean') then
      raise exception 'invalid_profile' using errcode = '22023', detail = 'adherence';
    end if;
  end if;

  select to_jsonb(p) into cur from public.athlete_profiles p where p.athlete_id = a.id;
  cur := coalesce(cur, jsonb_build_object('athlete_id', a.id));
  merged := cur || (p_profile - 'complete');
  -- une liste effacée redevient une liste vide
  foreach k in array array['areas', 'equipment', 'disciplines'] loop
    if coalesce(jsonb_typeof(merged -> k), 'null') = 'null' then
      merged := jsonb_set(merged, array[k], '[]'::jsonb);
    end if;
  end loop;
  if coalesce(jsonb_typeof(merged -> 'adherence'), 'null') = 'null' then
    merged := jsonb_set(merged, '{adherence}', '{}'::jsonb);
  end if;

  begin
    rec := jsonb_populate_record(null::public.athlete_profiles, merged);
    insert into public.athlete_profiles (
      athlete_id, sex, goal, areas, motivation, morphology, height_cm, weight_kg, birth_year, target_weight_kg,
      last_fit, level, activity, sessions_per_week, session_minutes, equipment, style, disciplines, adherence,
      reward, feeling, completed_at, updated_at)
    values (
      a.id, rec.sex, rec.goal, rec.areas, rec.motivation, rec.morphology, rec.height_cm, rec.weight_kg, rec.birth_year,
      rec.target_weight_kg, rec.last_fit, rec.level, rec.activity, rec.sessions_per_week, rec.session_minutes,
      rec.equipment, rec.style, rec.disciplines, rec.adherence, rec.reward, rec.feeling,
      case when coalesce((p_profile ->> 'complete')::boolean, false) then coalesce(rec.completed_at, now())
           else rec.completed_at end,
      now())
    on conflict (athlete_id) do update set
      sex = excluded.sex, goal = excluded.goal, areas = excluded.areas, motivation = excluded.motivation,
      morphology = excluded.morphology, height_cm = excluded.height_cm, weight_kg = excluded.weight_kg,
      birth_year = excluded.birth_year, target_weight_kg = excluded.target_weight_kg, last_fit = excluded.last_fit,
      level = excluded.level, activity = excluded.activity, sessions_per_week = excluded.sessions_per_week,
      session_minutes = excluded.session_minutes, equipment = excluded.equipment, style = excluded.style,
      disciplines = excluded.disciplines, adherence = excluded.adherence, reward = excluded.reward,
      feeling = excluded.feeling, completed_at = excluded.completed_at, updated_at = excluded.updated_at;
  exception
    when check_violation or not_null_violation or invalid_text_representation or numeric_value_out_of_range
      or datatype_mismatch or invalid_parameter_value or invalid_datetime_format then
      raise exception 'invalid_profile' using errcode = '22023', detail = sqlerrm;
  end;
  return public._profile_json(a.id);
end;
$$;

-- L'utilisateur efface tout son profil (taille, poids, réponses du questionnaire)
create or replace function public.athlete_delete_profile(p_token text)
returns void
language plpgsql volatile security definer
set search_path = public
as $$
declare
  a public.athletes;
begin
  a := public._athlete_by_token(p_token);
  delete from public.athlete_profiles where athlete_id = a.id;
end;
$$;

-- ---------------------------------------------------------------------
-- Espace admin (amorce, interface au bloc 7)
-- ---------------------------------------------------------------------

-- Lève un tampon « Ça fait mal » avant ses 10 jours
create or replace function public.coach_lift_block(p_athlete uuid, p_exercise text)
returns void
language plpgsql volatile security definer
set search_path = public
as $$
begin
  if not public.is_coach() then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  delete from public.exercise_blocks where athlete_id = p_athlete and exercise_id = p_exercise;
end;
$$;

-- Débloque les jours du programme suivi jusqu'au jour p_day
create or replace function public.coach_unlock_day(p_athlete uuid, p_day int)
returns void
language plpgsql volatile security definer
set search_path = public
as $$
begin
  if not public.is_coach() then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  if p_day is null or p_day < 1 or p_day > 120 then
    raise exception 'invalid_day' using errcode = '22023';
  end if;
  update public.athlete_programs set unlocked_through = greatest(unlocked_through, p_day)
   where athlete_id = p_athlete and status = 'actif';
  if not found then
    raise exception 'not_found' using errcode = 'P0002';
  end if;
end;
$$;

-- ---------------------------------------------------------------------
-- Droits
-- ---------------------------------------------------------------------

revoke all on all tables in schema public from anon;
revoke execute on all functions in schema public from public, anon;

grant select, insert, update, delete on all tables in schema public to authenticated;

grant execute on function public.athlete_get(text) to anon, authenticated;
grant execute on function public.athlete_submit_workout(text, text, text, int, boolean, jsonb, text, timestamptz, int, int, jsonb, jsonb) to anon, authenticated;
grant execute on function public.athlete_set_level(text, text, int) to anon, authenticated;
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
grant execute on function public.athlete_set_week_plan(text, jsonb) to anon, authenticated;
grant execute on function public.coach_set_week_plan(uuid, jsonb) to authenticated;
grant execute on function public.coach_set_levelup_mode(uuid, text) to authenticated;

-- V5
grant execute on function public.athlete_flag_pain(text, text) to anon, authenticated;
grant execute on function public.athlete_catalog(text) to anon, authenticated;
grant execute on function public.athlete_training(text, text) to anon, authenticated;
grant execute on function public.athlete_start_program(text, text) to anon, authenticated;
grant execute on function public.athlete_submit_training(text, text, text, int, jsonb, timestamptz, int, int, text) to anon, authenticated;
grant execute on function public.athlete_save_profile(text, jsonb) to anon, authenticated;
grant execute on function public.athlete_delete_profile(text) to anon, authenticated;
grant execute on function public.coach_lift_block(uuid, text) to authenticated;
grant execute on function public.coach_unlock_day(uuid, int) to authenticated;
