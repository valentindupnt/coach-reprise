export type SessionKey = 'A' | 'B' | 'M' | 'C';
export type ProgramSessionKey = 'A' | 'B' | 'M';
/** Un jour de la semaine type : une séance, un repos (R) ou « A ou B selon la semaine » (AB). */
export type WeekSlot = SessionKey | 'R' | 'AB';
export type Feeling = 'facile' | 'bien' | 'dur' | 'douleur';
export type ExerciseKind = 'force' | 'gainage' | 'mobilite' | 'etirement' | 'respiration' | 'cardio';
export type Block = 'warmup' | 'main' | 'cooldown';
export type Preference = 'aime' | 'a_changer';

export interface Level {
  label: string;
  seconds?: number;
  /** V5 : répétitions, pour un exercice en mode « reps ». */
  reps?: number;
}

// ---------- V5 : étiquettes (voir docs/MODELE-V5.md) ----------
export type Area = 'bras' | 'epaules' | 'abdos' | 'fessiers' | 'jambes' | 'dos' | 'corps_entier';
export type ExerciseGoal = 'renforcer' | 'tonifier' | 'mobilite' | 'cardio' | 'detente';
export type Discipline =
  | 'renforcement' | 'gainage' | 'calisthenie' | 'cardio' | 'hiit' | 'yoga' | 'etirement' | 'pilates' | 'meditation';
export type ExerciseMode = 'time' | 'reps';
export interface Tutorial {
  steps?: string[];
  breathing?: string;
  mistakes?: string[];
}

export interface Exercise {
  id: string;
  name: string;
  kind: ExerciseKind;
  illustration: string | null;
  video_url: string | null;
  cues: string[];
  caution: string | null;
  levels: Level[];
  zones: string[];
  equipment: string[];
  intensity: number;
  family: string | null;
  pattern: string | null;
  max_sets: number;
  // V5
  muscles_primary?: string[];
  muscles_secondary?: string[];
  areas?: Area[];
  goals?: ExerciseGoal[];
  discipline?: Discipline | null;
  /** Avec sauts. */
  impact?: boolean;
  mode?: ExerciseMode;
  default_value?: number | null;
  /** Valeur MET du Compendium 2024 et code d'activité (calories ≈ MET × poids × heures). */
  met?: number | null;
  met_code?: string | null;
  tutorial?: Tutorial | null;
  source?: string | null;
}

export interface ProgramItem {
  session_key: ProgramSessionKey;
  block: Block;
  position: number;
  level: number;
  /** Nombre de tours fixé par le coach pour cet exercice ; null = selon la phase. */
  sets: number | null;
  exercise: Exercise;
}

export type SwapWhy = 'variante' | 'autre_zone' | 'proche';

export interface SwapOption {
  why: SwapWhy;
  exercise: Exercise;
}

/** V5 : tampon « Ça fait mal » en cours (l'exercice n'est plus proposé jusqu'à until). */
export interface ExerciseBlock {
  exercise_id: string;
  until: string;
}

export interface Library {
  exercises: Exercise[];
  in_program: string[];
  blocks?: ExerciseBlock[];
}

export interface AthleteData {
  athlete: {
    first_name: string;
    start_date: string;
    coach_message: string | null;
    frozen: boolean;
    allow_swaps: boolean;
    /** Semaine type personnalisée (lundi en premier) ; null = semaine par défaut. */
    week_plan: WeekSlot[] | null;
    /** Qui valide la montée de niveau : le coach ou l'athlète elle-même (avec garde-fous). */
    levelup_mode: 'coach' | 'self';
    /** Nombre total de séances enregistrées. */
    workout_count: number;
  };
  program: ProgramItem[];
  /** V5 : profil sportif (null tant que le questionnaire n'est pas commencé). */
  profile?: Profile | null;
  /** V5 : programme suivi jour par jour (null si aucun). */
  plan?: Plan | null;
  /** V5 : tampons « Ça fait mal » en cours. */
  blocks?: ExerciseBlock[];
  workouts: { session_key: SessionKey; done_at: string; pain: number; rpe: number | null; duration_min: number | null }[];
  recent_changes: {
    exercise_id: string;
    from_level: number;
    to_level: number;
    source: 'auto' | 'coach' | 'self';
    created_at: string;
  }[];
}

export interface WorkoutSubmission {
  client_id: string;
  session: SessionKey;
  pain: number;
  neuro: boolean;
  items: { exercise_id: string; feeling: Feeling | null; preference?: Preference | null }[];
  comment: string | null;
  /** Heure de fin de séance (envoyée telle quelle, même si l'envoi a lieu plus tard). */
  created_at: string;
  rpe?: number | null;
  duration_min?: number | null;
  swaps?: { session: ProgramSessionKey; from: string; to: string }[];
  /** Niveaux choisis par l'athlète pendant la séance (plus dur / plus facile). */
  levels?: { exercise_id: string; level: number }[];
}

export interface SubmitResult {
  status: 'ok' | 'duplicate';
  frozen: boolean;
  regressed: { exercise_id: string; to_level: number }[];
  swapped?: { session: ProgramSessionKey; from: string; to: string }[];
  /** Exercices montés d'un niveau automatiquement (mode « l'athlète monte seule »). */
  leveled_up?: { exercise_id: string; to_level: number }[];
  /** V5 : exercices mis de côté 10 jours après « douleur ». */
  blocked?: ExerciseBlock[];
}

// ---------- V5 : entraînements, programmes, profil ----------
export type TrainingKind = 'programme' | 'rapide' | 'decouverte' | 'express';
export type Phase = 'warmup' | 'main' | 'cooldown';

export interface TrainingSummary {
  id: string;
  title: string;
  description: string | null;
  kind: TrainingKind;
  /** 1 débutant, 2 intermédiaire, 3 avancé. */
  level: 1 | 2 | 3;
  areas: Area[];
  discipline: string | null;
  rounds: number;
  rest_seconds: number;
  duration_min: number;
  active_seconds: number;
  rest_seconds_total: number;
  /** Calories ≈ met_minutes × poids (kg) / 60. */
  met_minutes: number;
  exercise_count: number;
  /** Matériel nécessaire (hors « aucun »). */
  equipment: string[];
  impact: boolean;
}

export interface TrainingItem {
  phase: Phase;
  position: number;
  level: number;
  /** Durée (s) ou répétitions imposées ; null = valeur du niveau ou de l'exercice. */
  value: number | null;
  sets: number | null;
  /** Exercice d'origine, s'il a été remplacé à cause d'un tampon « Ça fait mal ». */
  replaced_from: string | null;
  exercise: Exercise;
}

export interface Training extends TrainingSummary {
  items: TrainingItem[];
}

export interface ProgramSummary {
  id: string;
  title: string;
  description: string | null;
  goals: string[];
  areas: Area[];
  level: 1 | 2 | 3;
  days: number;
  min_minutes: number | null;
  max_minutes: number | null;
}

export type PlanDayStatus = 'fait' | 'disponible' | 'verrouille';

export interface PlanDay {
  day: number;
  status: PlanDayStatus;
  done_at: string | null;
  training: { id: string; title: string; areas: Area[]; level: number; duration_min: number };
}

export interface Plan {
  athlete_program_id: string;
  program: ProgramSummary;
  started_on: string;
  unlocked_through: number;
  /** Jour à faire aujourd'hui ; null si le suivant s'ouvre demain. */
  today_day: number | null;
  done_count: number;
  days: PlanDay[];
}

export interface Catalog {
  programs: ProgramSummary[];
  trainings: TrainingSummary[];
}

export interface Profile {
  sex: 'femme' | 'homme' | null;
  goal: 'perdre_du_poids' | 'renforcer' | 'tonifier' | 'garder_la_forme' | null;
  areas: Area[];
  motivation: 'confiance' | 'vitalite' | 'douleurs' | 'sommeil' | 'bien_etre' | null;
  morphology: 'mince' | 'moyenne' | 'enveloppee' | 'musclee' | null;
  height_cm: number | null;
  weight_kg: number | null;
  birth_year: number | null;
  target_weight_kg: number | null;
  last_fit: 'en_ce_moment' | 'moins_1_an' | '1_3_ans' | 'plus_3_ans' | 'jamais' | null;
  level: 'debutant' | 'intermediaire' | 'avance' | null;
  activity: 'sedentaire' | 'peu_actif' | 'actif' | 'tres_actif' | null;
  sessions_per_week: number | null;
  session_minutes: 10 | 15 | 20 | 30 | null;
  equipment: ('aucun' | 'tapis' | 'elastique' | 'halteres' | 'chaise' | 'mur')[];
  style: 'facile' | 'transpiration_legere' | 'intense' | null;
  disciplines: string[];
  adherence: { choisir?: boolean; ennui?: boolean; demotive?: boolean };
  reward: 'vetements' | 'cadeau' | 'voyage' | 'partager' | 'autre' | null;
  feeling: 'heureux' | 'en_forme' | 'confiant' | 'fier' | 'energie' | 'rassure' | null;
  completed_at: string | null;
  updated_at: string;
  /** Calculé par la base. */
  bmi: number | null;
}

/** Réponses envoyées : seules les clés présentes changent ; complete = questionnaire terminé. */
export type ProfilePatch = Partial<Omit<Profile, 'completed_at' | 'updated_at' | 'bmi'>> & { complete?: boolean };

export interface TrainingSubmission {
  client_id: string;
  training_id: string;
  /** Jour du programme suivi, s'il s'agit de la séance du plan. */
  program_day: number | null;
  items: { exercise_id: string; level?: number; feeling: Feeling | null; preference?: Preference | null }[];
  created_at: string;
  rpe?: number | null;
  duration_min?: number | null;
  comment?: string | null;
}

export interface TrainingResult {
  status: 'ok' | 'duplicate';
  /** Vrai si la séance a validé le jour du programme. */
  linked: boolean;
  blocked: ExerciseBlock[];
  plan: Plan | null;
}
