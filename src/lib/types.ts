export type SessionKey = 'A' | 'B' | 'M' | 'C';
export type ProgramSessionKey = 'A' | 'B' | 'M';
export type Feeling = 'facile' | 'bien' | 'dur' | 'douleur';
export type ExerciseKind = 'force' | 'gainage' | 'mobilite' | 'etirement' | 'respiration';
export type Block = 'warmup' | 'main' | 'cooldown';
export type Preference = 'aime' | 'a_changer';

export interface Level {
  label: string;
  seconds?: number;
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

export interface Library {
  exercises: Exercise[];
  in_program: string[];
}

export interface AthleteData {
  athlete: {
    first_name: string;
    start_date: string;
    coach_message: string | null;
    frozen: boolean;
    allow_swaps: boolean;
  };
  program: ProgramItem[];
  workouts: { session_key: SessionKey; done_at: string; pain: number; rpe: number | null; duration_min: number | null }[];
  recent_changes: {
    exercise_id: string;
    from_level: number;
    to_level: number;
    source: 'auto' | 'coach';
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
}

export interface SubmitResult {
  status: 'ok' | 'duplicate';
  frozen: boolean;
  regressed: { exercise_id: string; to_level: number }[];
  swapped?: { session: ProgramSessionKey; from: string; to: string }[];
}
