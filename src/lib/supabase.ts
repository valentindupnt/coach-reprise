import { createClient, type SupabaseClient } from '@supabase/supabase-js';

const url = import.meta.env.VITE_SUPABASE_URL as string | undefined;
const key = import.meta.env.VITE_SUPABASE_KEY as string | undefined;

export const isConfigured = Boolean(url && key);

export const supabase: SupabaseClient | null = isConfigured
  ? createClient(url!, key!, {
      auth: {
        persistSession: true,
        autoRefreshToken: true,
        detectSessionInUrl: false,
        storageKey: 'coach-reprise-auth',
      },
    })
  : null;

/** Message lisible à partir d'une erreur Supabase / réseau. */
export function readableError(e: unknown): string {
  const msg = e && typeof e === 'object' && 'message' in e ? String((e as { message: unknown }).message) : String(e);
  if (/invalid_token/.test(msg)) return 'Ce lien n\'est plus valide. Demande le nouveau lien à ton coach.';
  if (/Failed to fetch|NetworkError|Load failed|network/i.test(msg)) return 'Pas de connexion internet pour le moment.';
  if (/too_many_workouts/.test(msg)) return 'Beaucoup de séances enregistrées aujourd\'hui. Réessaie demain.';
  if (/Invalid login credentials/i.test(msg)) return 'E-mail ou mot de passe incorrect.';
  if (/forbidden|permission denied/i.test(msg)) return 'Ce compte n\'a pas accès au panneau coach.';
  return 'Une erreur est survenue. Réessaie dans un instant.';
}

export function isNetworkError(e: unknown): boolean {
  const msg = e && typeof e === 'object' && 'message' in e ? String((e as { message: unknown }).message) : String(e);
  return /Failed to fetch|NetworkError|Load failed|network|timeout/i.test(msg);
}
