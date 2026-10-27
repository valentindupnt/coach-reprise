// Vocabulaire commun du contenu V5 (bloc 2) : muscles, valeurs MET, sources.
// Tout le contenu de content/v5/*.mjs est vérifié contre ce fichier par scripts/build-content.mjs.

// Muscles affichés sur la silhouette (bloc 5). side : 'face' ou 'dos'.
// zone : zone historique (colonne exercises.zones) qui sert aux remplacements.
export const MUSCLES = {
  pectoraux:              { label: 'Pectoraux',                 side: 'face', zone: 'pectoraux' },
  deltoides_anterieurs:   { label: 'Épaules (avant)',           side: 'face', zone: 'epaules' },
  deltoides_lateraux:     { label: 'Épaules (côté)',            side: 'face', zone: 'epaules' },
  deltoides_posterieurs:  { label: 'Épaules (arrière)',         side: 'dos',  zone: 'epaules' },
  coiffe_rotateurs:       { label: 'Coiffe des rotateurs',      side: 'dos',  zone: 'epaules' },
  biceps:                 { label: 'Biceps',                    side: 'face', zone: 'bras' },
  triceps:                { label: 'Triceps',                   side: 'dos',  zone: 'bras' },
  avant_bras:             { label: 'Avant-bras',                side: 'face', zone: 'bras' },
  trapezes:               { label: 'Trapèzes',                  side: 'dos',  zone: 'dos' },
  rhomboides:             { label: 'Haut du dos (rhomboïdes)',  side: 'dos',  zone: 'dos' },
  grand_dorsal:           { label: 'Grand dorsal',              side: 'dos',  zone: 'dos' },
  lombaires:              { label: 'Bas du dos (lombaires)',    side: 'dos',  zone: 'lombaires' },
  grand_droit:            { label: 'Abdominaux (grand droit)',  side: 'face', zone: 'abdos' },
  transverse:             { label: 'Abdominaux profonds',       side: 'face', zone: 'abdos' },
  obliques:               { label: 'Obliques',                  side: 'face', zone: 'obliques' },
  grand_fessier:          { label: 'Grand fessier',             side: 'dos',  zone: 'fessiers' },
  moyen_fessier:          { label: 'Moyen fessier',             side: 'dos',  zone: 'hanches' },
  flechisseurs_hanche:    { label: 'Fléchisseurs de hanche',    side: 'face', zone: 'hanches' },
  quadriceps:             { label: 'Quadriceps',                side: 'face', zone: 'cuisses' },
  adducteurs:             { label: 'Adducteurs',                side: 'face', zone: 'cuisses' },
  ischio_jambiers:        { label: 'Ischio-jambiers',           side: 'dos',  zone: 'ischios' },
  mollets:                { label: 'Mollets',                   side: 'dos',  zone: 'mollets' },
  cou:                    { label: 'Cou',                       side: 'dos',  zone: 'cou' },
  diaphragme:             { label: 'Diaphragme',                side: 'face', zone: 'respiration' },
};

// Compendium des activités physiques 2024 (Herrmann et al.), catégorie « Conditioning exercise »,
// vérifié sur pacompendium.com/conditioning-exercise le 26/10/2026 ; 07075 et 17160 : cadrage V5.
export const MET = {
  '02020': { met: 7.5,  label: 'Callisthénie intense (pompes, burpees, jumping jacks)' },
  '02022': { met: 3.8,  label: 'Callisthénie modérée (pompes, fentes)' },
  '02024': { met: 2.8,  label: 'Callisthénie légère (crunchs, planche)' },
  '02030': { met: 3.5,  label: 'Callisthénie légère à modérée (exercices du dos, se relever du sol)' },
  '02032': { met: 6.0,  label: 'Circuit au poids du corps' },
  '02052': { met: 5.0,  label: 'Squats et soulevés de terre' },
  '02054': { met: 3.5,  label: 'Renforcement, 8 à 15 répétitions, résistance variée' },
  '02056': { met: 3.0,  label: 'Renforcement au poids du corps, général' },
  '02101': { met: 2.3,  label: 'Étirements doux' },
  '02103': { met: 1.8,  label: 'Pilates au sol' },
  '02105': { met: 2.8,  label: 'Pilates, général' },
  '02150': { met: 2.3,  label: 'Yoga hatha' },
  '02170': { met: 2.0,  label: 'Yoga, respiration alternée (nadi shodhana)' },
  '02180': { met: 3.5,  label: 'Salutation au soleil' },
  '02210': { met: 7.0,  label: 'Fractionné intense, effort modéré' },
  '02214': { met: 11.0, label: 'Fractionné intense, effort vigoureux (Tabata)' },
  '02340': { met: 2.8,  label: 'Se lever d\'une chaise, 6 à 12 par minute' },
  '07075': { met: 1.0,  label: 'Méditation' },
};

// Sources réutilisées. Les fiches free-exercise-db s'écrivent « fedb:Nom_Du_Fichier » et sont
// vérifiées contre une copie locale de la base (domaine public, licence Unlicense).
export const SOURCES = {
  nhs_force: {
    label: 'NHS, Strength exercises',
    url: 'https://www.nhs.uk/live-well/exercise/strength-and-flexibility-exercises/strength-exercises/',
  },
  nhs_souplesse: {
    label: 'NHS, Flexibility exercises',
    url: 'https://www.nhs.uk/live-well/exercise/flexibility-exercises/',
  },
  hse_force: {
    label: 'HSE (Irlande), Strength exercises at home',
    url: 'https://www2.hse.ie/living-well/exercise/exercise-at-home/strength-exercises/',
  },
  hse_souplesse: {
    label: 'HSE (Irlande), Flexibility exercises at home',
    url: 'https://www2.hse.ie/living-well/exercise/exercise-at-home/flexibility-exercises/',
  },
  mcgill: {
    label: 'Harvard Health Publishing, Three moves for better spine health (« Big 3 » de Stuart McGill)',
    url: 'https://www.health.harvard.edu/staying-healthy/three-moves-for-better-spine-health',
  },
  pmr: {
    label: 'University of Rochester, Progressive Muscle Relaxation',
    url: 'https://www.rochester.edu/uhs/ucc/online-screening-resources/progressive-muscle-relaxation',
  },
  body_scan: {
    label: 'Greater Good in Action (UC Berkeley), Body Scan Meditation',
    url: 'https://ggia.berkeley.edu/practice/body_scan_meditation',
  },
  ucla_mindful: {
    label: 'UCLA Mindful, méditations guidées gratuites',
    url: 'https://www.uclahealth.org/uclamindful/guided-meditations',
  },
  resonance: {
    label: 'Respiration lente autour de 6 cycles par minute, revue systématique (Université de Berne)',
    url: 'https://boris.unibe.ch/193198',
  },
  acsm_2026: {
    label: 'ACSM, position officielle 2026 sur le renforcement musculaire (Phillips et al.)',
    url: 'https://acsm.org/science-spotlight-acsm-releases-new-position-stand-on-resistance-training/',
  },
  who_2020: {
    label: 'OMS, recommandations 2020 sur l\'activité physique (Bull et al., BJSM)',
    url: 'https://doi.org/10.1136/bjsports-2020-102955',
  },
  compendium_2024: {
    label: 'Herrmann et al., 2024 Adult Compendium of Physical Activities (Journal of Sport and Health Science)',
    url: 'https://pmc.ncbi.nlm.nih.gov/articles/PMC10818145/',
  },
  compendium_codes: {
    label: 'Compendium 2024, tableau des codes « Conditioning exercise » (valeurs MET)',
    url: 'https://pacompendium.com/conditioning-exercise',
  },
  tudor_locke: {
    label: 'Tudor-Locke et al., 2018, cadence de marche et intensité (British Journal of Sports Medicine)',
    url: 'https://pmc.ncbi.nlm.nih.gov/articles/PMC6029645',
  },
};

// Repères qui ont servi à construire les entraînements et les programmes, par type d'entraînement.
// Les sources de chaque exercice s'ajoutent à celles-ci dans le tableur de relecture.
export const TRAINING_REFS = {
  programme: ['who_2020', 'acsm_2026'],
  rapide: ['who_2020', 'acsm_2026'],
  decouverte: ['who_2020'],
  express: ['who_2020'],
};
// Sources des méthodes de calcul (calories, pas), reprises dans l'onglet Sources du tableur.
export const METHOD_REFS = {
  compendium_2024: 'Calories : définition du MET et méthode MET x poids x durée',
  compendium_codes: 'Calories : valeur MET et code de chaque exercice',
  tudor_locke: 'Pas : environ 100 pas par minute de marche modérée (habitude marche)',
};

export const FEDB_URL = (id) => `https://github.com/yuhonas/free-exercise-db/blob/main/exercises/${id}.json`;

// Vocabulaires contrôlés par la base (supabase/schema.sql, bloc 1)
export const AREAS = ['bras', 'epaules', 'abdos', 'fessiers', 'jambes', 'dos', 'corps_entier'];
export const GOALS = ['renforcer', 'tonifier', 'mobilite', 'cardio', 'detente'];
export const DISCIPLINES = ['renforcement', 'gainage', 'calisthenie', 'cardio', 'hiit', 'yoga', 'etirement', 'pilates', 'meditation'];
export const KINDS = ['force', 'gainage', 'mobilite', 'etirement', 'respiration', 'cardio'];
// Matériel : uniquement le matériel du questionnaire, au sens « nécessaire ». Un exercice
// n'est proposé que si tout son matériel est disponible (schema.sql : e.equipment <@ profil).
export const EQUIPMENT = ['aucun', 'tapis', 'elastique', 'halteres', 'chaise', 'mur'];
