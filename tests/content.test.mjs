// Tests du contenu V5 (bloc 2), sans Supabase : schema.sql + seed.sql + content-v5.sql dans PGlite.
//   npm run test:content
// Vérifie : chargement et relance sans erreur, rien de visible avant validation, durées calculées
// par la base identiques à celles du générateur, matériel et sauts, remplacements possibles,
// puis le circuit de validation (tout « oui ») jusqu'au démarrage d'un programme.
import { PGlite } from '@electric-sql/pglite';
import { pgcrypto } from '@electric-sql/pglite/contrib/pgcrypto';
import { readFileSync, writeFileSync, mkdtempSync } from 'node:fs';
import { execFileSync } from 'node:child_process';
import { tmpdir } from 'node:os';
import assert from 'node:assert/strict';

const root = new URL('..', import.meta.url).pathname;
const sql = (f) => readFileSync(`${root}supabase/${f}`, 'utf8');
const relecture = JSON.parse(readFileSync(`${root}content/v5/relecture.json`, 'utf8'));

const db = new PGlite({ extensions: { pgcrypto } });
await db.exec(`
  create role anon nologin; create role authenticated nologin;
  grant usage on schema public to anon, authenticated;
  create schema auth; grant usage on schema auth to anon, authenticated;
  create table auth.users (id uuid primary key);
  create function auth.uid() returns uuid language sql stable as $$ select null::uuid $$;
  grant execute on function auth.uid() to anon, authenticated;`);
for (const f of ['schema.sql', 'seed.sql', 'content-v5.sql', 'content-v5.sql', 'seed.sql']) await db.exec(sql(f));

let passed = 0;
const ok = (m) => { passed++; console.log('  ✓ ' + m); };
const one = async (q, p) => (await db.query(q, p)).rows[0];
const all = async (q, p) => (await db.query(q, p)).rows;

// ---------------------------------------------------------------- chargement
const n = await one(`select count(*)::int n, count(*) filter (where approved)::int a from public.exercises`);
assert.equal(n.n, relecture.exercices.length);
assert.equal(n.a, 25, 'seuls les 25 exercices V1 restent validés');
ok(`${n.n} exercices chargés, relance sans doublon, validations existantes conservées`);

const t = await one(`select count(*)::int n, count(*) filter (where approved)::int a from public.trainings`);
assert.equal(t.n, relecture.entrainements.length);
assert.equal(t.a, 0);
const p = await one(`select count(*)::int n, sum((select count(*) from public.program_days d where d.program_id = p.id))::int days from public.programs p`);
assert.equal(p.n, 3);
assert.equal(p.days, 84);
ok(`${t.n} entraînements et 3 programmes de 28 jours, tous « à valider »`);

const untagged = await all(`select id from public.exercises where discipline is null or tutorial is null or met_code is null
  or muscles_primary = '{}' and discipline <> 'meditation' or video_url is null or source is null`);
assert.deepEqual(untagged, []);
ok('chaque exercice a discipline, muscles, MET, tutoriel, vidéo et source');

const badEquip = await all(`select id, equipment from public.exercises where not equipment <@ array['aucun','tapis','elastique','halteres','chaise','mur']`);
assert.deepEqual(badEquip, [], 'matériel au vocabulaire du questionnaire');
ok('matériel ramené au vocabulaire du questionnaire (plus de mini-band, serviette, coussin)');

// ---------------------------------------------------------------- durées : base = générateur
for (const e of relecture.entrainements) {
  const s = await one(`select public._training_stats($1) s`, [e.id]);
  assert.equal(s.s.duration_min, e.minutes, `${e.id} : durée base ${s.s.duration_min} / générateur ${e.minutes}`);
  assert.equal(Number(s.s.met_minutes), e.metMinutes, `${e.id} : MET-minutes`);
}
ok('durées et MET-minutes calculées par la base identiques au générateur, pour les 75 entraînements');

const prog = await all(`select t.id, (public._training_stats(t.id)->>'impact')::boolean impact,
  public._training_stats(t.id)->'equipment' eq from public.trainings t where t.kind in ('programme','express')`);
assert.deepEqual(prog.filter((r) => r.impact || r.eq.length), [], 'programmes et express sans saut ni matériel');
ok('programmes et séances express : aucun saut, aucun matériel');

const rapides = await all(`select id, (public._training_stats(id)->>'impact')::boolean impact,
  public._training_stats(id)->'equipment' eq from public.trainings where kind = 'rapide'`);
assert.deepEqual(rapides.filter((r) => r.eq.length).map((r) => r.id), [], 'démarrages rapides sans matériel');
assert.deepEqual(rapides.filter((r) => r.impact).map((r) => r.id).sort(),
  ['rapide_abdos_3', 'rapide_corps_entier_3', 'rapide_jambes_3']);
ok('démarrages rapides sans matériel ; seuls 3 avancés contiennent des sauts');

for (const pid of ['remise_en_forme', 'hanches_fessiers', 'gainage_calisthenie']) {
  const d = await all(`select d.day, (public._training_stats(d.training_id)->>'duration_min')::int m
    from public.program_days d where program_id = $1 order by day`, [pid]);
  const week = (w) => d.slice((w - 1) * 7, w * 7).filter((_, i) => ![2, 6].includes(i)).map((x) => x.m);
  const avg = (a) => a.reduce((x, y) => x + y, 0) / a.length;
  assert.ok(avg(week(1)) < avg(week(2)) && avg(week(2)) < avg(week(3)) && avg(week(3)) < avg(week(4)), `${pid} : durée croissante`);
  assert.ok(avg(week(1)) >= 8 && avg(week(1)) <= 12 && avg(week(4)) >= 22 && avg(week(4)) <= 27, `${pid} : 10 à 25 min`);
}
ok('les 3 programmes montent de 10 à 25 minutes, semaine après semaine');

// ---------------------------------------------------------------- remplacements
// Chaque exercice validé doit avoir au moins un remplaçant (même type, intensité ± 1) une fois tout validé.
await db.exec(`update public.exercises set approved = true`);
const lonely = await all(`select e.id from public.exercises e where not exists (
  select 1 from public.exercises o where o.id <> e.id and o.approved and o.kind = e.kind and abs(o.intensity - e.intensity) <= 1)`);
assert.deepEqual(lonely, [], 'chaque exercice a un remplaçant possible');
const jumps = await all(`select e.id from public.exercises e where e.impact and not exists (
  select 1 from public.exercises o where not o.impact and o.family = e.family and o.kind = e.kind)`);
assert.deepEqual(jumps, []);
ok('chaque exercice a au moins un remplaçant ; chaque exercice à sauts a une variante sans saut');
await db.exec(`update public.exercises set approved = false where source not like 'Programme de départ du coach%'`);

// ---------------------------------------------------------------- validation par le tableur
const dir = mkdtempSync(`${tmpdir()}/relecture-`);
const filled = `${dir}/rempli.xlsx`;
execFileSync('python3', ['-c', `
import sys
from openpyxl import load_workbook
wb = load_workbook(sys.argv[1])
for name in ('Exercices', 'Entraînements'):
    ws = wb[name]
    for r in range(2, ws.max_row + 1):
        ws.cell(r, 4, 'oui')
ws = wb['Programmes']
for r in range(1, ws.max_row + 1):
    if ws.cell(r, 1).value in ('Remise en forme', 'Hanches et fessiers', 'Gainage et calisthénie') and ws.cell(r, 2).value is None:
        ws.cell(r, 2, 'oui')
wb.save(sys.argv[2])`, `${root}content/v5/relecture-bloc2.xlsx`, filled]);
const genSql = `${dir}/validation.sql`;
const outPath = `${root}supabase/content-v5-validation.sql`;
const before = (() => { try { return readFileSync(outPath, 'utf8'); } catch { return null; } })();
execFileSync('python3', [`${root}scripts/build-validation.py`, filled]);
writeFileSync(genSql, readFileSync(outPath, 'utf8'));
if (before === null) execFileSync('rm', ['-f', outPath]); else writeFileSync(outPath, before);
await db.exec(readFileSync(genSql, 'utf8'));
const v = await one(`select (select count(*) from public.exercises where not approved)::int e,
  (select count(*) from public.trainings where not approved)::int t, (select count(*) from public.programs where not approved)::int p`);
assert.deepEqual(v, { e: 0, t: 0, p: 0 });
ok('tableur rempli de « oui » : exercices, entraînements et programmes validés');

const { access_token: token } = await one(`select access_token from public.athletes where first_name = 'Alice'`);
const cat = (await one(`select public.athlete_catalog($1) c`, [token])).c;
assert.equal(cat.programs.length, 3);
assert.equal(cat.trainings.filter((x) => x.kind === 'rapide').length, 18);
assert.equal(cat.trainings.filter((x) => x.kind === 'express').length, 6);
ok('catalogue : 3 programmes, 18 démarrages rapides, 6 séances express');

const plan = (await one(`select public.athlete_start_program($1, 'hanches_fessiers') p`, [token])).p;
assert.ok(JSON.stringify(plan).includes('hf_s1_a'), 'le jour 1 est la séance « Fessiers : les bases »');
const tr = (await one(`select public.athlete_training($1, 'hf_s1_a') t`, [token])).t;
assert.ok(tr.items.length >= 8);
ok('Alice démarre « Hanches et fessiers » et ouvre la séance du jour 1');

console.log(`\n${passed} vérifications du contenu réussies`);
