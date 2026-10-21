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
assert.equal(alice.levelup_mode, 'self', 'par défaut, l\'athlète choisit librement son niveau');
// les sections suivantes testent le circuit « le coach valide » : on le remet pour elles
await db.exec(`update public.athletes set levelup_mode = 'coach'`);
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
const submitX = (args) => as('anon', null, async () =>
  (await db.query('select public.athlete_submit_workout($1,$2,$3,$4,$5,$6::jsonb,$7,$8,$9,$10,$11::jsonb,$12::jsonb) r', [
    args.token ?? TOKEN, args.client_id ?? crypto.randomUUID(), args.session ?? 'A',
    args.pain ?? 1, args.neuro ?? false, JSON.stringify(args.items ?? []), args.comment ?? null,
    args.done_at ?? null, args.rpe ?? null, args.duration ?? null, JSON.stringify(args.swaps ?? []),
    JSON.stringify(args.levels ?? []),
  ])).rows[0].r);
const options = (session, exercise, limit = 2, token = TOKEN) => as('anon', null, async () =>
  (await db.query('select public.athlete_swap_options($1,$2,$3,$4) r', [token, session, exercise, limit])).rows[0].r);
const library = (token = TOKEN) => as('anon', null, async () =>
  (await db.query('select public.athlete_library($1) r', [token])).rows[0].r);
const asCoach = (sql, params = []) => as('authenticated', COACH, () => db.query(sql, params));
const row = async (sql, params = []) => (await db.query(sql, params)).rows[0];
const approve = (...ids) => db.query(`update public.exercises set approved = true where id = any($1)`, [ids]);
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
  assert.equal(data.program.length, 36);
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
  ok('les valeurs invalides sont refusées');

  // un exercice fait mais non noté : ressenti vide, jamais un « bien » inventé
  const cidNo = crypto.randomUUID();
  await submit({ client_id: cidNo, items: [{ exercise_id: 'dead_bug', preference: 'aime' }] });
  const noFeel = await row(
    `select wi.feeling, wi.preference from public.workout_items wi join public.workouts w on w.id = wi.workout_id where w.client_id = $1`, [cidNo]);
  assert.equal(noFeel.feeling, null);
  assert.equal(noFeel.preference, 'aime');
  ok('un exercice non noté est enregistré sans ressenti (pas de « bien » par défaut)');

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
  assert.ok(rows.length === 3 && rows.every((x) => x.level === 2));
  await submit({ session: 'M', items: [{ exercise_id: 'respiration', feeling: 'douleur' }] });
  const { rows: rows2 } = await db.query(`select level from public.program_items where athlete_id=$1 and exercise_id='respiration'`, [alice.id]);
  assert.ok(rows2.every((x) => x.level === 1));
  ok('un exercice présent dans plusieurs séances garde le même niveau partout');

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

console.log('Date, durée et effort de la séance');
{
  await ageAll();
  const threeDays = new Date(Date.now() - 3 * 86_400_000).toISOString();
  const cidDate = crypto.randomUUID();
  const r = await submitX({ client_id: cidDate, done_at: threeDays, duration: 28, rpe: 6, items: [{ exercise_id: 'rowing', feeling: 'bien', preference: 'aime' }] });
  assert.equal(r.status, 'ok');
  const w = await row(`select * from public.workouts where client_id = $1`, [cidDate]);
  assert.ok(Math.abs(new Date(w.done_at) - new Date(threeDays)) < 1000, 'date réelle conservée');
  assert.equal(w.duration_min, 28);
  assert.equal(w.rpe, 6);
  const wi = await row(`select preference from public.workout_items where workout_id = $1`, [w.id]);
  assert.equal(wi.preference, 'aime');
  ok('la date réelle, la durée, l\'effort ressenti et le « j\'aime » sont enregistrés');

  const cidFuture = crypto.randomUUID();
  const cidOld = crypto.randomUUID();
  await submitX({ client_id: cidFuture, done_at: new Date(Date.now() + 3 * 86_400_000).toISOString() });
  await submitX({ client_id: cidOld, done_at: new Date(Date.now() - 40 * 86_400_000).toISOString() });
  const { rows: odd } = await db.query(`select done_at from public.workouts where client_id = any($1)`, [[cidFuture, cidOld]]);
  assert.ok(odd.every((x) => Math.abs(new Date(x.done_at) - Date.now()) < 60_000), 'date hors limites = maintenant');
  ok('une date dans le futur ou trop ancienne est remplacée par l\'heure de réception');

  await rejects(submitX({ rpe: 11 }), /invalid_rpe/, 'rpe 11');
  await rejects(submitX({ items: [{ exercise_id: 'rowing', feeling: 'bien', preference: 'bof' }] }), /invalid_preference/, 'préférence inconnue');
  const cidBig = crypto.randomUUID();
  const big = await submitX({ client_id: cidBig, duration: 9999 });
  assert.equal(big.status, 'ok');
  assert.equal((await row(`select duration_min d from public.workouts where client_id = $1`, [cidBig])).d, 240);
  ok('un effort hors échelle ou une préférence inconnue sont refusés, une durée excessive est plafonnée');
}

console.log('Bibliothèque');
{
  const lib = await library();
  assert.equal(lib.exercises.length, 25, 'seuls les 25 exercices de départ sont validés');
  assert.ok(lib.exercises.every((e) => e.zones.length > 0 && e.intensity >= 1));
  assert.equal((await row(`select count(*)::int n from public.exercises where not approved`)).n, 18);
  ok('l\'athlète ne voit que les exercices validés par le coach (18 nouveaux exercices en attente)');

  await rejects(library('x'.repeat(48)), /invalid_token/, 'bibliothèque avec un mauvais lien');
  await rejects(as('anon', null, () => db.query('select * from public.exercises')), /permission denied/, 'anon lit exercises');
  ok('la bibliothèque exige le lien personnel');

  await approve('clamshell');
  assert.equal((await library()).exercises.length, 26);
  ok('un exercice validé par le coach apparaît chez l\'athlète');

  const data = await get();
  const A = data.program.filter((p) => p.session_key === 'A').map((p) => p.block);
  assert.deepEqual(A, ['warmup', 'warmup', 'warmup', 'main', 'main', 'main', 'main', 'main', 'main', 'cooldown', 'cooldown']);
  assert.ok(data.program.every((p) => p.exercise.max_sets >= 1 && Array.isArray(p.exercise.zones)));
  ok('le programme est livré dans l\'ordre échauffement, circuit, retour au calme');
}

console.log('Remplacement d\'un exercice');
{
  await approve('glissement_talon', 'planche_inclinee');

  // dead bug (gainage, intensité 2, zone abdos) : variante = glissement de talon, autre zone = planche latérale
  const o = await options('A', 'dead_bug');
  assert.equal(o.length, 2);
  assert.equal(o[0].why, 'variante');
  assert.equal(o[0].exercise.id, 'glissement_talon');
  assert.equal(o[1].why, 'autre_zone');
  assert.equal(o[1].exercise.id, 'planche_laterale');
  ok('« Ça fait mal » propose 2 exercices : une variante et une alternative sur une autre zone');

  assert.ok(o.every((x) => x.exercise.kind === 'gainage' && Math.abs(x.exercise.intensity - 2) <= 1));
  const ids = (await options('A', 'dead_bug', 4)).map((x) => x.exercise.id);
  assert.ok(!ids.includes('pallof_genoux') && !ids.includes('curl_up_mcgill'), 'jamais d\'exercice non validé');
  assert.ok(!ids.includes('bird_dog') && !ids.includes('pallof') && !ids.includes('planche'), 'jamais un exercice déjà dans la séance');
  assert.ok(!ids.includes('dead_bug'));
  ok('les propositions sont du même type, d\'intensité voisine, validées et pas déjà dans la séance');

  await rejects(options('Z', 'dead_bug'), /invalid_session/, 'séance inconnue');
  assert.deepEqual(await options('A', 'inconnu'), []);
  ok('une séance ou un exercice inconnus ne plantent pas');

  // exercice choisi en séance parmi les remplacements : le ressenti est gardé sans toucher au programme
  await ageAll();
  const before = (await get()).program.length;
  await submitX({ items: [{ exercise_id: 'glissement_talon', feeling: 'bien' }] });
  const saved = await row(`select wi.level from public.workout_items wi where wi.exercise_id = 'glissement_talon'`);
  assert.equal(saved.level, 1);
  assert.equal((await get()).program.length, before);
  await submitX({ items: [{ exercise_id: 'pallof_genoux', feeling: 'bien' }] });
  assert.equal((await row(`select count(*)::int n from public.workout_items where exercise_id = 'pallof_genoux'`)).n, 0);
  ok('un remplacement choisi en séance est enregistré ; un exercice non validé reste ignoré');

  // douleur récente : l'exercice n'est plus proposé
  await ageAll();
  await submitX({ session: 'A', pain: 2, items: [{ exercise_id: 'glissement_talon', feeling: 'douleur' }] });
  const after = (await options('A', 'dead_bug', 4)).map((x) => x.exercise.id);
  assert.ok(!after.includes('glissement_talon'));
  ok('un exercice douloureux ces 14 derniers jours n\'est plus proposé');
  await db.query(`delete from public.workout_items where exercise_id = 'glissement_talon'`);

  // remplacement permanent demandé au bilan
  await ageAll();
  const sw = await submitX({ pain: 1, swaps: [{ session: 'A', from: 'dead_bug', to: 'planche_inclinee' }] });
  assert.equal(sw.swapped.length, 1);
  const inA = (await db.query(`select exercise_id, level, block, position from public.program_items where athlete_id=$1 and session_key='A' and active and exercise_id in ('dead_bug','planche_inclinee')`, [alice.id])).rows;
  assert.equal(inA.length, 1);
  assert.equal(inA[0].exercise_id, 'planche_inclinee');
  assert.equal(inA[0].level, 1);
  assert.equal(inA[0].block, 'main');
  assert.equal(inA[0].position, 4);
  const log = await row(`select * from public.program_changes where athlete_id = $1`, [alice.id]);
  assert.equal(log.kind, 'swap');
  assert.equal(log.source, 'athlete');
  assert.equal(log.from_exercise, 'dead_bug');
  ok('le remplacement demandé au bilan garde la place dans la séance et s\'inscrit au journal');

  // demandes refusées : la séance est enregistrée quand même, rien ne change
  await ageAll();
  const bad = [
    { session: 'A', from: 'rowing', to: 'pallof_genoux' },        // non validé
    { session: 'A', from: 'rowing', to: 'respiration' },          // autre type
    { session: 'A', from: 'rowing', to: 'pull_apart' },           // déjà dans la séance
    { session: 'A', from: 'inconnu', to: 'clamshell' },           // pas dans la séance
    { session: 'Z', from: 'rowing', to: 'clamshell' },            // séance inconnue
  ];
  const r2 = await submitX({ swaps: bad });
  assert.equal(r2.status, 'ok');
  assert.equal(r2.swapped.length, 0);
  assert.equal((await row(`select count(*)::int n from public.program_changes`)).n, 1);
  ok('un remplacement invalide est ignoré sans bloquer l\'enregistrement de la séance');

  // le coach peut interdire les remplacements
  await asCoach(`update public.athletes set allow_swaps = false where id = $1`, [alice.id]);
  assert.deepEqual(await options('A', 'rowing'), []);
  await ageAll();
  const r3 = await submitX({ swaps: [{ session: 'B', from: 'ext_hanche', to: 'clamshell' }] });
  assert.equal(r3.swapped.length, 0);
  assert.equal((await get()).athlete.allow_swaps, false);
  await asCoach(`update public.athletes set allow_swaps = true where id = $1`, [alice.id]);
  ok('quand le coach verrouille les remplacements, aucune proposition et aucun changement');

  // pas de remplacement sur un programme gelé
  await ageAll();
  const r4 = await submitX({ neuro: true, swaps: [{ session: 'B', from: 'ext_hanche', to: 'clamshell' }] });
  assert.equal(r4.swapped.length, 0);
  assert.equal(r4.frozen, true);
  await asCoach('update public.athletes set frozen=false, frozen_at=null where id=$1', [alice.id]);
  ok('un symptôme neurologique gèle le programme avant tout remplacement');
}

console.log('Éditeur de programme (coach)');
{
  // accès
  for (const q of [
    `select public.coach_add_exercise($1,'B','clamshell','main')`,
    `select public.coach_remove_exercise($1,'B','ext_hanche')`,
    `select public.coach_set_sets($1,'A','rowing',3)`,
    `select public.coach_move_exercise($1,'A','rowing',1)`,
    `select public.coach_swap_exercise($1,'B','ext_hanche','clamshell',null)`,
  ]) {
    await rejects(as('authenticated', STRANGER, () => db.query(q, [alice.id])), /forbidden/, 'non-coach : ' + q);
    await rejects(as('anon', null, () => db.query(q, [alice.id])), /permission denied/, 'anon : ' + q);
  }
  await rejects(as('authenticated', STRANGER, () => db.query(`select public.coach_save_exercise('{}'::jsonb)`)), /forbidden/, 'non-coach enregistre un exercice');
  await rejects(as('anon', null, () => db.query(`select public._swap_options($1,'A','rowing',2)`, [alice.id])), /permission denied/, 'anon appelle une fonction interne');
  ok('seul le coach peut modifier le programme et le catalogue, les fonctions internes sont fermées');

  // tours par exercice
  await asCoach(`select public.coach_set_sets($1,'A','rowing',4)`, [alice.id]);
  assert.equal((await get()).program.find((p) => p.exercise.id === 'rowing').sets, 4);
  await rejects(asCoach(`select public.coach_set_sets($1,'A','planche',4)`, [alice.id]), /invalid_sets/, 'planche max 3 tours');
  await rejects(asCoach(`select public.coach_set_sets($1,'A','rowing',0)`, [alice.id]), /invalid_sets/, '0 tour');
  await asCoach(`select public.coach_set_sets($1,'A','rowing',null)`, [alice.id]);
  assert.equal((await get()).program.find((p) => p.exercise.id === 'rowing').sets, null);
  ok('le coach règle le nombre de tours par exercice (1 à 4, dans la limite conseillée de l\'exercice)');

  // ajout / retrait / ordre
  await asCoach(`select public.coach_add_exercise($1,'B','clamshell','main')`, [alice.id]);
  let main = (await get()).program.filter((p) => p.session_key === 'B' && p.block === 'main').map((p) => p.exercise.id);
  assert.equal(main.at(-1), 'clamshell');
  await rejects(asCoach(`select public.coach_add_exercise($1,'B','clamshell','main')`, [alice.id]), /already_in_session/, 'doublon');
  await asCoach(`select public.coach_move_exercise($1,'B','clamshell',-1)`, [alice.id]);
  main = (await get()).program.filter((p) => p.session_key === 'B' && p.block === 'main').map((p) => p.exercise.id);
  assert.equal(main.at(-2), 'clamshell');
  await asCoach(`select public.coach_move_exercise($1,'B','clamshell',-1)`, [alice.id]);
  await asCoach(`select public.coach_move_exercise($1,'B','clamshell',-1)`, [alice.id]);
  await asCoach(`select public.coach_move_exercise($1,'B','clamshell',-1)`, [alice.id]);
  await asCoach(`select public.coach_move_exercise($1,'B','clamshell',-1)`, [alice.id]);
  await asCoach(`select public.coach_move_exercise($1,'B','clamshell',-1)`, [alice.id]); // déjà en tête : sans effet
  main = (await get()).program.filter((p) => p.session_key === 'B' && p.block === 'main').map((p) => p.exercise.id);
  assert.equal(main[0], 'clamshell');
  assert.equal(new Set(main).size, main.length);
  await asCoach(`select public.coach_remove_exercise($1,'B','clamshell')`, [alice.id]);
  assert.ok(!(await get()).program.some((p) => p.exercise.id === 'clamshell'));
  await asCoach(`select public.coach_add_exercise($1,'B','clamshell','cooldown')`, [alice.id]);
  assert.equal((await get()).program.find((p) => p.exercise.id === 'clamshell' && p.session_key === 'B').block, 'cooldown');
  ok('le coach ajoute, retire, réactive et réordonne les exercices d\'une séance');

  // remplacement par le coach : sans les limites imposées à l'athlète
  await asCoach(`select public.coach_swap_exercise($1,'B','clamshell','pallof_genoux','test')`, [alice.id]);
  assert.ok((await get()).program.some((p) => p.exercise.id === 'pallof_genoux' && p.session_key === 'B'));
  ok('le coach peut aussi mettre un exercice qu\'il n\'a pas encore validé');

  // catalogue
  const id = (await asCoach(`select public.coach_save_exercise($1::jsonb) id`, [JSON.stringify({
    id: 'mon_exercice', name: 'Mon exercice', kind: 'force', cues: ['Une consigne.'], levels: [{ label: 'Niveau 1' }],
    zones: ['dos'], equipment: ['aucun'], intensity: 2, max_sets: 3, approved: true,
  })])).rows[0].id;
  assert.equal(id, 'mon_exercice');
  assert.ok((await library()).exercises.some((e) => e.id === 'mon_exercice'));
  await asCoach(`select public.coach_save_exercise($1::jsonb)`, [JSON.stringify({
    id: 'mon_exercice', name: 'Mon exercice modifié', kind: 'force', levels: [{ label: 'Niveau 1' }, { label: 'Niveau 2' }], approved: false,
  })]);
  assert.ok(!(await library()).exercises.some((e) => e.id === 'mon_exercice'));
  assert.equal((await row(`select name from public.exercises where id = 'mon_exercice'`)).name, 'Mon exercice modifié');
  await rejects(asCoach(`select public.coach_save_exercise($1::jsonb)`, [JSON.stringify({ id: 'Mauvais Id', name: 'x', kind: 'force', levels: [{ label: 'a' }] })]), /invalid_id/, 'id invalide');
  await rejects(asCoach(`select public.coach_save_exercise($1::jsonb)`, [JSON.stringify({ id: 'abcd', name: 'x', kind: 'cardio', levels: [{ label: 'a' }] })]), /check/, 'type inconnu');
  await rejects(asCoach(`select public.coach_save_exercise($1::jsonb)`, [JSON.stringify({ id: 'abcd', name: 'x', kind: 'force', levels: [] })]), /check/, 'aucun niveau');
  await rejects(asCoach(`select public.coach_save_exercise($1::jsonb)`, [JSON.stringify({ id: 'abcd', name: 'x', kind: 'force', levels: [{ label: 'a' }], video_url: 'http://x.fr' })]), /check/, 'vidéo non https');
  ok('le coach crée, modifie et retire de la bibliothèque un exercice ; les données invalides sont refusées');
}

console.log('V3 : montée de niveau autonome, semaine type, compteur');
{
  // état propre : plus aucune séance ni changement, niveaux à 1, programme dégelé
  await db.exec(`delete from public.workouts; delete from public.level_changes;
    update public.program_items set level = 1; update public.athletes set frozen = false, levelup_mode = 'coach'`);
  const mainA = (await db.query(
    `select exercise_id from public.program_items where athlete_id=$1 and session_key='A' and block='main' and active order by position`, [alice.id])).rows.map((r) => r.exercise_id);
  assert.ok(mainA.length >= 3);
  const [x, y, z] = mainA;
  const facile = (...ids) => ids.map((id) => ({ exercise_id: id, feeling: 'facile' }));

  // par défaut : le coach valide, rien ne monte seul
  await submitX({ items: facile(x) }); await ageAll();
  const r0 = await submitX({ items: facile(x) }); await ageAll();
  assert.equal(await level(x), 1);
  assert.deepEqual(r0.leveled_up, []);
  assert.ok((await proposals()).some((p) => p.exercise_id === x));
  ok('par défaut (validation coach), deux « trop facile » proposent une montée sans l\'appliquer');

  await rejects(as('anon', null, () => db.query(`select public.coach_set_levelup_mode($1,'self')`, [alice.id])), /permission denied/, 'anon');
  await rejects(as('authenticated', STRANGER, () => db.query(`select public.coach_set_levelup_mode($1,'self')`, [alice.id])), /forbidden/, 'non-coach');
  await rejects(asCoach(`select public.coach_set_levelup_mode($1,'nimporte')`, [alice.id]), /invalid_mode/, 'mode inconnu');
  await asCoach(`select public.coach_set_levelup_mode($1,'self')`, [alice.id]);
  assert.equal((await get()).athlete.levelup_mode, 'self');
  ok('seul le coach change le mode de montée de niveau');

  // mode autonome : une 3e séance « facile » (les 2 dernières le sont) fait monter
  const r1 = await submitX({ items: facile(x) }); await ageAll();
  assert.equal(await level(x), 2);
  assert.deepEqual(r1.leveled_up, [{ exercise_id: x, to_level: 2 }]);
  const lc = await row(`select source, from_level, to_level from public.level_changes where exercise_id=$1`, [x]);
  assert.deepEqual([lc.source, lc.from_level, lc.to_level], ['self', 1, 2]);
  assert.ok((await get()).recent_changes.some((c) => c.exercise_id === x && c.source === 'self'));
  ok('en mode autonome, la montée est appliquée, journalisée « self » et visible côté athlète');

  // pas de nouvelle montée dans les 7 jours, même avec 2 nouveaux « facile » au nouveau niveau
  await submitX({ items: facile(x) }); await ageAll();
  const r2 = await submitX({ items: facile(x) }); await ageAll();
  assert.equal(await level(x), 2);
  assert.deepEqual(r2.leveled_up, []);
  ok('pas de deuxième montée sur le même exercice avant 7 jours');

  // douleur de la séance > 3 : aucune montée
  await submitX({ items: facile(y) }); await ageAll();
  const r3 = await submitX({ pain: 4, items: facile(y) }); await ageAll();
  assert.equal(await level(y), 1);
  assert.deepEqual(r3.leveled_up, []);
  ok('douleur de séance au-dessus de 3 : pas de montée');

  // symptôme : programme gelé, aucune montée
  await db.exec(`delete from public.workouts; delete from public.level_changes; update public.program_items set level = 1`);
  await submitX({ items: facile(z) }); await ageAll();
  const r4 = await submitX({ neuro: true, items: facile(z) }); await ageAll();
  assert.equal(await level(z), 1);
  assert.deepEqual(r4.leveled_up, []);
  assert.equal(r4.frozen, true);
  await db.exec(`update public.athletes set frozen = false`);
  ok('symptôme neurologique : programme gelé et aucune montée');

  // douleur récente sur l'exercice : aucune montée
  await db.exec(`delete from public.workouts; delete from public.level_changes; update public.program_items set level = 1`);
  await submitX({ items: [{ exercise_id: x, feeling: 'douleur' }] }); await ageAll();
  await submitX({ items: facile(x) }); await ageAll();
  await submitX({ items: facile(x) }); await ageAll();
  const r5 = await submitX({ items: facile(x) }); await ageAll();
  assert.equal(await level(x), 1);
  assert.deepEqual(r5.leveled_up, []);
  ok('douleur sur l\'exercice dans les 14 jours : pas de montée');

  // au plus 2 exercices qui montent par séance
  await db.exec(`delete from public.workouts; delete from public.level_changes; update public.program_items set level = 1`);
  await submitX({ items: facile(...mainA) }); await ageAll();
  await submitX({ items: facile(...mainA) }); await ageAll();
  const r6 = await submitX({ items: facile(...mainA) }); await ageAll();
  assert.equal(r6.leveled_up.length, 2);
  ok('au plus 2 exercices montent par séance');

  // un exercice au niveau maximum ne monte pas
  await db.exec(`delete from public.workouts; delete from public.level_changes;
    update public.program_items set level = (select jsonb_array_length(levels) from public.exercises e where e.id = exercise_id) where exercise_id = '${x}'`);
  const maxLevel = await level(x);
  await submitX({ items: facile(x) }); await ageAll();
  await submitX({ items: facile(x) }); await ageAll();
  const r7 = await submitX({ items: facile(x) }); await ageAll();
  assert.equal(await level(x), maxLevel);
  assert.deepEqual(r7.leveled_up, []);
  ok('un exercice déjà au dernier niveau ne monte pas');

  // niveau choisi librement par l'athlète : dans les deux sens, sans condition, même sans séance
  await db.exec(`delete from public.workouts; delete from public.level_changes; update public.program_items set level = 1;
                 update public.athletes set frozen = false`);
  const maxOf = async (ex) => (await row(`select jsonb_array_length(levels)::int n from public.exercises where id=$1`, [ex])).n;
  const setLevel = (ex, lvl, token = TOKEN) => as('anon', null, () =>
    db.query(`select public.athlete_set_level($1,$2,$3)`, [token, ex, lvl]));
  await setLevel(x, await maxOf(x));
  assert.equal(await level(x), await maxOf(x));
  await setLevel(x, 2);
  assert.equal(await level(x), 2);
  const lcs = (await db.query(`select source, from_level, to_level from public.level_changes where exercise_id=$1 order by created_at`, [x])).rows;
  assert.deepEqual(lcs.map((r) => r.source), ['self', 'self']);
  assert.equal(lcs[0].from_level, 1);
  ok('en mode libre, l\'athlète monte au dernier niveau puis redescend, sans condition ni délai, avec journal');
  await rejects(setLevel(x, 99), /invalid_level/, 'niveau hors limites');
  await rejects(setLevel('inconnu', 2), /not_found/, 'exercice inconnu');
  await rejects(setLevel(x, 2, 'x'.repeat(48)), /invalid_token/, 'mauvais lien');
  ok('niveau hors limites, exercice inconnu et mauvais lien sont refusés');

  // niveau choisi en séance (plus dur) : appliqué avant le ressenti, qui est donc noté au niveau fait
  await submitX({ items: [{ exercise_id: y, feeling: 'dur' }], levels: [{ exercise_id: y, level: 3 }] });
  assert.equal(await level(y), 3);
  assert.equal((await row(`select wi.level from public.workout_items wi where wi.exercise_id=$1`, [y])).level, 3);
  assert.ok((await row(`select count(*)::int n from public.level_changes where exercise_id=$1 and source='self'`, [y])).n === 1);
  ok('un niveau choisi pendant la séance est appliqué et le ressenti est enregistré à ce niveau');
  // une douleur sur cet exercice le fait redescendre d'un niveau, comme toujours
  await ageAll();
  await submitX({ items: [{ exercise_id: y, feeling: 'douleur' }] });
  assert.equal(await level(y), 2);
  ok('la douleur fait toujours redescendre d\'un niveau, même après un choix libre');

  // programme gelé : aucun choix de niveau
  await db.exec(`update public.athletes set frozen = true`);
  await rejects(setLevel(x, 1), /program_frozen/, 'gelé');
  await db.exec(`update public.athletes set frozen = false`);

  // le coach garde la main : l'athlète ne peut pas changer de niveau, ni en séance
  await asCoach(`select public.coach_set_levelup_mode($1,'coach')`, [alice.id]);
  assert.equal((await get()).athlete.levelup_mode, 'coach');
  await rejects(setLevel(x, 1), /level_by_coach/, 'mode coach');
  await ageAll();
  await submitX({ items: facile(z), levels: [{ exercise_id: z, level: 3 }] });
  assert.equal(await level(z), 1);
  ok('quand le coach garde la main, ni le réglage ni la séance ne changent les niveaux');

  // semaine type
  assert.equal((await get()).athlete.week_plan, null);
  const setPlan = (plan, token = TOKEN) => as('anon', null, () =>
    db.query(`select public.athlete_set_week_plan($1,$2::jsonb)`, [token, JSON.stringify(plan)]));
  await setPlan(['M', 'A', 'R', 'B', 'C', 'AB', 'R']);
  assert.deepEqual((await get()).athlete.week_plan, ['M', 'A', 'R', 'B', 'C', 'AB', 'R']);
  await rejects(setPlan(['A', 'B', 'A', 'B', 'A', 'R', 'R']), /too_many_strength_days/, '5 jours de renfo');
  await rejects(setPlan(['A', 'X', 'R', 'R', 'R', 'R', 'R']), /invalid_week_plan/, 'valeur inconnue');
  await rejects(setPlan(['A', 'R']), /invalid_week_plan|check/, 'pas 7 jours');
  await rejects(setPlan(['M', 'A', 'R', 'B', 'C', 'AB', 'R'], 'x'.repeat(48)), /invalid_token/, 'mauvais lien');
  await setPlan(null);
  assert.equal((await get()).athlete.week_plan, null);
  ok('l\'athlète organise sa semaine (4 jours de renfo maximum, valeurs contrôlées, retour au défaut possible)');

  await asCoach(`select public.coach_set_week_plan($1,$2::jsonb)`, [alice.id, JSON.stringify(['A', 'B', 'A', 'B', 'A', 'R', 'R'])]);
  assert.equal((await get()).athlete.week_plan[4], 'A');
  await rejects(as('authenticated', STRANGER, () => db.query(`select public.coach_set_week_plan($1,'["A","A","A","A","A","A","A"]'::jsonb)`, [alice.id])), /forbidden/, 'non-coach');
  await asCoach(`select public.coach_set_week_plan($1,null)`, [alice.id]);
  ok('le coach fixe la semaine type sans la limite des 4 jours ; un non-coach ne peut pas');

  // compteur
  await db.exec(`delete from public.workouts`);
  await submitX({ session: 'M' }); await submitX({ session: 'C' }); await ageAll();
  assert.equal((await get()).athlete.workout_count, 2);
  ok('athlete_get donne le nombre total de séances');
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

  const prog = (await db.query(`select session_key, block, exercise_id, sets, active from public.program_items where athlete_id = $1`, [alice.id])).rows;
  assert.equal(prog.length, 36);
  assert.ok(prog.every((p) => p.active && p.sets === null));
  assert.ok(prog.some((p) => p.session_key === 'A' && p.exercise_id === 'dead_bug'));
  assert.ok(!prog.some((p) => p.exercise_id === 'planche_inclinee' || p.exercise_id === 'pallof_genoux'));
  assert.equal((await row(`select count(*)::int n from public.program_changes`)).n, 0);
  ok('reset-alice.sql rétablit aussi le programme de départ (remplacements, ajouts et tours annulés)');
}

console.log(`\n${passed} vérifications réussies.`);
