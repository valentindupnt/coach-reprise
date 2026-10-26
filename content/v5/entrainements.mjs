// Blocs 2.3 à 2.5 bis : entraînements et programmes.
// Écriture compacte d'un exercice dans un entraînement :
//   'squat'        niveau de l'entraînement
//   'squat@2'      niveau 2 de l'exercice
//   'squat@2=40'   niveau 2, valeur imposée (secondes ou répétitions selon le mode de l'exercice)
//   'squat*3'      3 tours pour cet exercice dans le corps de séance (sinon : tours de l'entraînement)
// target : durée visée en minutes, vérifiée à ± 2 min par scripts/build-content.mjs.
// Tous les programmes, démarrages rapides et séances express sont SANS matériel et SANS saut,
// sauf les démarrages rapides avancés « corps entier » et « jambes » (sauts, remplacés si besoin).

function parse(s) {
  const m = /^([a-z0-9_]+)(?:@(\d+))?(?:=(\d+))?(?:\*(\d+))?$/.exec(s);
  if (!m) throw new Error(`entrée mal formée : ${s}`);
  return { ex: m[1], level: m[2] ? +m[2] : undefined, value: m[3] ? +m[3] : undefined, sets: m[4] ? +m[4] : undefined };
}
const T = (o) => ({
  rounds: 2, rest: 15, level: 1, ...o,
  warmup: (o.warmup ?? []).map(parse), main: o.main.map(parse), cooldown: (o.cooldown ?? []).map(parse),
});

// ------------------------------------------------------------------ blocs réutilisés
const ECHAUFFEMENT = ['marche_genoux_hauts@1=40', 'cercles_bras', 'cercles_hanches', 'rotations_buste'];
const ECHAUFFEMENT_LONG = ['marche_genoux_hauts@2=45', 'cercles_bras', 'cercles_hanches', 'rotations_buste', 'plus_grand_etirement@1=40'];
const ECHAUFFEMENT_BAS = ['marche_genoux_hauts@1=40', 'cercles_hanches', 'balancier_jambes@1=30', 'squat@1=8'];

// =================================================================== PROGRAMMES (28 jours)
// Semaine type : J1 A, J2 B, J3 mobilité, J4 C, J5 A, J6 B, J7 récupération.
// Durée : semaine 1 vers 10 min, semaine 2 vers 15, semaine 3 vers 20, semaine 4 vers 25.
// Niveaux d'exercice : 1 en semaines 1 et 2, 2 en semaine 3, 2 ou 3 en semaine 4.
// Mobilité et récupération : communes aux trois programmes.

const COMMUNS = [
  T({ id: 'prog_mobilite_s1', kind: 'programme', title: 'Mobilité douce', target: 6, rest: 10, rounds: 1,
      areas: ['corps_entier'], discipline: 'etirement',
      description: 'Une séance courte pour délier le dos, les hanches et les épaules entre deux renforcements.',
      main: ['chat_vache@1', 'cercles_hanches', 'livre_ouvert@1', 'plus_grand_etirement@1', 'enfant@2'] }),
  T({ id: 'prog_mobilite_s2', kind: 'programme', title: 'Mobilité du dos et des hanches', target: 7, rest: 10, rounds: 1,
      areas: ['corps_entier'], discipline: 'etirement',
      description: 'Mobilité active pour récupérer et bouger mieux.',
      main: ['chat_vache@2', 'cercles_bras', 'rotations_buste', 'plus_grand_etirement@2', 'fente_basse@1', 'enfant@3'] }),
  T({ id: 'prog_mobilite_s3', kind: 'programme', title: 'Mobilité et salutation au soleil', target: 8, rest: 10, rounds: 1,
      areas: ['corps_entier'], discipline: 'yoga',
      description: 'Mobilité puis deux salutations au soleil en douceur.',
      main: ['chat_vache@2', 'cercles_hanches', 'salutation_soleil@1', 'plus_grand_etirement@2', 'sphinx@1', 'torsion_couchee@1'] }),
  T({ id: 'prog_mobilite_s4', kind: 'programme', title: 'Mobilité complète', target: 9, rest: 10, rounds: 1,
      areas: ['corps_entier'], discipline: 'yoga',
      description: 'Une séance de mobilité plus longue pour finir le mois en souplesse.',
      main: ['chat_vache@3', 'cercles_bras', 'salutation_soleil@2', 'plus_grand_etirement@2', 'fente_basse@1', 'pigeon@1', 'torsion_couchee@1'] }),
  T({ id: 'prog_recup_s1', kind: 'programme', title: 'Récupération : étirements', target: 7, rest: 10, rounds: 1,
      areas: ['corps_entier'], discipline: 'etirement',
      description: 'Étirements doux de tout le corps pour finir la semaine.',
      main: ['genoux_poitrine@1', 'fessiers_4@1', 'ischios@1', 'torsion_couchee@1', 'enfant@2', 'respiration@1'] }),
  T({ id: 'prog_recup_s2', kind: 'programme', title: 'Récupération : yoga doux', target: 9, rest: 10, rounds: 1,
      areas: ['corps_entier'], discipline: 'yoga',
      description: 'Postures de yoga au sol et respiration lente.',
      main: ['chat_vache@2', 'sphinx@2', 'enfant@3', 'papillon@2', 'torsion_couchee@1', 'coherence_cardiaque@1'] }),
  T({ id: 'prog_recup_s3', kind: 'programme', title: 'Récupération : hanches et dos', target: 9, rest: 10, rounds: 1,
      areas: ['corps_entier'], discipline: 'yoga',
      description: 'Ouverture des hanches, détente du dos et quelques minutes de calme.',
      main: ['fente_basse@1', 'pigeon@1', 'papillon@2', 'bebe_heureux@2', 'torsion_couchee@1', 'genoux_poitrine@2', 'coherence_cardiaque@1=120'] }),
  T({ id: 'prog_recup_s4', kind: 'programme', title: 'Récupération : bilan du mois', target: 11, rest: 10, rounds: 1,
      areas: ['corps_entier'], discipline: 'yoga',
      description: 'Étirements et scan corporel pour savourer le chemin parcouru.',
      main: ['chat_vache@2', 'pince_assise@2', 'papillon@2', 'torsion_couchee@1', 'scan_corporel@1'] }),
];

// ------------------------------------------------------------------ Remise en forme
const REMISE = [
  // Semaine 1 (vers 10 min)
  T({ id: 'rf_s1_a', kind: 'programme', title: 'Bas du corps et gainage', target: 10, areas: ['jambes', 'fessiers', 'abdos'],
      warmup: ECHAUFFEMENT, main: ['squat@1', 'pont@1', 'dead_bug@1', 'planche@1'], cooldown: ['ischios@1'] }),
  T({ id: 'rf_s1_b', kind: 'programme', title: 'Haut du corps et dos', target: 10, areas: ['bras', 'epaules', 'dos'],
      warmup: ECHAUFFEMENT, main: ['pompe_genoux@1', 'superman@1', 'bird_dog@3', 'ours_statique@1'], cooldown: ['enfant@2'] }),
  T({ id: 'rf_s1_c', kind: 'programme', title: 'Cardio doux', target: 10, areas: ['corps_entier'], discipline: 'cardio',
      warmup: ['cercles_bras', 'cercles_hanches'], main: ['marche_genoux_hauts@1', 'step_jacks@1', 'squat_coup_de_pied@1', 'boxe_ombre@1'],
      cooldown: ['chien_tete_bas@1'] }),
  // Semaine 2 (vers 15 min)
  T({ id: 'rf_s2_a', kind: 'programme', title: 'Bas du corps et gainage', target: 15, areas: ['jambes', 'fessiers', 'abdos'],
      warmup: ECHAUFFEMENT, main: ['squat@2', 'fente_arriere@1', 'pont@2', 'dead_bug@2', 'planche@2'],
      cooldown: ['ischios@1', 'flechisseurs@1'] }),
  T({ id: 'rf_s2_b', kind: 'programme', title: 'Haut du corps et dos', target: 15, areas: ['bras', 'epaules', 'dos'],
      warmup: ECHAUFFEMENT, main: ['pompe_genoux@2', 'superman@2', 'planche_epaules@1', 'ytw@1', 'bird_dog@3', 'planche_inverse@1'],
      cooldown: ['enfant@2', 'epaule_bras_croise@1'] }),
  T({ id: 'rf_s2_c', kind: 'programme', title: 'Cardio et renforcement', target: 15, areas: ['corps_entier'], discipline: 'cardio',
      warmup: ['marche_genoux_hauts@1', 'cercles_bras', 'cercles_hanches'],
      main: ['step_jacks@2', 'squat@1', 'boxe_ombre@2', 'mountain_climbers_lents@2', 'patineur_sans_saut@1', 'squat_coup_de_pied@1'],
      cooldown: ['quadriceps_debout@1', 'chien_tete_bas@1'] }),
  // Semaine 3 (vers 20 min)
  T({ id: 'rf_s3_a', kind: 'programme', title: 'Bas du corps et gainage', target: 20, rounds: 3, areas: ['jambes', 'fessiers', 'abdos'],
      warmup: ECHAUFFEMENT_LONG, main: ['squat@2', 'fente_arriere@2', 'pont@3', 'dead_bug@2', 'planche@2'],
      cooldown: ['ischios@2', 'flechisseurs@1'] }),
  T({ id: 'rf_s3_b', kind: 'programme', title: 'Haut du corps et dos', target: 20, rounds: 3, areas: ['bras', 'epaules', 'dos'],
      warmup: ECHAUFFEMENT_LONG, main: ['pompe_genoux@3', 'superman@2', 'planche_epaules@2', 'ytw@2', 'planche_inverse@1'],
      cooldown: ['enfant@2', 'epaule_bras_croise@2'] }),
  T({ id: 'rf_s3_c', kind: 'programme', title: 'Cardio et renforcement', target: 20, rounds: 3, areas: ['corps_entier'], discipline: 'cardio',
      warmup: ['marche_genoux_hauts@2', 'cercles_bras', 'cercles_hanches', 'rotations_buste'],
      main: ['step_jacks@3', 'squat@2', 'boxe_ombre@2', 'mountain_climbers_lents@2', 'burpee_sans_saut@1', 'squat_coup_de_pied@2'],
      cooldown: ['quadriceps_debout@2', 'chien_tete_bas@1'] }),
  // Semaine 4 (vers 25 min)
  T({ id: 'rf_s4_a', kind: 'programme', title: 'Bas du corps et gainage', target: 25, rounds: 3, level: 2, areas: ['jambes', 'fessiers', 'abdos'],
      warmup: ECHAUFFEMENT_LONG, main: ['squat@3', 'fente_arriere@2', 'pont@3', 'fente_laterale@2', 'dead_bug@3', 'planche@3'],
      cooldown: ['ischios@2', 'flechisseurs@2', 'fessiers_4@1'] }),
  T({ id: 'rf_s4_b', kind: 'programme', title: 'Haut du corps et dos', target: 25, rounds: 3, level: 2, areas: ['bras', 'epaules', 'dos'],
      warmup: ECHAUFFEMENT_LONG, main: ['pompe_genoux@3', 'superman@3', 'planche_epaules@2', 'ytw@3', 'planche_inverse@2', 'chenille@1', 'boxe_ombre@3', 'ours_statique@3'],
      cooldown: ['enfant@3', 'epaule_bras_croise@2', 'triceps_etirement@1'] }),
  T({ id: 'rf_s4_c', kind: 'programme', title: 'Cardio et renforcement', target: 25, rounds: 3, level: 2, areas: ['corps_entier'], discipline: 'cardio',
      warmup: ['marche_genoux_hauts@2', 'cercles_bras', 'cercles_hanches', 'rotations_buste', 'plus_grand_etirement@1=40'],
      main: ['step_jacks@3', 'squat@3', 'boxe_ombre@3', 'mountain_climbers_lents@3', 'burpee_sans_saut@2', 'patineur_sans_saut@2'],
      cooldown: ['quadriceps_debout@2', 'chien_tete_bas@2', 'etirement_lateral@1'] }),
];

// ------------------------------------------------------------------ Hanches et fessiers
const FESSIERS = [
  T({ id: 'hf_s1_a', kind: 'programme', title: 'Fessiers : les bases', target: 10, areas: ['fessiers'],
      warmup: ECHAUFFEMENT_BAS, main: ['pont@1', 'clamshell@1', 'ruade@1', 'abduction_couchee@1'], cooldown: ['fessiers_4@1'] }),
  T({ id: 'hf_s1_b', kind: 'programme', title: 'Jambes et fessiers', target: 10, areas: ['jambes', 'fessiers'],
      warmup: ECHAUFFEMENT_BAS, main: ['squat_sumo@1', 'fente_arriere@1', 'bouche_incendie@1', 'releve_mollets@1'], cooldown: ['quadriceps_debout@1'] }),
  T({ id: 'hf_s1_c', kind: 'programme', title: 'Fessiers et abdos', target: 10, areas: ['fessiers', 'abdos'],
      warmup: ['marche_genoux_hauts@1=40', 'cercles_hanches', 'rotations_buste'],
      main: ['pont_marche@1', 'dead_bug@1', 'adducteurs_couche@1', 'crunch_inverse@1'], cooldown: ['papillon@1'] }),

  T({ id: 'hf_s2_a', kind: 'programme', title: 'Fessiers : volume', target: 15, areas: ['fessiers'],
      warmup: ECHAUFFEMENT_BAS, main: ['pont@2', 'hip_thrust@1', 'clamshell@2', 'ruade@2', 'abduction_couchee@2'],
      cooldown: ['fessiers_4@1', 'flechisseurs@1'] }),
  T({ id: 'hf_s2_b', kind: 'programme', title: 'Jambes et fessiers', target: 15, areas: ['jambes', 'fessiers'],
      warmup: ECHAUFFEMENT_BAS, main: ['squat_sumo@1', 'fente_arriere@2', 'charniere_hanche@1', 'bouche_incendie@2', 'releve_mollets@2'],
      cooldown: ['quadriceps_debout@1', 'ischios@1'] }),
  T({ id: 'hf_s2_c', kind: 'programme', title: 'Fessiers, abdos et cardio', target: 15, areas: ['fessiers', 'abdos'],
      warmup: ['marche_genoux_hauts@1=40', 'cercles_hanches', 'rotations_buste'],
      main: ['pont_marche@2', 'patineur_sans_saut@1', 'dead_bug@2', 'adducteurs_couche@2', 'squat_coup_de_pied@1'],
      cooldown: ['papillon@2', 'fessiers_4@1'] }),

  T({ id: 'hf_s3_a', kind: 'programme', title: 'Fessiers : force', target: 20, rounds: 3, areas: ['fessiers'],
      warmup: ECHAUFFEMENT_BAS, main: ['hip_thrust@2', 'pont_unilateral@1', 'clamshell@3', 'ruade@3', 'abduction_couchee@3'],
      cooldown: ['fessiers_4@2', 'flechisseurs@2'] }),
  T({ id: 'hf_s3_b', kind: 'programme', title: 'Jambes et fessiers', target: 20, rounds: 3, areas: ['jambes', 'fessiers'],
      warmup: ECHAUFFEMENT_BAS, main: ['squat_sumo@2', 'fente_laterale@2', 'charniere_hanche@2', 'fente_arriere@2', 'releve_mollets@2'],
      cooldown: ['quadriceps_debout@2', 'ischios@2'] }),
  T({ id: 'hf_s3_c', kind: 'programme', title: 'Fessiers, abdos et cardio', target: 20, rounds: 3, areas: ['fessiers', 'abdos'],
      warmup: ['marche_genoux_hauts@2', 'cercles_hanches', 'rotations_buste', 'balancier_jambes@1=30'],
      main: ['pont_marche@2', 'patineur_sans_saut@2', 'dead_bug@2', 'bouche_incendie@2', 'squat_coup_de_pied@2'],
      cooldown: ['papillon@2', 'pigeon@1'] }),

  T({ id: 'hf_s4_a', kind: 'programme', title: 'Fessiers : force', target: 25, rounds: 3, level: 2, areas: ['fessiers'],
      warmup: ECHAUFFEMENT_BAS, main: ['hip_thrust@2', 'pont_unilateral@2', 'clamshell@3', 'ruade@3', 'abduction_couchee@3', 'bouche_incendie@2'],
      cooldown: ['fessiers_4@2', 'flechisseurs@2', 'pigeon@1'] }),
  T({ id: 'hf_s4_b', kind: 'programme', title: 'Jambes et fessiers', target: 25, rounds: 3, level: 2, areas: ['jambes', 'fessiers'],
      warmup: ECHAUFFEMENT_BAS, main: ['squat_sumo@3', 'fente_laterale@3', 'charniere_hanche@2', 'fente_arriere@3', 'chaise_yoga@2', 'releve_mollets@3', 'bouche_incendie@3'],
      cooldown: ['quadriceps_debout@2', 'ischios@2', 'chien_tete_bas@1'] }),
  T({ id: 'hf_s4_c', kind: 'programme', title: 'Fessiers, abdos et cardio', target: 25, rounds: 3, level: 2, areas: ['fessiers', 'abdos'],
      warmup: ['marche_genoux_hauts@2', 'cercles_hanches', 'rotations_buste', 'balancier_jambes@2'],
      main: ['pont_marche@3', 'patineur_sans_saut@2', 'dead_bug@3', 'bouche_incendie@3', 'squat_coup_de_pied@2', 'adducteurs_couche@2', 'clamshell@3'],
      cooldown: ['papillon@3', 'pigeon@1', 'bebe_heureux@1'] }),
];

// ------------------------------------------------------------------ Gainage et calisthénie
const GAINAGE = [
  T({ id: 'gc_s1_a', kind: 'programme', title: 'Gainage : les bases', target: 10, areas: ['abdos'], discipline: 'gainage',
      warmup: ECHAUFFEMENT, main: ['dead_bug@1', 'planche@1', 'bird_dog@3', 'planche_laterale@1'], cooldown: ['cobra@1'] }),
  T({ id: 'gc_s1_b', kind: 'programme', title: 'Poussée et tirage au poids du corps', target: 10, areas: ['bras', 'dos', 'epaules'], discipline: 'calisthenie',
      warmup: ECHAUFFEMENT, main: ['pompe_genoux@1', 'superman@1', 'ours_statique@1', 'squat@1'], cooldown: ['enfant@2'] }),
  T({ id: 'gc_s1_c', kind: 'programme', title: 'Abdos et rotation', target: 10, areas: ['abdos'], discipline: 'gainage',
      warmup: ['marche_genoux_hauts@1=40', 'rotations_buste', 'cercles_hanches'],
      main: ['crunch@1', 'toucher_talons@1', 'crunch_inverse@1', 'mountain_climbers_lents@1'], cooldown: ['torsion_couchee@1'] }),

  T({ id: 'gc_s2_a', kind: 'programme', title: 'Gainage : anti-extension', target: 15, areas: ['abdos'], discipline: 'gainage',
      warmup: ECHAUFFEMENT, main: ['dead_bug@2', 'planche@2', 'hollow@1', 'planche_laterale@2', 'ours_statique@2', 'crunch_inverse@2'],
      cooldown: ['cobra@2', 'enfant@2'] }),
  T({ id: 'gc_s2_b', kind: 'programme', title: 'Poussée et tirage au poids du corps', target: 15, areas: ['bras', 'dos', 'epaules'], discipline: 'calisthenie',
      warmup: ECHAUFFEMENT, main: ['pompe_genoux@2', 'superman@2', 'planche_inverse@1', 'ytw@1', 'squat@2', 'chenille@1'],
      cooldown: ['enfant@2', 'epaule_bras_croise@1'] }),
  T({ id: 'gc_s2_c', kind: 'programme', title: 'Abdos et rotation', target: 15, areas: ['abdos'], discipline: 'gainage',
      warmup: ['marche_genoux_hauts@1=40', 'rotations_buste', 'cercles_hanches'],
      main: ['crunch_velo@1', 'rotation_russe@1', 'crunch_inverse@2', 'planche_epaules@1', 'mountain_climbers_lents@2'],
      cooldown: ['torsion_couchee@1', 'cobra@1'] }),

  T({ id: 'gc_s3_a', kind: 'programme', title: 'Gainage : anti-extension', target: 20, rounds: 3, areas: ['abdos'], discipline: 'gainage',
      warmup: ECHAUFFEMENT_LONG, main: ['dead_bug@3', 'planche@3', 'hollow@2', 'planche_laterale@3', 'ciseaux@1', 'crunch_inverse@3', 'planche_epaules@2'],
      cooldown: ['cobra@2', 'enfant@2'] }),
  T({ id: 'gc_s3_b', kind: 'programme', title: 'Poussée et tirage au poids du corps', target: 20, rounds: 3, areas: ['bras', 'dos', 'epaules'], discipline: 'calisthenie',
      warmup: ECHAUFFEMENT_LONG, main: ['pompe@1', 'superman@3', 'planche_inverse@2', 'ytw@2', 'chenille@1', 'squat@3', 'planche_epaules@2'],
      cooldown: ['enfant@3', 'triceps_etirement@1'] }),
  T({ id: 'gc_s3_c', kind: 'programme', title: 'Abdos et rotation', target: 20, rounds: 3, areas: ['abdos'], discipline: 'gainage',
      warmup: ['marche_genoux_hauts@2', 'rotations_buste', 'cercles_hanches', 'cercles_bras'],
      main: ['crunch_velo@2', 'rotation_russe@2', 'releve_jambes@1', 'planche_dynamique@1', 'mountain_climbers_lents@2'],
      cooldown: ['torsion_couchee@1', 'cobra@2'] }),

  T({ id: 'gc_s4_a', kind: 'programme', title: 'Gainage : anti-extension', target: 25, rounds: 3, level: 2, areas: ['abdos'], discipline: 'gainage',
      warmup: ECHAUFFEMENT_LONG, main: ['dead_bug@4', 'planche@4', 'hollow@2', 'planche_laterale@3', 'ciseaux@2', 'ours_statique@3', 'releve_jambes@2', 'planche_laterale_rotation@1'],
      cooldown: ['cobra@3', 'enfant@3', 'genoux_poitrine@2'] }),
  T({ id: 'gc_s4_b', kind: 'programme', title: 'Poussée et tirage au poids du corps', target: 25, rounds: 3, level: 2, areas: ['bras', 'dos', 'epaules'], discipline: 'calisthenie',
      warmup: ECHAUFFEMENT_LONG, main: ['pompe@2', 'superman@3', 'planche_inverse@2', 'pompe_pike@1', 'ytw@3', 'chenille@2', 'squat@3', 'ours_statique@3'],
      cooldown: ['enfant@3', 'triceps_etirement@2', 'epaule_bras_croise@2'] }),
  T({ id: 'gc_s4_c', kind: 'programme', title: 'Abdos et rotation', target: 25, rounds: 3, level: 2, areas: ['abdos'], discipline: 'gainage',
      warmup: ['marche_genoux_hauts@2', 'rotations_buste', 'cercles_hanches', 'cercles_bras', 'chat_vache@1'],
      main: ['crunch_velo@3', 'rotation_russe@3', 'releve_jambes@2', 'planche_dynamique@2', 'planche_laterale_rotation@1', 'mountain_climbers_lents@3'],
      cooldown: ['torsion_couchee@1', 'cobra@2', 'genoux_poitrine@2'] }),
];

// ------------------------------------------------------------------ assemblage des 28 jours
const semaine = (p, s) => [`${p}_s${s}_a`, `${p}_s${s}_b`, `prog_mobilite_s${s}`, `${p}_s${s}_c`, `${p}_s${s}_a`, `${p}_s${s}_b`, `prog_recup_s${s}`];
const mois = (p) => [1, 2, 3, 4].flatMap((s) => semaine(p, s));

const SOURCE_PROG = 'Composé pour l\'app (bloc 2 V5). Repères : OMS 2020 (renforcement au moins 2 jours par semaine, '
  + 'https://doi.org/10.1136/bjsports-2020-102955) ; ACSM 2026, renforcement musculaire et progression '
  + '(https://acsm.org/science-spotlight-acsm-releases-new-position-stand-on-resistance-training/).';

export const PROGRAMS = [
  { id: 'remise_en_forme', title: 'Remise en forme', level: 1, goals: ['garder_la_forme', 'perdre_du_poids', 'renforcer'],
    areas: ['corps_entier'], source: SOURCE_PROG, days: mois('rf'),
    description: '28 jours pour retrouver la forme : bas du corps, haut du corps et cardio doux en alternance, sans matériel '
      + 'et sans saut. Les séances passent de 10 à 25 minutes au fil des semaines.' },
  { id: 'hanches_fessiers', title: 'Hanches et fessiers', level: 1, goals: ['tonifier', 'renforcer'],
    areas: ['fessiers', 'jambes'], source: SOURCE_PROG, days: mois('hf'),
    description: '28 jours pour tonifier les fessiers et les jambes : ponts, fentes, travail de hanche et un peu de cardio, '
      + 'sans matériel et sans saut. De 10 à 25 minutes par séance.' },
  { id: 'gainage_calisthenie', title: 'Gainage et calisthénie', level: 1, goals: ['renforcer', 'tonifier'],
    areas: ['abdos', 'bras', 'dos'], source: SOURCE_PROG, days: mois('gc'),
    description: '28 jours pour un tronc solide et les bases de la calisthénie : planches, dead bug, pompes et travail du dos '
      + 'au poids du corps. De 10 à 25 minutes par séance.' },
];

// =================================================================== DÉMARRAGE RAPIDE (2.4)
// 6 zones x 3 niveaux, sans matériel. Débutant vers 8 min, intermédiaire vers 13, avancé vers 18.
const R = (zone, titre, lv, o) => T({ id: `rapide_${zone}_${lv}`, kind: 'rapide', level: lv,
  title: `${titre}, ${['débutant', 'intermédiaire', 'avancé'][lv - 1]}`, areas: [zone], ...o });

const RAPIDES = [
  R('corps_entier', 'Corps entier', 1, { target: 8, warmup: ['marche_genoux_hauts@1=30', 'cercles_bras'],
    main: ['squat@1', 'pompe_genoux@1', 'pont@1', 'planche@1'], cooldown: ['enfant@1'] }),
  R('corps_entier', 'Corps entier', 2, { target: 13, warmup: ECHAUFFEMENT,
    main: ['squat@2', 'pompe_genoux@3', 'fente_arriere@2', 'mountain_climbers_lents@2', 'superman@2'], cooldown: ['enfant@2', 'quadriceps_debout@1'] }),
  R('corps_entier', 'Corps entier', 3, { target: 18, rounds: 3, warmup: ECHAUFFEMENT,
    main: ['squat_saute@2', 'pompe@2', 'fente_arriere@3', 'burpee@1', 'planche_dynamique@2', 'jumping_jacks@2'], cooldown: ['enfant@2', 'quadriceps_debout@1'] }),

  R('abdos', 'Abdos', 1, { target: 8, warmup: ['rotations_buste', 'cercles_hanches'],
    main: ['dead_bug@1', 'crunch@1', 'planche@1', 'crunch_inverse@1'], cooldown: ['cobra@1'] }),
  R('abdos', 'Abdos', 2, { target: 13, warmup: ['marche_genoux_hauts@1=40', 'rotations_buste', 'cercles_hanches'],
    main: ['crunch_velo@2', 'planche@3', 'rotation_russe@2', 'ciseaux@1', 'planche_laterale@2'], cooldown: ['cobra@2', 'torsion_couchee@1'] }),
  R('abdos', 'Abdos', 3, { target: 18, rounds: 3, warmup: ['marche_genoux_hauts@2', 'rotations_buste', 'cercles_hanches'],
    main: ['hollow@3', 'v_up@1', 'planche_dynamique@2', 'rotation_russe@3', 'releve_jambes@3', 'mountain_climbers@2'], cooldown: ['cobra@2', 'torsion_couchee@1'] }),

  R('jambes', 'Jambes', 1, { target: 8, warmup: ['marche_genoux_hauts@1=30', 'cercles_hanches'],
    main: ['squat@1', 'fente_arriere@1', 'releve_mollets@1', 'pont@1'], cooldown: ['quadriceps_debout@1'] }),
  R('jambes', 'Jambes', 2, { target: 13, warmup: ECHAUFFEMENT_BAS,
    main: ['squat_sumo@2', 'fente_laterale@2', 'charniere_hanche@2', 'pont_unilateral@1', 'releve_mollets@2'], cooldown: ['quadriceps_debout@1', 'ischios@1'] }),
  R('jambes', 'Jambes', 3, { target: 18, rounds: 3, warmup: ECHAUFFEMENT_BAS,
    main: ['squat_saute@2', 'fente_arriere@3', 'fente_laterale@3', 'pont_unilateral@2', 'patineur@2'], cooldown: ['quadriceps_debout@2', 'ischios@2'] }),

  R('bras', 'Bras', 1, { target: 8, warmup: ['cercles_bras', 'marche_genoux_hauts@1=30'],
    main: ['pompe_genoux@1', 'planche_inverse@1', 'boxe_ombre@1', 'ours_statique@1'], cooldown: ['triceps_etirement@1'] }),
  R('bras', 'Bras', 2, { target: 13, warmup: ['cercles_bras', 'marche_genoux_hauts@1=40', 'rotations_buste'],
    main: ['pompe_genoux@3', 'planche_inverse@2', 'boxe_ombre@2', 'pompe@1', 'planche_dynamique@1', 'ours_statique@2'], cooldown: ['triceps_etirement@1', 'epaule_bras_croise@1'] }),
  R('bras', 'Bras', 3, { target: 18, rounds: 3, warmup: ['cercles_bras', 'marche_genoux_hauts@2', 'rotations_buste'],
    main: ['pompe@3', 'pompe_serree@2', 'planche_inverse@3', 'pompe_pike@1', 'planche_dynamique@2', 'boxe_ombre@3'], cooldown: ['triceps_etirement@2', 'epaule_bras_croise@2'] }),

  R('epaules', 'Épaules', 1, { target: 8, warmup: ['cercles_bras', 'rotations_buste'],
    main: ['ytw@1', 'ours_statique@1', 'boxe_ombre@1', 'planche@1'], cooldown: ['epaule_bras_croise@1'] }),
  R('epaules', 'Épaules', 2, { target: 13, warmup: ['cercles_bras', 'marche_genoux_hauts@1=40', 'rotations_buste'],
    main: ['ytw@2', 'planche_epaules@2', 'pompe_genoux@2', 'boxe_ombre@2', 'ours_statique@2'], cooldown: ['epaule_bras_croise@1', 'chien_tete_bas@1'] }),
  R('epaules', 'Épaules', 3, { target: 18, rounds: 3, warmup: ['cercles_bras', 'marche_genoux_hauts@2', 'rotations_buste'],
    main: ['pompe_pike@2', 'ytw@3', 'planche_epaules@3', 'marche_ours@2', 'pompe@2', 'boxe_ombre@3'], cooldown: ['epaule_bras_croise@2', 'chien_tete_bas@2'] }),

  R('dos', 'Dos', 1, { target: 8, warmup: ['chat_vache@1', 'cercles_bras'],
    main: ['bird_dog@3', 'superman@1', 'pont@1', 'ytw@1'], cooldown: ['enfant@2'] }),
  R('dos', 'Dos', 2, { target: 13, warmup: ['chat_vache@2', 'cercles_bras', 'rotations_buste'],
    main: ['superman@2', 'ytw@2', 'bird_dog@4', 'charniere_hanche@1', 'planche_inverse@1'], cooldown: ['enfant@2', 'sphinx@1'] }),
  R('dos', 'Dos', 3, { target: 18, rounds: 3, warmup: ['chat_vache@2', 'cercles_bras', 'rotations_buste', 'plus_grand_etirement@1=40'],
    main: ['superman@3', 'ytw@3', 'planche_inverse@3', 'charniere_hanche@3', 'chenille@2', 'bird_dog@4'], cooldown: ['enfant@3', 'sphinx@2'] }),
];

// =================================================================== MOMENTS POUR SOI (2.5)
const DECOUVERTE = [
  T({ id: 'decouverte_yoga_matin', kind: 'decouverte', title: 'Yoga du matin', target: 8, rounds: 1, rest: 5,
      areas: ['corps_entier'], discipline: 'yoga',
      description: 'Une séquence douce pour réveiller le corps : salutation au soleil et postures debout.',
      main: ['montagne@1', 'chat_vache@2', 'salutation_soleil@1', 'chaise_yoga@1', 'guerrier_1@1', 'guerrier_2@1', 'triangle@1', 'arbre@1', 'enfant@2'] }),
  T({ id: 'decouverte_etirements_soir', kind: 'decouverte', title: 'Étirements du soir', target: 9, rounds: 1, rest: 5,
      areas: ['corps_entier'], discipline: 'etirement',
      description: 'Relâcher les tensions de la journée avant de dormir, tout en douceur.',
      main: ['etirement_lateral@1', 'quadriceps_debout@1', 'sphinx@1', 'genoux_poitrine@1', 'fessiers_4@1', 'ischios@1', 'torsion_couchee@1', 'papillon@1', 'respiration@1'] }),
  T({ id: 'decouverte_meditation', kind: 'decouverte', title: 'Méditation guidée', target: 7, rounds: 1, rest: 5,
      areas: [], discipline: 'meditation',
      description: 'Quelques minutes de respiration lente, puis d\'attention au souffle.',
      main: ['coherence_cardiaque@1=120', 'meditation_souffle@2'] }),
  T({ id: 'decouverte_gainage_express', kind: 'decouverte', title: 'Gainage express', target: 5, rounds: 2, rest: 10,
      areas: ['abdos'], discipline: 'gainage',
      description: 'Un gainage court et efficace, quand il ne reste que quelques minutes.',
      main: ['planche@2', 'dead_bug@2', 'planche_laterale@1', 'bird_dog@3'] }),
  T({ id: 'decouverte_detente_sommeil', kind: 'decouverte', title: 'Détente avant le sommeil', target: 12, rounds: 1, rest: 5,
      areas: [], discipline: 'meditation',
      description: 'Jambes au mur, puis relaxation progressive pour préparer le sommeil.',
      main: ['jambes_au_mur@1', 'relaxation_progressive@2', 'coherence_cardiaque@1=120'] }),
  T({ id: 'decouverte_yoga_hanches', kind: 'decouverte', title: 'Yoga des hanches', target: 9, rounds: 1, rest: 5,
      areas: ['fessiers', 'jambes'], discipline: 'yoga',
      description: 'Ouvrir les hanches après une journée assise.',
      main: ['chat_vache@1', 'fente_basse@2', 'guerrier_2@2', 'pigeon@2', 'papillon@2', 'pince_assise@2', 'bebe_heureux@2', 'torsion_couchee@1'] }),
  T({ id: 'decouverte_scan_corporel', kind: 'decouverte', title: 'Scan corporel', target: 8, rounds: 1, rest: 5,
      areas: [], discipline: 'meditation',
      description: 'Parcourir le corps de la tête aux pieds pour se poser.',
      main: ['respiration@1', 'scan_corporel@2'] }),
];

// =================================================================== SÉANCES EXPRESS (2.5 bis)
// 3 à 5 min, sans matériel, gardées sur le téléphone pour être lancées hors ligne.
const EXPRESS = [
  T({ id: 'express_reveil', kind: 'express', title: 'Réveil en 4 minutes', target: 4, rounds: 1, rest: 5,
      areas: ['corps_entier'], discipline: 'etirement', description: 'Mobilité du matin, sans quitter la chambre.',
      main: ['cercles_bras', 'rotations_buste', 'cercles_hanches', 'chat_vache@1', 'squat@1=8'] }),
  T({ id: 'express_cardio', kind: 'express', title: 'Coup de boost cardio', target: 4, rounds: 2, rest: 10,
      areas: ['corps_entier'], discipline: 'cardio', description: 'Quatre minutes pour se réchauffer, sans saut.',
      main: ['step_jacks@2=30', 'boxe_ombre@1=30', 'marche_genoux_hauts@2=30'] }),
  T({ id: 'express_abdos', kind: 'express', title: 'Abdos express', target: 5, rounds: 2, rest: 10,
      areas: ['abdos'], discipline: 'gainage', description: 'Quatre exercices de gainage enchaînés deux fois.',
      main: ['planche@2=20', 'dead_bug@1=8', 'crunch@1=12', 'planche_laterale@1=20'] }),
  T({ id: 'express_jambes', kind: 'express', title: 'Jambes express', target: 5, rounds: 2, rest: 10,
      areas: ['jambes', 'fessiers'], discipline: 'renforcement', description: 'Squats, fentes et pont : l\'essentiel des jambes.',
      main: ['squat@1=8', 'fente_arriere@1=6', 'pont@1=10', 'releve_mollets@1=10'] }),
  T({ id: 'express_pause_bureau', kind: 'express', title: 'Pause bureau', target: 4, rounds: 1, rest: 5,
      areas: ['dos', 'epaules'], discipline: 'etirement', description: 'Dénouer la nuque, les épaules et le dos entre deux réunions.',
      main: ['chin_tuck@1', 'omoplates@1', 'trapezes@1=40', 'epaule_bras_croise@1', 'etirement_lateral@1=30'] }),
  T({ id: 'express_respiration', kind: 'express', title: 'Trois minutes pour respirer', target: 3, rounds: 1, rest: 0,
      areas: [], discipline: 'meditation', description: 'Respiration lente pour faire redescendre la pression.',
      main: ['coherence_cardiaque@1'] }),
];

export const TRAININGS = [...COMMUNS, ...REMISE, ...FESSIERS, ...GAINAGE, ...RAPIDES, ...DECOUVERTE, ...EXPRESS];
