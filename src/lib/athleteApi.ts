import { supabase, isNetworkError } from './supabase';
import type { AthleteData, Library, ProgramSessionKey, SubmitResult, SwapOption, WorkoutSubmission } from './types';

const CACHE_KEY = (token: string) => `cr-cache-${token.slice(0, 12)}`;
const QUEUE_KEY = (token: string) => `cr-queue-${token.slice(0, 12)}`;
const LIB_KEY = (token: string) => `cr-lib-${token.slice(0, 12)}`;

function safeGet<T>(key: string): T | null {
  try {
    const raw = localStorage.getItem(key);
    return raw ? (JSON.parse(raw) as T) : null;
  } catch {
    return null;
  }
}
function safeSet(key: string, value: unknown) {
  try {
    localStorage.setItem(key, JSON.stringify(value));
  } catch {
    /* stockage indisponible (navigation privée) : l'app fonctionne quand même */
  }
}

export function readCache(token: string): AthleteData | null {
  return safeGet<AthleteData>(CACHE_KEY(token));
}

export async function fetchAthlete(token: string): Promise<AthleteData> {
  if (!supabase) throw new Error('not_configured');
  const { data, error } = await supabase.rpc('athlete_get', { p_token: token });
  if (error) throw error;
  safeSet(CACHE_KEY(token), data);
  return data as AthleteData;
}

export function readLibraryCache(token: string): Library | null {
  return safeGet<Library>(LIB_KEY(token));
}

export async function fetchLibrary(token: string): Promise<Library> {
  if (!supabase) throw new Error('not_configured');
  const { data, error } = await supabase.rpc('athlete_library', { p_token: token });
  if (error) throw error;
  safeSet(LIB_KEY(token), data);
  return data as Library;
}

/** Propositions de remplacement (variante, autre zone) choisies par la base. */
export async function fetchSwapOptions(
  token: string,
  session: ProgramSessionKey,
  exerciseId: string,
  limit = 2,
): Promise<SwapOption[]> {
  if (!supabase) throw new Error('not_configured');
  const { data, error } = await supabase.rpc('athlete_swap_options', {
    p_token: token,
    p_session: session,
    p_exercise: exerciseId,
    p_limit: limit,
  });
  if (error) throw error;
  return (data ?? []) as SwapOption[];
}

export function pendingWorkouts(token: string): WorkoutSubmission[] {
  return safeGet<WorkoutSubmission[]>(QUEUE_KEY(token)) ?? [];
}

function setPending(token: string, list: WorkoutSubmission[]) {
  safeSet(QUEUE_KEY(token), list);
}

async function sendOne(token: string, w: WorkoutSubmission): Promise<SubmitResult> {
  if (!supabase) throw new Error('not_configured');
  const { data, error } = await supabase.rpc('athlete_submit_workout', {
    p_token: token,
    p_client_id: w.client_id,
    p_session: w.session,
    p_pain: w.pain,
    p_neuro: w.neuro,
    p_items: w.items,
    p_comment: w.comment,
    p_done_at: w.created_at,
    p_rpe: w.rpe ?? null,
    p_duration_min: w.duration_min ?? null,
    p_swaps: w.swaps ?? [],
  });
  if (error) throw error;
  return data as SubmitResult;
}

/**
 * Enregistre une séance. En cas de coupure réseau, elle est gardée sur le
 * téléphone et renvoyée plus tard (le serveur ignore les doublons).
 */
export async function submitWorkout(
  token: string,
  w: WorkoutSubmission,
): Promise<{ result: SubmitResult | null; queued: boolean }> {
  try {
    const result = await sendOne(token, w);
    return { result, queued: false };
  } catch (e) {
    if (isNetworkError(e)) {
      setPending(token, [...pendingWorkouts(token).filter((p) => p.client_id !== w.client_id), w]);
      return { result: null, queued: true };
    }
    throw e;
  }
}

/** Renvoie les séances en attente. Retourne le nombre envoyé. */
export async function flushPending(token: string): Promise<{ sent: number; frozen: boolean }> {
  const list = pendingWorkouts(token);
  let sent = 0;
  let frozen = false;
  const remaining: WorkoutSubmission[] = [];
  for (const w of list) {
    try {
      const r = await sendOne(token, w);
      sent++;
      frozen = frozen || r.frozen;
    } catch (e) {
      if (isNetworkError(e)) remaining.push(w);
      // autre erreur (donnée refusée) : on abandonne cette séance pour ne pas bloquer la file
    }
  }
  setPending(token, remaining);
  return { sent, frozen };
}

export function newClientId(): string {
  if (typeof crypto !== 'undefined' && 'randomUUID' in crypto) return crypto.randomUUID();
  return `${Date.now()}-${Math.random().toString(36).slice(2)}`;
}
