// Génère le contenu V5 (bloc 2) à partir de content/v5/*.mjs :
//   - supabase/content-v5.sql    : import dans Supabase (à lancer après schema.sql et seed.sql)
//   - content/v5/relecture.json  : données du tableur de relecture (scripts/build-relecture.py)
// Vérifie au passage tout le contenu : vocabulaires, muscles, MET, sources, niveaux, durées.
//   node scripts/build-content.mjs [--fedb chemin/vers/free-exercise-db]
import { writeFileSync, existsSync } from 'node:fs';
import { MUSCLES, MET, SOURCES, FEDB_URL, AREAS, GOALS, DISCIPLINES, KINDS, EQUIPMENT } from '../content/v5/vocabulaire.mjs';
import { EXISTANTS } from '../content/v5/exercices-existants.mjs';
import { RENFO } from '../content/v5/exercices-renfo.mjs';
import { CARDIO } from '../content/v5/exercices-cardio.mjs';
import { YOGA } from '../content/v5/exercices-yoga.mjs';
import { VIDEOS } from '../content/v5/videos.mjs';
import { TRAININGS, PROGRAMS } from '../content/v5/entrainements.mjs';
import { EXISTING_LEVELS, EXISTING_NAMES } from '../content/v5/niveaux-existants.mjs';

const root = new URL('..', import.meta.url).pathname;
const args = process.argv.slice(2);
const fedbDir = args.includes('--fedb') ? args[args.indexOf('--fedb') + 1] : `${root}../free-exercise-db`;
const checkFedb = existsSync(`${fedbDir}/exercises`);

const errors = [];
const err = (m) => errors.push(m);
const NEW = [...RENFO, ...CARDIO, ...YOGA];

// Identifiants des 43 exercices déjà en base (seed.sql)
const SEEDED = new Set(EXISTANTS.map((e) => e.id));
if (SEEDED.size !== 43) err(`attendu 43 exercices existants, trouvé ${SEEDED.size}`);

// ------------------------------------------------------------------ sources
function resolveSource(s, id) {
  if (typeof s === 'object') {
    if (!s.label || !/^https:\/\//.test(s.url)) err(`${id} : source mal formée`);
    return s;
  }
  if (s.startsWith('fedb:')) {
    const f = s.slice(5);
    if (checkFedb && !existsSync(`${fedbDir}/exercises/${f}.json`)) err(`${id} : fiche free-exercise-db inconnue ${f}`);
    return { label: `free-exercise-db (domaine public), fiche ${f.replace(/_/g, ' ')}`, url: FEDB_URL(f) };
  }
  if (!SOURCES[s]) err(`${id} : source inconnue ${s}`);
  return SOURCES[s] ?? { label: s, url: '' };
}
const sourceText = (list) => list.map((s) => `${s.label} (${s.url})`).join(' ; ');

// ------------------------------------------------------------------ vérifications
const ids = new Set();
function checkCommon(e, isNew) {
  const id = e.id;
  if (!/^[a-z0-9_]{2,40}$/.test(id)) err(`${id} : identifiant invalide`);
  if (ids.has(id)) err(`${id} : doublon`);
  ids.add(id);
  if (isNew && SEEDED.has(id)) err(`${id} : existe déjà dans seed.sql`);
  if (!DISCIPLINES.includes(e.discipline)) err(`${id} : discipline ${e.discipline}`);
  for (const a of e.areas) if (!AREAS.includes(a)) err(`${id} : zone ${a}`);
  for (const g of e.goals) if (!GOALS.includes(g)) err(`${id} : objectif ${g}`);
  if (!e.goals.length) err(`${id} : aucun objectif`);
  for (const m of [...e.primary, ...e.secondary]) if (!MUSCLES[m]) err(`${id} : muscle ${m}`);
  if (e.primary.some((m) => e.secondary.includes(m))) err(`${id} : muscle à la fois principal et secondaire`);
  if (!e.equipment.length) err(`${id} : matériel vide (mettre 'aucun')`);
  for (const q of e.equipment) if (!EQUIPMENT.includes(q)) err(`${id} : matériel ${q}`);
  if (e.equipment.includes('aucun') && e.equipment.length > 1) err(`${id} : 'aucun' mélangé à du matériel`);
  if (!['time', 'reps'].includes(e.mode)) err(`${id} : mode ${e.mode}`);
  if (!(e.value >= 1 && e.value <= 600)) err(`${id} : valeur par défaut ${e.value}`);
  if (e.mode === 'reps' && e.value > 40) err(`${id} : ${e.value} répétitions par défaut, trop`);
  if (!MET[e.met]) err(`${id} : code MET ${e.met}`);
  if (!e.breathing || !e.mistakes?.length) err(`${id} : tutoriel incomplet`);
  const text = JSON.stringify(e);
  if (/[—–→]|->/.test(text)) err(`${id} : tiret long ou flèche dans le texte`);
}

for (const e of EXISTANTS) checkCommon(e, false);
for (const e of NEW) {
  checkCommon(e, true);
  const id = e.id;
  if (!KINDS.includes(e.kind)) err(`${id} : type ${e.kind}`);
  if (!e.name || e.name.length > 80) err(`${id} : nom`);
  if (e.cues?.length !== 3) err(`${id} : il faut 3 consignes`);
  if (!(e.intensity >= 1 && e.intensity <= 5)) err(`${id} : intensité`);
  if (!(e.levels.length >= 1 && e.levels.length <= 6)) err(`${id} : 1 à 6 niveaux`);
  for (const [label, v] of e.levels) {
    if (!label || !(v >= 1 && v <= 600)) err(`${id} : niveau mal formé`);
    if (e.mode === 'reps' && v > 40) err(`${id} : niveau ${label} à ${v} répétitions`);
  }
  if (!(e.max_sets >= 1 && e.max_sets <= 4)) err(`${id} : tours max`);
  if (!e.src?.length) err(`${id} : aucune source`);
  if (e.impact === true && !NEW.some((o) => o.family === e.family && o.impact !== true && o.kind === e.kind))
    err(`${id} : exercice à sauts sans variante sans saut de la même famille`);
}

// Zones historiques (colonne zones) déduites des muscles principaux
const zonesOf = (e) => [...new Set(e.primary.map((m) => MUSCLES[m].zone))];

// ------------------------------------------------------------------ SQL
const q = (s) => (s === null || s === undefined ? 'null' : `'${String(s).replace(/'/g, "''")}'`);
const arr = (a) => (a.length ? `array[${a.map(q).join(', ')}]::text[]` : `'{}'::text[]`);
const js = (o) => `${q(JSON.stringify(o))}::jsonb`;

const exByld = new Map();
const out = [];
out.push(`-- =====================================================================
-- Contenu V5 (bloc 2) : exercices sourcés, yoga, étirements, méditation,
-- entraînements et programmes. FICHIER GÉNÉRÉ par scripts/build-content.mjs
-- à partir de content/v5/*.mjs : ne pas le modifier à la main.
--
-- À lancer APRÈS schema.sql et seed.sql (SQL Editor > New query > Run).
-- Additif et relançable :
--   - les nouveaux exercices, entraînements et programmes arrivent « à valider »
--     (approved = false) : ils n'apparaissent nulle part tant qu'ils ne sont pas validés ;
--   - une relance met à jour le contenu encore à valider, jamais ce qui a déjà été validé ;
--   - les 43 exercices existants reçoivent leurs étiquettes sourcées, sans toucher à leur nom,
--     leurs consignes, leurs niveaux ni leur statut de validation.
-- =====================================================================
`);

out.push('-- ---------------------------------------------------------------- 1. Nouveaux exercices');
const cols = ['id', 'name', 'kind', 'illustration', 'video_url', 'cues', 'caution', 'levels', 'zones', 'equipment',
  'intensity', 'family', 'pattern', 'max_sets', 'approved', 'source', 'muscles_primary', 'muscles_secondary',
  'areas', 'goals', 'discipline', 'impact', 'mode', 'default_value', 'met', 'met_code', 'tutorial'];
const rows = [];
for (const e of NEW) {
  const sources = e.src.map((s) => resolveSource(s, e.id));
  const levels = e.levels.map(([label, v]) => (e.mode === 'reps' ? { label, reps: v } : { label, seconds: v }));
  const tutorial = { steps: e.tutorial_steps ?? e.cues, breathing: e.breathing, mistakes: e.mistakes };
  const video = VIDEOS[e.id]?.url ?? null;
  exByld.set(e.id, { ...e, levelsJson: levels });
  rows.push(`(${[q(e.id), q(e.name), q(e.kind), 'null', q(video), arr(e.cues), q(e.caution ?? null), js(levels),
    arr(zonesOf(e)), arr(e.equipment), e.intensity, q(e.family), q(e.pattern), e.max_sets, 'false',
    q(sourceText(sources)), arr(e.primary), arr(e.secondary), arr(e.areas), arr(e.goals), q(e.discipline),
    e.impact ? 'true' : 'false', q(e.mode), e.value, MET[e.met].met.toFixed(1), q(e.met), js(tutorial)].join(', ')})`);
}
out.push(`insert into public.exercises (${cols.join(', ')}) values\n${rows.join(',\n')}
on conflict (id) do update set
${cols.filter((c) => !['id', 'approved', 'illustration'].includes(c)).map((c) => `  ${c} = excluded.${c}`).join(',\n')}
where public.exercises.approved = false;
`);

out.push('-- ---------------------------------------------------------------- 2. Étiquettes sourcées des 43 exercices existants');
for (const e of EXISTANTS) {
  const sources = e.src.map((s) => resolveSource(s, e.id));
  const extra = sourceText(sources);
  const video = VIDEOS[e.id]?.url ?? null;
  exByld.set(e.id, { ...e, existing: true });
  out.push(`update public.exercises set
  muscles_primary = ${arr(e.primary)}, muscles_secondary = ${arr(e.secondary)},
  areas = ${arr(e.areas)}, goals = ${arr(e.goals)}, discipline = ${q(e.discipline)}, impact = false,
  equipment = ${arr(e.equipment)}, mode = ${q(e.mode)}, default_value = ${e.value},
  met = ${MET[e.met].met.toFixed(1)}, met_code = ${q(e.met)},
  tutorial = jsonb_build_object('steps', to_jsonb(cues), 'breathing', ${q(e.breathing)}, 'mistakes', ${js(e.mistakes)}),
  video_url = coalesce(video_url, ${q(video)})${extra ? `,
  source = case when coalesce(source, '') like ${q('%' + sources[0].url + '%')} then source else concat_ws(' ; ', source, ${q(extra)}) end` : ''}
where id = ${q(e.id)};`);
}
out.push('');

// ------------------------------------------------------------------ entraînements
// Durée calculée comme public._training_stats (schema.sql) : temps = valeur imposée, sinon secondes
// du niveau, sinon valeur par défaut ; répétitions = 3 s par répétition ; une pause entre deux passages.
function itemSeconds(ex, level, value) {
  const lv = ex.levelsJson ? ex.levelsJson[Math.min(Math.max(level ?? 1, 1), ex.levelsJson.length) - 1] : null;
  if (ex.mode === 'reps') return 3 * (value ?? lv?.reps ?? ex.value ?? 12);
  return value ?? lv?.seconds ?? ex.value ?? 45;
}
// Les niveaux et noms des exercices existants viennent de content/v5/niveaux-existants.mjs.
for (const [id, lv] of Object.entries(EXISTING_LEVELS)) if (exByld.has(id)) Object.assign(exByld.get(id), { levelsJson: lv, name: EXISTING_NAMES[id] });

function stats(t) {
  let active = 0, execs = 0, metSec = 0;
  const equip = new Set();
  let impact = false;
  for (const phase of ['warmup', 'main', 'cooldown']) {
    for (const it of t[phase] ?? []) {
      const ex = exByld.get(it.ex);
      if (!ex) { err(`${t.id} : exercice inconnu ${it.ex}`); continue; }
      const n = phase === 'main' ? (it.sets ?? t.rounds) : 1;
      const sec = itemSeconds(ex, it.level ?? t.level, it.value);
      active += n * sec;
      execs += n;
      metSec += n * sec * MET[ex.met].met;
      ex.equipment.filter((q) => q !== 'aucun').forEach((q) => equip.add(q));
      impact ||= ex.impact === true;
    }
  }
  const rest = Math.max(execs - 1, 0) * t.rest;
  return { minutes: Math.ceil((active + rest) / 60), metMinutes: Math.round((metSec / 60 + rest / 60) * 10) / 10,
           equipment: [...equip], impact };
}

const tids = new Set();
const trainingStats = {};
for (const t of TRAININGS) {
  if (!/^[a-z0-9_]{2,60}$/.test(t.id)) err(`${t.id} : identifiant d'entraînement invalide`);
  if (tids.has(t.id)) err(`${t.id} : entraînement en double`);
  tids.add(t.id);
  if (!['programme', 'rapide', 'decouverte', 'express'].includes(t.kind)) err(`${t.id} : type ${t.kind}`);
  if (!(t.level >= 1 && t.level <= 3)) err(`${t.id} : niveau`);
  if (!(t.rounds >= 1 && t.rounds <= 6)) err(`${t.id} : tours`);
  for (const a of t.areas) if (!AREAS.includes(a)) err(`${t.id} : zone ${a}`);
  if (t.title.length > 80 || (t.description ?? '').length > 500) err(`${t.id} : titre ou description trop longs`);
  if (/[—–→]|->/.test(JSON.stringify(t))) err(`${t.id} : tiret long ou flèche`);
  const seen = new Set();
  for (const phase of ['warmup', 'main', 'cooldown']) {
    for (const it of t[phase] ?? []) {
      if (seen.has(it.ex)) err(`${t.id} : ${it.ex} deux fois`);
      seen.add(it.ex);
      const ex = exByld.get(it.ex);
      if (ex && it.sets && it.sets > (ex.max_sets ?? 4)) err(`${t.id} : ${it.ex} dépasse ses tours max`);
    }
  }
  if (!(t.main?.length)) err(`${t.id} : corps de séance vide`);
  const s = stats(t);
  trainingStats[t.id] = s;
  if (t.target && Math.abs(s.minutes - t.target) > 2) err(`${t.id} : ${s.minutes} min au lieu de ${t.target}`);
  if (t.kind === 'express') {
    if (s.minutes < 3 || s.minutes > 5) err(`${t.id} : séance express de ${s.minutes} min`);
    if (s.equipment.length) err(`${t.id} : séance express avec matériel`);
  }
}

out.push('-- ---------------------------------------------------------------- 3. Entraînements');
for (const t of TRAININGS) {
  out.push(`insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values (${q(t.id)}, ${q(t.title)}, ${q(t.description ?? null)}, ${q(t.kind)}, ${t.level}, ${arr(t.areas)}, ${q(t.discipline ?? null)}, ${t.rounds}, ${t.rest}, false, ${q(t.source ?? 'Composé pour l\'app (bloc 2 V5), voir docs/CONTENU-V5.md')})
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;`);
  const items = [];
  for (const phase of ['warmup', 'main', 'cooldown']) {
    (t[phase] ?? []).forEach((it, i) => items.push(`(${q(t.id)}, ${q(phase)}, ${i + 1}, ${q(it.ex)}, ${it.level ?? t.level}, ${it.value ?? 'null'}, ${it.sets ?? 'null'})`));
  }
  out.push(`delete from public.training_items where training_id = ${q(t.id)}
  and exists (select 1 from public.trainings where id = ${q(t.id)} and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.training_id, v.phase, v.position, v.exercise_id, v.level, v.value::int, v.sets::int from (values
  ${items.join(',\n  ')}
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = ${q(t.id)} and approved = false)
on conflict (training_id, phase, position) do nothing;
`);
}

// ------------------------------------------------------------------ programmes
out.push('-- ---------------------------------------------------------------- 4. Programmes');
for (const p of PROGRAMS) {
  if (!/^[a-z0-9_]{2,60}$/.test(p.id)) err(`${p.id} : identifiant de programme invalide`);
  p.days.forEach((tid, i) => {
    if (!tids.has(tid)) err(`${p.id} jour ${i + 1} : entraînement inconnu ${tid}`);
    else if (TRAININGS.find((t) => t.id === tid).kind !== 'programme') err(`${p.id} jour ${i + 1} : ${tid} n'est pas un entraînement de programme`);
  });
  out.push(`insert into public.programs (id, title, description, goals, areas, level, approved, source)
values (${q(p.id)}, ${q(p.title)}, ${q(p.description)}, ${arr(p.goals)}, ${arr(p.areas)}, ${p.level}, false, ${q(p.source)})
on conflict (id) do update set title = excluded.title, description = excluded.description, goals = excluded.goals,
  areas = excluded.areas, level = excluded.level, source = excluded.source
where public.programs.approved = false;
delete from public.program_days where program_id = ${q(p.id)}
  and exists (select 1 from public.programs where id = ${q(p.id)} and approved = false);
insert into public.program_days (program_id, day, training_id)
select v.* from (values
  ${p.days.map((tid, i) => `(${q(p.id)}, ${i + 1}, ${q(tid)})`).join(',\n  ')}
) as v(program_id, day, training_id)
where exists (select 1 from public.programs where id = ${q(p.id)} and approved = false)
on conflict (program_id, day) do nothing;
`);
}

if (args.includes('--durees')) for (const t of TRAININGS) console.log(`${t.id.padEnd(30)} ${String(trainingStats[t.id].minutes).padStart(3)} min (visé ${t.target ?? '-'})`);
if (errors.length) {
  console.error(`${errors.length} problème(s) :\n  - ${errors.join('\n  - ')}`);
  process.exit(1);
}

writeFileSync(`${root}supabase/content-v5.sql`, out.join('\n'));

// ------------------------------------------------------------------ données de relecture
const label = (m) => MUSCLES[m].label;
const relecture = {
  exercices: [...NEW.map((e) => ({ ...e, statut: 'Nouveau' })), ...EXISTANTS.map((e) => ({ ...e, name: EXISTING_NAMES[e.id], statut: 'Existant, ré-étiqueté' }))].map((e) => ({
    id: e.id, statut: e.statut, nom: e.name ?? null, type: e.kind ?? null, discipline: e.discipline,
    zones: e.areas.join(', '), objectifs: e.goals.join(', '), intensite: e.intensity ?? null,
    sauts: e.impact ? 'oui' : 'non', materiel: e.equipment.join(', '),
    mode: e.mode === 'reps' ? `${e.value} répétitions` : `${e.value} s`,
    niveaux: e.levels ? e.levels.map(([l, v], i) => `${i + 1}. ${l} (${v}${e.mode === 'reps' ? ' rép.' : ' s'})`).join('\n') : '(inchangés)',
    muscles_principaux: e.primary.map(label).join(', '), muscles_secondaires: e.secondary.map(label).join(', '),
    met: `${MET[e.met].met} (code ${e.met}, ${MET[e.met].label})`,
    consignes: e.cues ? e.cues.join('\n') : '(inchangées)', precaution: e.caution ?? '',
    respiration: e.breathing, erreurs: e.mistakes.join('\n'),
    sources: e.src.map((s) => resolveSource(s, e.id)), video: VIDEOS[e.id] ?? null,
  })),
  entrainements: TRAININGS.map((t) => ({
    id: t.id, titre: t.title, type: t.kind, niveau: t.level, zones: t.areas.join(', '), tours: t.rounds, pause: t.rest,
    description: t.description ?? '', ...trainingStats[t.id],
    contenu: ['warmup', 'main', 'cooldown'].map((ph) => (t[ph] ?? []).map((it) => {
      const ex = exByld.get(it.ex);
      return `${{ warmup: 'Échauffement', main: 'Corps', cooldown: 'Retour au calme' }[ph]} : ${ex.name ?? it.ex}`;
    }).join('\n')).filter(Boolean).join('\n'),
  })),
  programmes: PROGRAMS.map((p) => ({
    id: p.id, titre: p.title, description: p.description, niveau: p.level, objectifs: p.goals.join(', '),
    jours: p.days.map((tid, i) => ({ jour: i + 1, entrainement: tid, titre: TRAININGS.find((t) => t.id === tid).title,
                                       minutes: trainingStats[tid].minutes })),
  })),
};
writeFileSync(`${root}content/v5/relecture.json`, JSON.stringify(relecture, null, 1));

const nNew = NEW.length;
console.log(`OK : ${nNew} nouveaux exercices, ${EXISTANTS.length} ré-étiquetés, ${TRAININGS.length} entraînements, ${PROGRAMS.length} programmes.`
  + (checkFedb ? '' : '\n(attention : fiches free-exercise-db non vérifiées, base introuvable)'));
const withVideo = [...NEW, ...EXISTANTS].filter((e) => VIDEOS[e.id]).length;
console.log(`Vidéos : ${withVideo} / ${nNew + EXISTANTS.length}`);
