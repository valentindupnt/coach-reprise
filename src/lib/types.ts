export type SessionKey = 'A' | 'B' | 'M' | 'C';
export type ProgramSessionKey = 'A' | 'B' | 'M';
export type Feeling = 'facile' | 'bien' | 'dur' | 'douleur';
export type ExerciseKind = 'force' | 'gainage' | 'mobilite' | 'etirement' | 'respiration';

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
}

export interface ProgramItem {
  session_key: ProgramSessionKey;
  position: number;
  level: number;
  exercise: Exercise;
}

export interface AthleteData {
  athlete: {
    first_name: string;
    start_date: string;
    coach_message: string | null;
    frozen: boolean;
  };
  program: ProgramItem[];
  workouts: { session_key: SessionKey; done_at: string; pain: number }[];
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
  items: { exercise_id: string; feeling: Feeling }[];
  comment: string | null;
  created_at: string;
}

export interface SubmitResult {
  status: 'ok' | 'duplicate';
  frozen: boolean;
  regressed: { exercise_id: string; to_level: number }[];
}
