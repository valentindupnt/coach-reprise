import type { Exercise, ExerciseKind, ProgramItem, SwapOption } from './types';

export const KIND_LABEL: Record<ExerciseKind, string> = {
  force: 'Renforcement',
  gainage: 'Gainage',
  mobilite: 'Mobilité',
  etirement: 'Étirement',
  respiration: 'Respiration',
};

export const ZONE_LABEL: Record<string, string> = {
  dos: 'Dos',
  epaules: 'Épaules',
  bras: 'Bras',
  abdos: 'Abdos profonds',
  obliques: 'Obliques',
  lombaires: 'Lombaires',
  fessiers: 'Fessiers',
  cuisses: 'Cuisses',
  ischios: 'Ischio-jambiers',
  mollets: 'Mollets',
  hanches: 'Hanches',
  thorax: 'Haut du dos',
  pectoraux: 'Pectoraux',
  cou: 'Cou',
  respiration: 'Respiration',
};

export const EQUIPMENT_LABEL: Record<string, string> = {
  aucun: 'Sans matériel',
  elastique: 'Élastique',
  'mini-band': 'Mini-band',
  chaise: 'Chaise',
  mur: 'Mur',
  serviette: 'Serviette',
  coussin: 'Coussin',
};

export const INTENSITY_LABEL: Record<number, string> = {
  1: 'Très léger',
  2: 'Léger',
  3: 'Modéré',
  4: 'Soutenu',
  5: 'Intense',
};

export const WHY_LABEL = {
  variante: 'Variante du même exercice',
  autre_zone: 'Autre zone, même intensité',
  proche: 'Intensité proche',
} as const;

export const label = (map: Record<string, string>, key: string) => map[key] ?? key;

export interface LibraryFilter {
  text: string;
  kind: ExerciseKind | '';
  zone: string;
  equipment: string;
}

export const EMPTY_FILTER: LibraryFilter = { text: '', kind: '', zone: '', equipment: '' };

const norm = (s: string) => s.normalize('NFD').replace(/[̀-ͯ]/g, '').toLowerCase();

export function filterExercises<T extends Exercise>(list: T[], f: LibraryFilter): T[] {
  const q = norm(f.text.trim());
  return list.filter(
    (e) =>
      (!f.kind || e.kind === f.kind) &&
      (!f.zone || e.zones.includes(f.zone)) &&
      (!f.equipment || e.equipment.includes(f.equipment)) &&
      (!q || norm(e.name).includes(q) || e.zones.some((z) => norm(label(ZONE_LABEL, z)).includes(q))),
  );
}

/** Valeurs présentes dans la bibliothèque, pour construire les filtres. */
export function facets(list: Exercise[]) {
  const zones = new Set<string>();
  const equipment = new Set<string>();
  const kinds = new Set<ExerciseKind>();
  for (const e of list) {
    e.zones.forEach((z) => zones.add(z));
    e.equipment.forEach((q) => equipment.add(q));
    kinds.add(e.kind);
  }
  return {
    zones: [...zones].sort((a, b) => label(ZONE_LABEL, a).localeCompare(label(ZONE_LABEL, b), 'fr')),
    equipment: [...equipment].sort((a, b) => label(EQUIPMENT_LABEL, a).localeCompare(label(EQUIPMENT_LABEL, b), 'fr')),
    kinds: [...kinds],
  };
}

/** Exercices de la même famille (variantes). */
export function variantsOf<T extends Exercise>(list: T[], e: Exercise): T[] {
  return e.family ? list.filter((x) => x.id !== e.id && x.family === e.family) : [];
}

/**
 * Même logique que la base (athlete_swap_options), utilisée hors ligne : validés, même type,
 * intensité voisine (± 1), pas déjà dans la séance. Variante d'abord, puis autre zone, puis le reste.
 */
export function suggestSwaps(
  library: Exercise[],
  current: Exercise,
  sessionItems: ProgramItem[],
  avoid: string[] = [],
  limit = 2,
): SwapOption[] {
  const inSession = new Set(sessionItems.map((i) => i.exercise.id));
  const pool = library
    .filter(
      (e) =>
        e.id !== current.id &&
        e.kind === current.kind &&
        Math.abs(e.intensity - current.intensity) <= 1 &&
        !inSession.has(e.id) &&
        !avoid.includes(e.id),
    )
    .sort((a, b) => Math.abs(a.intensity - current.intensity) - Math.abs(b.intensity - current.intensity) || a.id.localeCompare(b.id));

  const out: SwapOption[] = [];
  const take = (e: Exercise | undefined, why: SwapOption['why']) => {
    if (e && out.length < limit && !out.some((o) => o.exercise.id === e.id)) out.push({ why, exercise: e });
  };
  take(pool.find((e) => current.family && e.family === current.family), 'variante');
  take(pool.find((e) => !e.zones.some((z) => current.zones.includes(z))), 'autre_zone');
  pool.forEach((e) => take(e, 'proche'));
  return out;
}
