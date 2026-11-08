// FLEXO, bloc Étirements : déroulé d'un set guidé, posture par posture.
// Aucune dépendance à l'écran : testé dans tests/stretch.test.mjs.
import type { Moment, StretchMode, StretchSport, Training, TrainingItem } from './types';

export interface Segment {
  /** Identifiant d'exercice, pour retrouver la fiche. */
  exerciseId: string;
  /** Position de la posture dans le set (0, 1, 2...). */
  index: number;
  /** « Côté droit », « Côté gauche », ou null si la posture n'a pas de côté. */
  side: 'droit' | 'gauche' | null;
  seconds: number;
  /** Vrai pour la transition entre deux postures : on se prépare, la posture suivante est annoncée. */
  prepare: boolean;
}

/** Durée d'une posture : valeur imposée par le set, sinon secondes du niveau, sinon valeur par défaut. */
export function postureSeconds(item: TrainingItem): number {
  const ex = item.exercise;
  if (item.value) return item.value;
  const lv = ex.levels[Math.min(Math.max(item.level, 1), ex.levels.length) - 1];
  return lv?.seconds ?? ex.default_value ?? 45;
}

export function levelLabel(item: TrainingItem): string {
  const ex = item.exercise;
  return ex.levels[Math.min(Math.max(item.level, 1), ex.levels.length) - 1]?.label ?? '';
}

/**
 * Les côtés se lisent dans le libellé du niveau, par exemple « 20 s par côté » ou « 2 × 20 s par côté » :
 * on tient chaque côté à tour de rôle. Un libellé « par côté » sans durée (« 8 répétitions par côté »)
 * partage le temps en deux moitiés. Sans « par côté », la posture est un seul bloc.
 */
export function splitSides(label: string, seconds: number): { side: 'droit' | 'gauche' | null; seconds: number }[] {
  const m = /(?:(\d+)\s*×\s*)?(\d+)\s*s\s+par\s+côté/i.exec(label);
  if (m) {
    const reps = m[1] ? Number(m[1]) : 1;
    const hold = Number(m[2]);
    if (reps * hold * 2 === seconds) {
      return Array.from({ length: reps }, () => [
        { side: 'droit' as const, seconds: hold },
        { side: 'gauche' as const, seconds: hold },
      ]).flat();
    }
  }
  if (/par\s+côté/i.test(label) && seconds >= 2) {
    const half = Math.floor(seconds / 2);
    return [
      { side: 'droit', seconds: half },
      { side: 'gauche', seconds: seconds - half },
    ];
  }
  return [{ side: null, seconds }];
}

/** Déroulé complet : les postures dans l'ordre, une transition de `rest_seconds` entre deux postures. */
export function buildSegments(training: Training): Segment[] {
  const items = [...training.items].sort((a, b) => a.position - b.position);
  const out: Segment[] = [];
  items.forEach((item, index) => {
    if (index > 0 && training.rest_seconds > 0) {
      out.push({ exerciseId: item.exercise.id, index, side: null, seconds: training.rest_seconds, prepare: true });
    }
    for (const part of splitSides(levelLabel(item), postureSeconds(item))) {
      out.push({ exerciseId: item.exercise.id, index, side: part.side, seconds: part.seconds, prepare: false });
    }
  });
  return out;
}

export const totalSeconds = (segments: Segment[]) => segments.reduce((a, s) => a + s.seconds, 0);

export const MOMENT_LABEL: Record<Moment, string> = { avant: 'Avant l\'effort', apres: 'Après l\'effort', hors_seance: 'Hors séance' };
export const SPORT_LABEL: Record<StretchSport, string> = { velo: 'Vélo', course: 'Course', muscu: 'Muscu', tous: 'Tous sports' };
export const MODE_LABEL: Record<StretchMode, string> = { statique: 'Statique', dynamique: 'Mobilité', activation: 'Activation' };
