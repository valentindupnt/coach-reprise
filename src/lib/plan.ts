import type { SessionKey, ProgramSessionKey, ProgramItem, Level } from './types';

export const SESSION_META: Record<SessionKey, { title: string; subtitle: string; tone: 'sage' | 'rose' | 'sand' }> = {
  A: { title: 'Renforcement A', subtitle: 'Élastiques et gainage', tone: 'sage' },
  B: { title: 'Renforcement B', subtitle: 'Jambes et chaîne arrière', tone: 'sage' },
  M: { title: 'Mobilité et souplesse', subtitle: 'Séance douce complète', tone: 'rose' },
  C: { title: 'Cardio doux', subtitle: 'Marche, vélo ou natation tranquille', tone: 'sand' },
};

export const DAY_NAMES = ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam'];
export const DAY_NAMES_LONG = ['dimanche', 'lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi'];

export interface DayPlan {
  session: SessionKey;
  title: string;
  detail: string;
  minutes: string;
}

/** Semaine type : lundi A, mardi cardio, mercredi B, jeudi mobilité, vendredi A ou B, samedi cardio, dimanche léger. */
export function planForDate(d: Date, week: number): DayPlan {
  const day = d.getDay();
  switch (day) {
    case 1:
      return { session: 'A', title: 'Renforcement A', detail: 'Élastiques et gainage', minutes: '30 min' };
    case 2:
      return { session: 'C', title: 'Marche douce', detail: 'Puis 5 min de mobilité', minutes: '30 min' };
    case 3:
      return { session: 'B', title: 'Renforcement B', detail: 'Jambes et chaîne arrière', minutes: '30 min' };
    case 4:
      return { session: 'M', title: 'Mobilité et souplesse', detail: 'Séance douce complète', minutes: '30 min' };
    case 5: {
      const s: SessionKey = week % 2 === 1 ? 'A' : 'B';
      return { session: s, title: `Renforcement ${s}`, detail: 'On alterne A et B chaque semaine', minutes: '30 min' };
    }
    case 6:
      return { session: 'C', title: 'Cardio doux', detail: 'Marche rapide, vélo ou natation', minutes: '30 min' };
    default:
      return { session: 'C', title: 'Marche et étirements', detail: 'Ou repos : c\'est aussi le plan', minutes: '20 à 30 min' };
  }
}

/** Date locale AAAA-MM-JJ (pas d'UTC : on raisonne en jours de l'utilisatrice). */
export function localDay(d: Date): string {
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, '0');
  const dd = String(d.getDate()).padStart(2, '0');
  return `${y}-${m}-${dd}`;
}

export function parseLocalDay(s: string): Date {
  const [y, m, d] = s.slice(0, 10).split('-').map(Number);
  return new Date(y, (m || 1) - 1, d || 1);
}

/** Numéro de semaine du programme (1 = première semaine). */
export function programWeek(startDate: string, now = new Date()): number {
  const start = parseLocalDay(startDate);
  const today = parseLocalDay(localDay(now));
  const days = Math.round((today.getTime() - start.getTime()) / 86_400_000);
  return Math.max(1, Math.floor(days / 7) + 1);
}

export interface Phase {
  name: string;
  detail: string;
  rounds: number;
}

/** Progression sur 8 semaines, puis maintien. Semaine 4 allégée. */
export function phaseForWeek(week: number): Phase {
  if (week <= 2) return { name: 'Apprendre le geste', detail: 'Élastique très léger, 2 tours', rounds: 2 };
  if (week === 3) return { name: 'Construire le volume', detail: '3 tours', rounds: 3 };
  if (week === 4) return { name: 'Semaine allégée', detail: '2 tours pour récupérer', rounds: 2 };
  if (week <= 6) return { name: 'Gagner en endurance', detail: 'Élastique moyen, tempo lent', rounds: 3 };
  if (week <= 8) return { name: 'Consolider', detail: 'Plus ferme, seulement si tout est stable', rounds: 3 };
  return { name: 'Entretien', detail: 'On garde le rythme, ton coach ajuste', rounds: 3 };
}

export const PHASES = [
  { weeks: '1-2', name: 'Apprendre le geste', detail: 'Élastique très léger, 2 tours' },
  { weeks: '3-4', name: 'Construire le volume', detail: '3 tours, semaine 4 allégée' },
  { weeks: '5-6', name: 'Gagner en endurance', detail: 'Élastique moyen, tempo lent' },
  { weeks: '7-8', name: 'Consolider', detail: 'Plus ferme, seulement si tout est stable' },
];

export const WORK_SECONDS = 45;
export const REST_SECONDS = 30;
export const TRANSITION_SECONDS = 15;

export function currentLevel(item: ProgramItem): Level {
  const lv = item.exercise.levels;
  return lv[Math.min(Math.max(item.level, 1), lv.length) - 1] ?? { label: '' };
}

export function itemsForSession(program: ProgramItem[], s: ProgramSessionKey): ProgramItem[] {
  return program.filter((p) => p.session_key === s).sort((a, b) => a.position - b.position);
}

/** Étapes du lecteur de séance. */
export interface Step {
  kind: 'work' | 'rest';
  item: ProgramItem;
  round: number;
  rounds: number;
  index: number; // position de l'exercice dans la séance
  total: number;
  seconds: number;
}

export function buildSteps(items: ProgramItem[], session: ProgramSessionKey, rounds: number): Step[] {
  const steps: Step[] = [];
  const isCircuit = session === 'A' || session === 'B';
  const r = isCircuit ? rounds : 1;
  for (let round = 1; round <= r; round++) {
    items.forEach((item, index) => {
      const lv = currentLevel(item);
      const work = lv.seconds ?? WORK_SECONDS;
      steps.push({ kind: 'work', item, round, rounds: r, index, total: items.length, seconds: work });
      const last = round === r && index === items.length - 1;
      if (!last) {
        steps.push({
          kind: 'rest',
          item,
          round,
          rounds: r,
          index,
          total: items.length,
          seconds: isCircuit ? REST_SECONDS : TRANSITION_SECONDS,
        });
      }
    });
  }
  return steps;
}

export function formatSeconds(s: number): string {
  const m = Math.floor(s / 60);
  const r = s % 60;
  return m > 0 ? `${m}:${String(r).padStart(2, '0')}` : `${r}`;
}

export function totalMinutes(steps: Step[]): number {
  return Math.max(1, Math.round(steps.reduce((acc, s) => acc + s.seconds, 0) / 60));
}
