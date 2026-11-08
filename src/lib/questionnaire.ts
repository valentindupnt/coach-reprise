// NOMA : questionnaire de départ (8 questions). Contenu identique pour tous.

export interface RefExercise {
  id: string;
  name: string;
  hint: string;
  unit: 'reps' | 's' | 'kg';
  start: number;
  step: number;
}

/** Repères suggérés : maximum d'affilée (reps ou secondes) ou charge soulevée 10 fois (kg). */
export const REFERENCES: RefExercise[] = [
  { id: 'pompes', name: 'Pompes', hint: 'Poids du corps', unit: 'reps', start: 10, step: 1 },
  { id: 'gainage', name: 'Gainage planche', hint: 'Temps tenu', unit: 's', start: 30, step: 5 },
  { id: 'crunchs', name: 'Crunchs', hint: 'Poids du corps', unit: 'reps', start: 15, step: 1 },
  { id: 'tractions', name: 'Tractions', hint: 'Poids du corps', unit: 'reps', start: 3, step: 1 },
  { id: 'developpe_couche', name: 'Développé couché', hint: 'Charge soulevée 10 fois', unit: 'kg', start: 40, step: 2.5 },
  { id: 'rowing', name: 'Rowing', hint: 'Charge soulevée 10 fois', unit: 'kg', start: 30, step: 2.5 },
  { id: 'developpe_epaules', name: 'Développé épaules', hint: 'Charge soulevée 10 fois', unit: 'kg', start: 20, step: 2.5 },
  { id: 'squat', name: 'Squat', hint: 'Charge soulevée 10 fois', unit: 'kg', start: 40, step: 2.5 },
  { id: 'hip_thrust', name: 'Hip thrust', hint: 'Charge soulevée 10 fois', unit: 'kg', start: 40, step: 2.5 },
  { id: 'souleve_jambes_tendues', name: 'Soulevé de terre jambes tendues', hint: 'Charge soulevée 10 fois', unit: 'kg', start: 40, step: 2.5 },
];

export const UNIT_LABEL: Record<RefExercise['unit'], string> = { reps: 'reps', s: 's', kg: 'kg' };

export const LEVELS = [
  { id: 'debutant', label: 'Débutant' },
  { id: 'intermediaire', label: 'Intermédiaire' },
  { id: 'confirme', label: 'Confirmé' },
];
export const GOALS = [
  { id: 'tonifier', label: 'Tonifier et se sentir bien' },
  { id: 'fessiers', label: 'Fessiers et bas du corps' },
  { id: 'muscu_complete', label: 'Muscu complète' },
  { id: 'complement_sport', label: 'Compléter le vélo ou la course' },
];
export const DAYS = [2, 3, 4, 5];
export const MINUTES = [
  { id: 10, label: 'Express, 10 min' },
  { id: 30, label: '30 min' },
  { id: 50, label: '50 min' },
];
export const PLACES = [
  { id: 'maison_sans', label: 'À la maison, sans matériel' },
  { id: 'maison_halteres', label: 'À la maison, avec haltères' },
  { id: 'salle', label: 'En salle' },
];
export const AVOID_ZONES = [
  { id: 'dos', label: 'Dos' },
  { id: 'epaules', label: 'Épaules' },
  { id: 'hanches', label: 'Hanches' },
  { id: 'genoux', label: 'Genoux' },
  { id: 'poignets', label: 'Poignets' },
];

export interface Answers {
  level?: string;
  refs?: Record<string, number>;
  goal?: string;
  days?: number;
  minutes?: number;
  place?: string;
  avoid?: string[];
  height_cm?: number;
  weight_kg?: number;
  birth_year?: number;
}

export const TOTAL_STEPS = 8;
