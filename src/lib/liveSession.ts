import type { ProgramItem, ProgramSessionKey } from './types';
import type { SessionResult } from '../athlete/Player';

/**
 * Séance en cours, gardée sur le téléphone : si la page se recharge (changement d'appli, écran
 * verrouillé, onglet fermé par le système), on peut reprendre là où on en était.
 */
export interface LiveSession {
  v: 1;
  session: ProgramSessionKey;
  savedAt: number;
  rounds: number;
  /** Lecteur en cours (index d'étape, temps restant) — absent une fois la séance terminée. */
  index?: number;
  remainingMs?: number;
  /** Temps réellement passé en séance (hors pauses), en millisecondes. */
  activeMs?: number;
  replaced?: Record<string, ProgramItem>;
  /** Niveaux choisis en séance : exercice -> niveau. */
  levels?: Record<string, number>;
  skipped?: string[];
  painful?: string[];
  /** Étapes d'effort réellement faites : numéro d'étape -> exercice. */
  marks?: Record<number, string>;
  /** Séance terminée, ressenti pas encore envoyé. */
  finished?: SessionResult;
}

const KEY = (token: string) => `cr-live-${token.slice(0, 12)}`;
/** Au-delà, la séance en cours est considérée comme abandonnée. */
export const LIVE_MAX_AGE_MS = 12 * 3600_000;

export function readLive(token: string): LiveSession | null {
  try {
    const raw = localStorage.getItem(KEY(token));
    if (!raw) return null;
    const live = JSON.parse(raw) as LiveSession;
    if (live?.v !== 1 || !live.session || Date.now() - live.savedAt > LIVE_MAX_AGE_MS) {
      localStorage.removeItem(KEY(token));
      return null;
    }
    return live;
  } catch {
    return null;
  }
}

export function writeLive(token: string, live: LiveSession) {
  try {
    localStorage.setItem(KEY(token), JSON.stringify(live));
  } catch {
    /* stockage indisponible : l'app fonctionne quand même, sans reprise */
  }
}

export function clearLive(token: string) {
  try {
    localStorage.removeItem(KEY(token));
  } catch {
    /* ignoré */
  }
}
