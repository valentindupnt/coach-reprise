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
