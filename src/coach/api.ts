import { supabase } from '../lib/supabase';
import type { Block, Exercise, Feeling, Level, Preference, ProgramSessionKey, SessionKey } from '../lib/types';

export interface CoachAthlete {
  id: string;
  first_name: string;
  access_token: string;
  start_date: string;
  coach_message: string | null;
  frozen: boolean;
  frozen_at: string | null;
  allow_swaps: boolean;
}

/** Exercice du catalogue tel que le coach le voit (avec validation et source). */
export interface CoachExercise extends Exercise {
  approved: boolean;
  source: string | null;
}

export interface CoachProgramItem {
  athlete_id: string;
  session_key: ProgramSessionKey;
  block: Block;
  position: number;
  level: number;
  sets: number | null;
  exercise_id: string;
  exercises: { name: string; kind: string; levels: Level[]; max_sets: number } | null;
}

export interface ProgramChange {
  id: string;
  athlete_id: string;
  session_key: ProgramSessionKey;
  kind: 'swap' | 'add' | 'remove' | 'sets';
  from_exercise: string | null;
  to_exercise: string | null;
  source: 'athlete' | 'coach';
  reason: string | null;
  created_at: string;
}

export interface CoachWorkout {
  id: string;
  athlete_id: string;
  session_key: SessionKey;
  done_at: string;
  pain: number;
  neuro: boolean;
  comment: string | null;
  reviewed: boolean;
  rpe: number | null;
  duration_min: number | null;
  workout_items: { exercise_id: string; level: number; feeling: Feeling | null; preference: Preference | null }[];
}

export interface LevelChange {
  id: string;
  athlete_id: string;
  exercise_id: string;
  from_level: number;
  to_level: number;
  source: 'auto' | 'coach';
  reason: string | null;
  created_at: string;
}

export interface Proposal {
  athlete_id: string;
  first_name: string;
  exercise_id: string;
  exercise_name: string;
  session_key: ProgramSessionKey;
  level: number;
  max_level: number;
}

function db() {
  if (!supabase) throw new Error('not_configured');
  return supabase;
}

export async function isCoach(): Promise<boolean> {
  const { data, error } = await db().rpc('is_coach');
  if (error) throw error;
  return Boolean(data);
}

export async function loadAthletes(): Promise<CoachAthlete[]> {
  const { data, error } = await db()
    .from('athletes')
    .select('id, first_name, access_token, start_date, coach_message, frozen, frozen_at, allow_swaps')
    .order('created_at');
  if (error) throw error;
  return (data ?? []) as CoachAthlete[];
}

export async function loadProgram(athleteId: string): Promise<CoachProgramItem[]> {
  const { data, error } = await db()
    .from('program_items')
    .select('athlete_id, session_key, block, position, level, sets, exercise_id, exercises(name, kind, levels, max_sets)')
    .eq('athlete_id', athleteId)
    .eq('active', true)
    .order('session_key')
    .order('position');
  // le bloc (échauffement, circuit, retour au calme) se trie côté client
  if (error) throw error;
  return (data ?? []) as unknown as CoachProgramItem[];
}

export async function loadWorkouts(athleteId: string, limit = 120): Promise<CoachWorkout[]> {
  const { data, error } = await db()
    .from('workouts')
    .select('id, athlete_id, session_key, done_at, pain, neuro, comment, reviewed, rpe, duration_min, workout_items(exercise_id, level, feeling, preference)')
    .eq('athlete_id', athleteId)
    .order('done_at', { ascending: false })
    .limit(limit);
  if (error) throw error;
  return (data ?? []) as CoachWorkout[];
}

export async function loadUnreviewedAlerts(): Promise<CoachWorkout[]> {
  const { data, error } = await db()
    .from('workouts')
    .select('id, athlete_id, session_key, done_at, pain, neuro, comment, reviewed, rpe, duration_min, workout_items(exercise_id, level, feeling, preference)')
    .eq('reviewed', false)
    .order('done_at', { ascending: false })
    .limit(200);
  if (error) throw error;
  return ((data ?? []) as CoachWorkout[]).filter(isAlert);
}

export function isAlert(w: CoachWorkout): boolean {
  return w.neuro || w.pain > 3 || w.workout_items.some((i) => i.feeling === 'douleur') || Boolean(w.comment);
}

export async function loadChanges(athleteId: string): Promise<LevelChange[]> {
  const { data, error } = await db()
    .from('level_changes')
    .select('*')
    .eq('athlete_id', athleteId)
    .order('created_at', { ascending: false })
    .limit(30);
  if (error) throw error;
  return (data ?? []) as LevelChange[];
}

export async function loadProposals(): Promise<Proposal[]> {
  const { data, error } = await db().rpc('coach_proposals');
  if (error) throw error;
  const seen = new Set<string>();
  // un exercice présent dans deux séances ne doit apparaître qu'une fois
  return ((data ?? []) as Proposal[]).filter((p) => {
    const k = `${p.athlete_id}:${p.exercise_id}`;
    if (seen.has(k)) return false;
    seen.add(k);
    return true;
  });
}

export async function setLevel(athleteId: string, exerciseId: string, level: number, reason: string | null) {
  const { error } = await db().rpc('coach_set_level', {
    p_athlete: athleteId,
    p_exercise: exerciseId,
    p_level: level,
    p_reason: reason,
  });
  if (error) throw error;
}

export async function markReviewed(ids: string[]) {
  if (!ids.length) return;
  const { error } = await db().from('workouts').update({ reviewed: true }).in('id', ids);
  if (error) throw error;
}

export async function saveMessage(athleteId: string, message: string | null) {
  const { error } = await db().from('athletes').update({ coach_message: message }).eq('id', athleteId);
  if (error) throw error;
}

export async function unfreeze(athleteId: string) {
  const { error } = await db().from('athletes').update({ frozen: false, frozen_at: null }).eq('id', athleteId);
  if (error) throw error;
}

export async function rotateToken(athleteId: string): Promise<string> {
  const { data, error } = await db().rpc('coach_rotate_token', { p_athlete: athleteId });
  if (error) throw error;
  return data as string;
}

// ---------- V2 : bibliothèque et éditeur de programme ----------

export async function loadLibrary(): Promise<CoachExercise[]> {
  const { data, error } = await db()
    .from('exercises')
    .select('id, name, kind, illustration, video_url, cues, caution, levels, zones, equipment, intensity, family, pattern, max_sets, approved, source')
    .order('name');
  if (error) throw error;
  return (data ?? []) as CoachExercise[];
}

/** Crée ou modifie un exercice (le serveur valide les champs). */
export async function saveExercise(ex: Partial<CoachExercise> & { id: string; name: string; kind: string; levels: Level[] }): Promise<string> {
  const { data, error } = await db().rpc('coach_save_exercise', { p_ex: ex });
  if (error) throw error;
  return data as string;
}

export async function setApproved(exerciseId: string, approved: boolean) {
  const { error } = await db().from('exercises').update({ approved }).eq('id', exerciseId);
  if (error) throw error;
}

export async function loadProgramChanges(athleteId: string): Promise<ProgramChange[]> {
  const { data, error } = await db()
    .from('program_changes')
    .select('*')
    .eq('athlete_id', athleteId)
    .order('created_at', { ascending: false })
    .limit(30);
  if (error) throw error;
  return (data ?? []) as ProgramChange[];
}

export async function swapExercise(athleteId: string, session: ProgramSessionKey, from: string, to: string, reason: string | null) {
  const { error } = await db().rpc('coach_swap_exercise', {
    p_athlete: athleteId,
    p_session: session,
    p_from: from,
    p_to: to,
    p_reason: reason,
  });
  if (error) throw error;
}

export async function addExercise(athleteId: string, session: ProgramSessionKey, exercise: string, block: Block) {
  const { error } = await db().rpc('coach_add_exercise', { p_athlete: athleteId, p_session: session, p_exercise: exercise, p_block: block });
  if (error) throw error;
}

export async function removeExercise(athleteId: string, session: ProgramSessionKey, exercise: string) {
  const { error } = await db().rpc('coach_remove_exercise', { p_athlete: athleteId, p_session: session, p_exercise: exercise });
  if (error) throw error;
}

export async function setSets(athleteId: string, session: ProgramSessionKey, exercise: string, sets: number | null) {
  const { error } = await db().rpc('coach_set_sets', { p_athlete: athleteId, p_session: session, p_exercise: exercise, p_sets: sets });
  if (error) throw error;
}

export async function moveExercise(athleteId: string, session: ProgramSessionKey, exercise: string, dir: -1 | 1) {
  const { error } = await db().rpc('coach_move_exercise', { p_athlete: athleteId, p_session: session, p_exercise: exercise, p_dir: dir });
  if (error) throw error;
}

export async function setAllowSwaps(athleteId: string, allow: boolean) {
  const { error } = await db().from('athletes').update({ allow_swaps: allow }).eq('id', athleteId);
  if (error) throw error;
}
