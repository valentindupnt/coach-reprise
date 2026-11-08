import { localDay } from './plan';

/** Lundi de la semaine de `d`, à minuit (heure locale). */
function weekStart(d: Date): Date {
  const x = new Date(d.getFullYear(), d.getMonth(), d.getDate());
  x.setDate(x.getDate() - ((x.getDay() + 6) % 7));
  return x;
}

const weekKey = (d: Date) => localDay(weekStart(d));

export interface Streak {
  /** Séances faites cette semaine (lundi à dimanche). */
  thisWeek: number;
  /** Semaines de suite avec au moins une séance. La semaine en cours compte dès qu'elle a une séance ; sinon on part de la précédente. */
  weeks: number;
}

export function sessionStats(doneAt: string[], now = new Date()): Streak {
  const perWeek = new Map<string, number>();
  for (const iso of doneAt) {
    const k = weekKey(new Date(iso));
    perWeek.set(k, (perWeek.get(k) ?? 0) + 1);
  }
  const current = weekStart(now);
  const thisWeek = perWeek.get(localDay(current)) ?? 0;
  const cursor = new Date(current);
  if (thisWeek === 0) cursor.setDate(cursor.getDate() - 7); // semaine en cours pas encore commencée : on ne la pénalise pas
  let weeks = 0;
  while ((perWeek.get(localDay(cursor)) ?? 0) > 0) {
    weeks++;
    cursor.setDate(cursor.getDate() - 7);
  }
  return { thisWeek, weeks };
}

/** Jours de suite avec au moins une séance. Aujourd'hui compte s'il y en a une ; sinon on part d'hier. */
export function dayStreak(doneAt: string[], now = new Date()): number {
  const days = new Set(doneAt.map((iso) => localDay(new Date(iso))));
  const cursor = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  if (!days.has(localDay(cursor))) cursor.setDate(cursor.getDate() - 1);
  let n = 0;
  while (days.has(localDay(cursor))) {
    n++;
    cursor.setDate(cursor.getDate() - 1);
  }
  return n;
}

/** Calories estimées : MET moyen de 3,5 × poids (kg, 70 par défaut) × durée (h). Valeur indicative. */
export function estimateKcal(workouts: { duration_min: number | null }[], weightKg: number | null): number {
  const w = weightKg && weightKg > 30 ? weightKg : 70;
  const minutes = workouts.reduce((a, x) => a + (x.duration_min ?? 0), 0);
  return Math.round((3.5 * w * minutes) / 60);
}
