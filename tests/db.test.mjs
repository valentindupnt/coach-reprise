// Tests des règles de la base de données, sans Supabase :
// on rejoue schema.sql + seed.sql dans un PostgreSQL embarqué (PGlite)
// avec un faux schéma « auth » et les rôles anon / authenticated.
//   npm run test:db
import { PGlite } from '@electric-sql/pglite';
import { pgcrypto } from '@electric-sql/pglite/contrib/pgcrypto';
import { readFileSync } from 'node:fs';
import assert from 'node:assert/strict';

const db = new PGlite({ extensions: { pgcrypto } });
const COACH = '11111111-1111-1111-1111-111111111111';
const STRANGER = '22222222-2222-2222-2222-222222222222';

await db.exec(`
  create role anon nologin;
  create role authenticated nologin;
  grant usage on schema public to anon, authenticated;
  create schema auth;
  grant usage on schema auth to anon, authenticated;
  create table auth.users (id uuid primary key);
  create function auth.uid() returns uuid language sql stable as $$
    select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid
  $$;
  grant execute on function auth.uid() to anon, authenticated;
  insert into auth.users values ('${COACH}'), ('${STRANGER}');
`);

await db.exec(readFileSync(new URL('../supabase/schema.sql', import.meta.url), 'utf8'));
await db.exec(readFileSync(new URL('../supabase/seed.sql', import.meta.url), 'utf8'));
// relançables sans erreur ni doublon
await db.exec(readFileSync(new URL('../supabase/schema.sql', import.meta.url), 'utf8'));
await db.exec(readFileSync(new URL('../supabase/seed.sql', import.meta.url), 'utf8'));
await db.exec(`insert into public.coaches (user_id) values ('${COACH}')`);

const { rows: [alice] } = await db.query(`select * from public.athletes where first_name = 'Alice'`);
const { rows: [{ n: nAthletes }] } = await db.query(`select count(*)::int n from public.athletes`);
assert.equal(nAthletes, 1, 'seed relancé : une seule Alice');
const TOKEN = alice.access_token;
assert.equal(TOKEN.length, 48);

let passed = 0;
const ok = (msg) => { passed++; console.log('  ✓ ' + msg); };

async function as(role, sub, fn) {
  await db.exec(`set role ${role}`);
  await db.exec(`select set_config('request.jwt.claim.sub', '${sub ?? ''}', false)`);
  try { return await fn(); } finally { await db.exec('reset role'); }
}
async function rejects(promise, pattern, msg) {
  try { await promise; } catch (e) {
    assert.match(String(e.message), pattern, msg);
    return;
  }
  assert.fail('aurait dû échouer : ' + msg);
}
const get = (token = TOKEN) => as('anon', null, async () =>
  (await db.query('select public.athlete_get($1) r', [token])).rows[0].r);
const submit = (args) => as('anon', null, async () =>
  (await db.query('select public.athlete_submit_workout($1,$2,$3,$4,$5,$6::jsonb,$7) r', [
    args.token ?? TOKEN, args.client_id ?? crypto.randomUUID(), args.session ?? 'A',
    args.pain ?? 1, args.neuro ?? false, JSON.stringify(args.items ?? []), args.comment ?? null,
  ])).rows[0].r);
const level = async (ex) => (await db.query(
  `select level from public.program_items where athlete_id=$1 and exercise_id=$2 limit 1`, [alice.id, ex])).rows[0].level;
// Vieillit toutes les séances d'un jour (évite la limite de 12 séances / 24 h dans les tests)
const ageAll = () => db.query(`update public.workouts set done_at = done_at - interval '1 day'`);
const proposals = () => as('authenticated', COACH, async () =>
  (await db.query('select * from public.coach_proposals()')).rows);

console.log('Accès et sécurité');
{
  const data = await get();
  assert.equal(data.athlete.first_name, 'Alice');
  assert.equal(data.program.length, 26);
  assert.ok(data.program.every((p) => p.level === 1));
  ok('athlete_get renvoie le programme avec le bon lien');

  await rejects(get('x'.repeat(48)), /invalid_token/, 'mauvais lien');
  await rejects(get('court'), /invalid_token/, 'lien trop court');
  ok('un mauvais lien est refusé');

  await rejects(as('anon', null, () => db.query('select * from public.athletes')), /permission denied/, 'anon lit athletes');
  await rejects(as('anon', null, () => db.query('select * from public.workouts')), /permission denied/, 'anon lit workouts');
  await rejects(as('anon', null, () => db.query('select public.coach_proposals()')), /permission denied/, 'anon appelle coach');
  ok('un visiteur anonyme ne peut lire aucune table ni fonction coach');

  const strangerRows = await as('authenticated', STRANGER, async () =>
    (await db.query('select * from public.athletes')).rows);
  assert.equal(strangerRows.length, 0);
  await rejects(as('authenticated', STRANGER, () =>
    db.query(`select public.coach_set_level($1,'dead_bug',2,null)`, [alice.id])), /forbidden/, 'non-coach change niveau');
  await rejects(as('authenticated', STRANGER, () =>
    db.query(`select public.coach_rotate_token($1)`, [alice.id])), /forbidden/, 'non-coach change lien');
  ok('un compte connecté qui n\'est pas coach ne voit rien et ne modifie rien');

  const coachRows = await as('authenticated', COACH, async () =>
    (await db.query('select * from public.athletes')).rows);
  assert.equal(coachRows.length, 1);
  ok('le coach voit Alice');
}

console.log('Enregistrement des séances');
{
  const cid = crypto.randomUUID();
  const r1 = await submit({ client_id: cid, items: [{ exercise_id: 'dead_bug', feeling: 'bien' }] });
  assert.equal(r1.status, 'ok');
  const r2 = await submit({ client_id: cid, items: [{ exercise_id: 'dead_bug', feeling: 'bien' }] });
  assert.equal(r2.status, 'duplicate');
  const { rows: [{ n }] } = await db.query('select count(*)::int n from public.workouts where client_id=$1', [cid]);
  assert.equal(n, 1);
  ok('un renvoi après coupure réseau ne crée pas de doublon');

  await rejects(submit({ pain: 11 }), /invalid_pain/, 'douleur 11');
  await rejects(submit({ pain: -1 }), /invalid_pain/, 'douleur -1');
  await rejects(submit({ session: 'Z' }), /invalid_session/, 'séance inconnue');
  await rejects(submit({ items: [{ exercise_id: 'dead_bug', feeling: 'super' }] }), /invalid_feeling/, 'ressenti inconnu');
  await rejects(submit({ items: [{ exercise_id: 'dead_bug' }] }), /invalid_feeling/, 'ressenti manquant');
  ok('les valeurs invalides sont refusées');

  const r3 = await submit({ items: [{ exercise_id: 'inconnu', feeling: 'bien' }] });
  assert.equal(r3.status, 'ok');
  ok('un exercice absent du programme est ignoré sans erreur');

  const r4 = await submit({ session: 'C', items: [] });
  assert.equal(r4.status, 'ok');
  ok('une séance cardio sans exercice est acceptée');
}

console.log('Régression automatique');
{
  await ageAll();
  await as('authenticated', COACH, () => db.query(`select public.coach_set_level($1,'bird_dog',3,'test')`, [alice.id]));
  assert.equal(await level('bird_dog'), 3);
  const r = await submit({ pain: 5, items: [{ exercise_id: 'bird_dog', feeling: 'douleur' }, { exercise_id: 'bird_dog', feeling: 'douleur' }] });
  assert.equal(await level('bird_dog'), 2, 'une seule descente même si l\'exercice est envoyé deux fois');
  assert.deepEqual(r.regressed, [{ exercise_id: 'bird_dog', to_level: 2 }]);
  ok('« douleur » sur un exercice le fait descendre d\'un niveau, une seule fois');

  await submit({ items: [{ exercise_id: 'rowing', feeling: 'douleur' }] });
  assert.equal(await level('rowing'), 1);
  ok('au niveau 1, on ne descend pas plus bas');

  await as('authenticated', COACH, () => db.query(`select public.coach_set_level($1,'respiration',2,null)`, [alice.id]));
  const { rows } = await db.query(`select level from public.program_items where athlete_id=$1 and exercise_id='respiration'`, [alice.id]);
  assert.ok(rows.length === 2 && rows.every((x) => x.level === 2));
  await submit({ session: 'M', items: [{ exercise_id: 'respiration', feeling: 'douleur' }] });
  const { rows: rows2 } = await db.query(`select level from public.program_items where athlete_id=$1 and exercise_id='respiration'`, [alice.id]);
  assert.ok(rows2.every((x) => x.level === 1));
  ok('un exercice présent dans deux séances garde le même niveau partout');

  const { rows: [{ n }] } = await db.query(`select count(*)::int n from public.level_changes where source='auto'`);
  assert.equal(n, 2);
  ok('chaque descente automatique est inscrite au journal');
}

console.log('Propositions de montée (validées par le coach)');
{
  await ageAll();
  assert.equal((await proposals()).filter((p) => p.exercise_id === 'pallof').length, 0);
  await submit({ pain: 2, items: [{ exercise_id: 'pallof', feeling: 'facile' }] });
  assert.equal((await proposals()).filter((p) => p.exercise_id === 'pallof').length, 0);
  ok('un seul « trop facile » ne suffit pas');

  await submit({ pain: 2, items: [{ exercise_id: 'pallof', feeling: 'facile' }] });
  const p = (await proposals()).filter((x) => x.exercise_id === 'pallof');
  assert.equal(p.length, 1);
  assert.equal(p[0].level, 1);
  assert.equal(await level('pallof'), 1, 'jamais de montée automatique');
  ok('deux « trop facile » de suite : proposition au coach, sans montée automatique');

  await submit({ pain: 2, items: [{ exercise_id: 'planche', feeling: 'facile' }] });
  await submit({ pain: 4, items: [{ exercise_id: 'planche', feeling: 'facile' }] });
  assert.equal((await proposals()).filter((x) => x.exercise_id === 'planche').length, 0);
  ok('pas de proposition si la douleur dépasse 3');

  await submit({ pain: 1, items: [{ exercise_id: 'pull_apart', feeling: 'facile' }] });
  await submit({ pain: 1, items: [{ exercise_id: 'pull_apart', feeling: 'bien' }] });
  await submit({ pain: 1, items: [{ exercise_id: 'pull_apart', feeling: 'facile' }] });
  assert.equal((await proposals()).filter((x) => x.exercise_id === 'pull_apart').length, 0);
  ok('pas de proposition si les deux derniers ressentis ne sont pas « facile »');

  await as('authenticated', COACH, () => db.query(`select public.coach_set_level($1,'pallof',2,'validé')`, [alice.id]));
  assert.equal(await level('pallof'), 2);
  await submit({ pain: 0, items: [{ exercise_id: 'pallof', feeling: 'facile' }] });
  await submit({ pain: 0, items: [{ exercise_id: 'pallof', feeling: 'facile' }] });
  assert.equal((await proposals()).filter((x) => x.exercise_id === 'pallof').length, 0);
  ok('après une validation, pas de nouvelle proposition avant 7 jours');

  await rejects(as('authenticated', COACH, () =>
    db.query(`select public.coach_set_level($1,'pallof',5,null)`, [alice.id])), /invalid_level/, 'niveau 5');
  await rejects(as('authenticated', COACH, () =>
    db.query(`select public.coach_set_level($1,'pallof',0,null)`, [alice.id])), /invalid_level/, 'niveau 0');
  ok('le coach ne peut pas choisir un niveau qui n\'existe pas');
}

console.log('Symptôme neurologique');
{
  await ageAll();
  await submit({ pain: 0, items: [{ exercise_id: 'dead_bug', feeling: 'facile' }] });
  await submit({ pain: 0, items: [{ exercise_id: 'dead_bug', feeling: 'facile' }] });
  assert.equal((await proposals()).filter((x) => x.exercise_id === 'dead_bug').length, 1);

  const r = await submit({ pain: 1, neuro: true, items: [] });
  assert.equal(r.frozen, true);
  assert.equal((await get()).athlete.frozen, true);
  ok('fourmillements ou faiblesse : le programme est gelé');

  assert.equal((await proposals()).length, 0);
  ok('aucune proposition de montée tant que le programme est gelé');

  await as('authenticated', COACH, () => db.query('update public.athletes set frozen=false, frozen_at=null where id=$1', [alice.id]));
  assert.equal((await get()).athlete.frozen, false);
  ok('le coach peut débloquer');
}

console.log('Lien secret');
{
  const t = await as('authenticated', COACH, async () =>
    (await db.query('select public.coach_rotate_token($1) t', [alice.id])).rows[0].t);
  assert.equal(t.length, 48);
  await rejects(get(TOKEN), /invalid_token/, 'ancien lien');
  assert.equal((await get(t)).athlete.first_name, 'Alice');
  ok('après changement de lien, l\'ancien ne fonctionne plus et le nouveau oui');
}

console.log('Remise à zéro');
{
  await db.exec(readFileSync(new URL('../supabase/reset-alice.sql', import.meta.url), 'utf8'));
  const { rows: [a2] } = await db.query(`select * from public.athletes where id = $1`, [alice.id]);
  const { rows: [{ n }] } = await db.query(`select count(*)::int n from public.workouts`);
  const { rows: [{ m }] } = await db.query(`select max(level)::int m from public.program_items`);
  assert.equal(n, 0);
  assert.equal(m, 1);
  assert.equal(a2.frozen, false);
  ok('reset-alice.sql efface les tests, remet les niveaux à 1 et change le lien');
}

console.log(`\n${passed} vérifications réussies.`);
