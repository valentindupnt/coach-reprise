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
const ageAll = () => db.exec(`update public.workouts set done_at = done_at - interval '1 day';
  update public.exercise_blocks set blocked_at = blocked_at - interval '1 day', until = until - interval '1 day'`);
const blockOf = async (ex) => (await db.query(
  `select until from public.exercise_blocks where athlete_id=$1 and exercise_id=$2 and until > now()`, [alice.id, ex])).rows[0];
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

console.log('Bouton « Ça fait mal » : tampon de 10 jours');
{
  await ageAll();
  await as('authenticated', COACH, () => db.query(`select public.coach_set_level($1,'bird_dog',3,'test')`, [alice.id]));
  const r = await submit({ pain: 5, items: [{ exercise_id: 'bird_dog', feeling: 'douleur' }, { exercise_id: 'bird_dog', feeling: 'douleur' }] });
  assert.equal(await level('bird_dog'), 3, 'le niveau ne bouge plus');
  assert.deepEqual(r.regressed, []);
  assert.equal(r.blocked.length, 1);
  assert.equal(r.blocked[0].exercise_id, 'bird_dog');
  const days = (new Date(r.blocked[0].until) - Date.now()) / 86_400_000;
  assert.ok(days > 9.9 && days <= 10.01, 'tampon de 10 jours');
  assert.equal((await row(`select count(*)::int n from public.exercise_blocks where exercise_id = 'bird_dog'`)).n, 1);
  ok('« douleur » sur un exercice pose un tampon de 10 jours, une seule fois, sans toucher au niveau');

  assert.equal((await row(`select count(*)::int n from public.level_changes where source='auto'`)).n, 0);
  ok('plus aucune baisse de niveau automatique');

  assert.ok((await get()).blocks.some((b) => b.exercise_id === 'bird_dog'));
  assert.ok((await library()).blocks.some((b) => b.exercise_id === 'bird_dog'));
  ok('le tampon et sa date de fin sont envoyés à l\'app (accueil et bibliothèque)');

  for (let k = 0; k < 10; k++) await ageAll();
  assert.equal(await blockOf('bird_dog'), undefined);
  assert.ok(!(await get()).blocks.some((b) => b.exercise_id === 'bird_dog'));
  ok('le tampon se lève tout seul au bout de 10 jours');

  // bouton « Ça fait mal » en ligne : tampon immédiat
  const f = await as('anon', null, async () => (await db.query(`select public.athlete_flag_pain($1,'rowing') r`, [TOKEN])).rows[0].r);
  assert.equal(f.exercise_id, 'rowing');
  assert.ok(await blockOf('rowing'));
  await rejects(as('anon', null, () => db.query(`select public.athlete_flag_pain($1,'inconnu')`, [TOKEN])), /not_found/, 'exercice inconnu');
  await rejects(as('anon', null, () => db.query(`select public.athlete_flag_pain($1,'rowing')`, ['x'.repeat(48)])), /invalid_token/, 'mauvais lien');
  ok('le bouton « Ça fait mal » pose le tampon tout de suite quand on est en ligne');

  // l'admin lève un tampon avant la fin ; personne d'autre ne le peut
  await rejects(as('authenticated', STRANGER, () => db.query(`select public.coach_lift_block($1,'rowing')`, [alice.id])), /forbidden/, 'non-coach');
  await rejects(as('anon', null, () => db.query(`select public.coach_lift_block($1,'rowing')`, [alice.id])), /permission denied/, 'anon');
  await asCoach(`select public.coach_lift_block($1,'rowing')`, [alice.id]);
  assert.equal(await blockOf('rowing'), undefined);
  ok('l\'espace admin peut lever un tampon avant ses 10 jours');
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

console.log('Plus de gel du programme');
{
  await ageAll();
  await submit({ pain: 0, items: [{ exercise_id: 'dead_bug', feeling: 'facile' }] });
  await submit({ pain: 0, items: [{ exercise_id: 'dead_bug', feeling: 'facile' }] });
  assert.equal((await proposals()).filter((x) => x.exercise_id === 'dead_bug').length, 1);

  const r = await submit({ pain: 1, neuro: true, items: [] });
  assert.equal(r.status, 'ok');
  assert.equal(r.frozen, false);
  assert.equal((await get()).athlete.frozen, false);
  ok('un symptôme signalé par une ancienne version de l\'app ne gèle plus le programme');

  await db.exec(`update public.athletes set frozen = true, frozen_at = now()`);
  await db.exec(readFileSync(new URL('../supabase/schema.sql', import.meta.url), 'utf8'));
  assert.equal((await get()).athlete.frozen, false);
  ok('la migration libère un utilisateur gelé auparavant');
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
  ok('un exercice tamponné « Ça fait mal » n\'est plus proposé en remplacement');
  await db.query(`delete from public.workout_items where exercise_id = 'glissement_talon'`);
  await db.query(`delete from public.exercise_blocks where exercise_id = 'glissement_talon'`);

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

  // plus de gel : un symptôme signalé n'empêche plus un remplacement
  await ageAll();
  const r4 = await submitX({ neuro: true, swaps: [{ session: 'B', from: 'ext_hanche', to: 'clamshell' }] });
  assert.equal(r4.swapped.length, 1);
  assert.equal(r4.frozen, false);
  await asCoach(`select public.coach_swap_exercise($1,'B','clamshell','ext_hanche','retour')`, [alice.id]);
  ok('un symptôme signalé ne bloque plus le remplacement demandé au bilan');
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
  await rejects(asCoach(`select public.coach_save_exercise($1::jsonb)`, [JSON.stringify({ id: 'abcd', name: 'x', kind: 'danse', levels: [{ label: 'a' }] })]), /check/, 'type inconnu');
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

  // symptôme signalé : pas de gel, mais pas de montée sur cette séance
  await db.exec(`delete from public.workouts; delete from public.level_changes; update public.program_items set level = 1`);
  await submitX({ items: facile(z) }); await ageAll();
  const r4 = await submitX({ neuro: true, items: facile(z) }); await ageAll();
  assert.equal(await level(z), 1);
  assert.deepEqual(r4.leveled_up, []);
  assert.equal(r4.frozen, false);
  ok('symptôme signalé : pas de gel, et pas de montée sur cette séance');

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
  // une douleur sur cet exercice pose le tampon, sans changer le niveau choisi
  await ageAll();
  await submitX({ items: [{ exercise_id: y, feeling: 'douleur' }] });
  assert.equal(await level(y), 3);
  assert.ok(await blockOf(y));
  ok('la douleur pose le tampon de 10 jours et garde le niveau choisi');

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

console.log('V5 : étiquettes des exercices');
{
  const all = (await db.query(`select * from public.exercises`)).rows;
  assert.equal(all.length, 44, '43 du catalogue + 1 créé par le coach');
  assert.ok(all.every((e) => e.discipline && e.areas.length > 0 && e.goals.length > 0 && e.met !== null && /^\d{5}$/.test(e.met_code)));
  ok('tous les exercices, y compris ceux créés depuis le panneau, reçoivent zones, objectifs, discipline et valeur MET');

  const ex = async (id) => row(`select * from public.exercises where id = $1`, [id]);
  assert.ok((await ex('pont')).areas.includes('fessiers'));
  assert.deepEqual([(await ex('respiration')).discipline, Number((await ex('respiration')).met), (await ex('respiration')).met_code], ['meditation', 1, '07075']);
  const rowing = await ex('rowing');
  assert.equal(rowing.discipline, 'renforcement');
  assert.ok(rowing.areas.includes('dos') && rowing.areas.includes('bras'));
  assert.equal(rowing.mode, 'time');
  ok('les étiquettes déduites sont cohérentes (pont : fessiers ; respiration : méditation, MET 1,0 ; rowing : dos et bras)');

  const libEx = (await library()).exercises.find((e) => e.id === 'rowing');
  for (const k of ['muscles_primary', 'muscles_secondary', 'areas', 'goals', 'discipline', 'impact', 'mode', 'met', 'met_code', 'tutorial']) {
    assert.ok(k in libEx, k);
  }
  ok('la fiche envoyée à l\'app contient toutes les nouvelles étiquettes');

  await rejects(db.query(`update public.exercises set areas = array['pieds'] where id = 'rowing'`), /check/, 'zone inconnue');
  await rejects(db.query(`update public.exercises set mode = 'x' where id = 'rowing'`), /check/, 'mode inconnu');
  await rejects(db.query(`update public.exercises set met_code = 'abc' where id = 'rowing'`), /check/, 'code MET');
  await rejects(db.query(`update public.exercises set discipline = 'boxe' where id = 'rowing'`), /check/, 'discipline inconnue');
  ok('une étiquette hors liste est refusée par la base');
}

// Exercices et entraînements de test (contrôlés, pour vérifier les calculs)
await db.exec(`
  insert into public.exercises (id, name, kind, levels, approved, mode, met, met_code, impact, equipment, intensity, areas, discipline, goals, family)
  values
    ('v5_t',  'Test temps',     'cardio', '[{"label":"a"}]', true, 'time', 4.0, '02020', true,  '{aucun}',     2, '{corps_entier}', 'cardio',       '{cardio}',   null),
    ('v5_r',  'Test reps',      'force',  '[{"label":"a"}]', true, 'reps', 3.0, '02056', false, '{elastique}', 2, '{bras}',         'renforcement', '{renforcer}', 'v5fam'),
    ('v5_r2', 'Test variante',  'force',  '[{"label":"a"}]', true, 'reps', 3.0, '02056', false, '{aucun}',     2, '{bras}',         'renforcement', '{renforcer}', 'v5fam');
  update public.exercises set default_value = 10 where id in ('v5_r', 'v5_r2');
  insert into public.trainings (id, title, kind, rounds, rest_seconds, approved, areas) values
    ('t_test', 'Test rapide', 'rapide', 2, 15, true, '{bras}'),
    ('t_brouillon', 'Brouillon', 'decouverte', 2, 15, false, '{}'),
    ('t_day', 'Jour type', 'programme', 1, 10, true, '{corps_entier}'),
    ('t_day2', 'Jour type 2', 'programme', 1, 10, true, '{corps_entier}');
  insert into public.training_items (training_id, phase, position, exercise_id, value) values
    ('t_test', 'warmup', 1, 'v5_t', 30), ('t_test', 'main', 1, 'v5_t', 40), ('t_test', 'main', 2, 'v5_r', null),
    ('t_test', 'cooldown', 1, 'v5_t', 20),
    ('t_day', 'main', 1, 'v5_t', 60), ('t_day2', 'main', 1, 'v5_r', null);
`);
const training = (id, token = TOKEN) => as('anon', null, async () =>
  (await db.query('select public.athlete_training($1,$2) r', [token, id])).rows[0].r);
const catalog = (token = TOKEN) => as('anon', null, async () =>
  (await db.query('select public.athlete_catalog($1) r', [token])).rows[0].r);
const startProgram = (id, token = TOKEN) => as('anon', null, async () =>
  (await db.query('select public.athlete_start_program($1,$2) r', [token, id])).rows[0].r);
const submitT = (a) => as('anon', null, async () =>
  (await db.query('select public.athlete_submit_training($1,$2,$3,$4,$5::jsonb,$6,$7,$8,$9) r', [
    a.token ?? TOKEN, a.client_id ?? crypto.randomUUID(), a.training, a.day ?? null, JSON.stringify(a.items ?? []),
    a.done_at ?? null, a.rpe ?? null, a.duration ?? null, a.comment ?? null,
  ])).rows[0].r);
const saveProfile = (p, token = TOKEN) => as('anon', null, async () =>
  (await db.query('select public.athlete_save_profile($1,$2::jsonb) r', [token, JSON.stringify(p)])).rows[0].r);

console.log('V5 : entraînements');
{
  const t = await training('t_test');
  assert.deepEqual(t.items.map((i) => `${i.phase}:${i.exercise.id}`), ['warmup:v5_t', 'main:v5_t', 'main:v5_r', 'cooldown:v5_t']);
  // 30 + 2 x 40 + 2 x (10 reps x 3 s) + 20 = 190 s d'effort ; 6 passages, donc 5 pauses de 15 s = 75 s
  assert.equal(t.active_seconds, 190);
  assert.equal(t.rest_seconds_total, 75);
  assert.equal(t.duration_min, 5);
  ok('la durée est calculée d\'après le contenu (phases, tours, temps ou répétitions, pauses)');

  // (30x4 + 80x4 + 60x3 + 20x4) / 60 + 75 s de pause à 1 MET = 11,67 + 1,25
  assert.equal(Number(t.met_minutes), 12.9);
  assert.deepEqual(t.equipment, ['elastique']);
  assert.equal(t.impact, true);
  ok('MET-minutes (pour les calories), matériel nécessaire et présence de sauts sont calculés');

  await rejects(training('t_brouillon'), /not_found/, 'non validé');
  await rejects(training('inconnu'), /not_found/, 'inconnu');
  await rejects(training('t_test', 'x'.repeat(48)), /invalid_token/, 'mauvais lien');
  const c = await catalog();
  const ids = c.trainings.map((x) => x.id);
  assert.ok(ids.includes('t_test') && !ids.includes('t_brouillon') && !ids.includes('t_day'));
  ok('le catalogue ne montre que les entraînements validés hors programme');

  // tampon : l'exercice est remplacé à l'ouverture par une variante validée
  await as('anon', null, () => db.query(`select public.athlete_flag_pain($1,'v5_r')`, [TOKEN]));
  const t2 = await training('t_test');
  const swapped = t2.items.find((i) => i.phase === 'main' && i.position === 2);
  assert.equal(swapped.exercise.id, 'v5_r2');
  assert.equal(swapped.replaced_from, 'v5_r');
  ok('un exercice tamponné est remplacé automatiquement à l\'ouverture de l\'entraînement');

  // matériel absent du profil : pas de remplaçant possible, l'exercice est retiré de la séance
  await db.exec(`update public.exercises set equipment = '{halteres}' where id = 'v5_r2'`);
  await saveProfile({ equipment: ['tapis'] });
  const t3 = await training('t_test');
  assert.equal(t3.items.length, 3);
  assert.ok(!t3.items.some((i) => ['v5_r', 'v5_r2'].includes(i.exercise.id)));
  ok('sans remplaçant compatible (matériel du profil), l\'exercice tamponné est retiré');
  await db.exec(`update public.exercises set equipment = '{aucun}' where id = 'v5_r2'; delete from public.athlete_profiles;
    delete from public.exercise_blocks`);
}

console.log('V5 : programmes jour par jour');
{
  await db.exec(`
    insert into public.programs (id, title, approved, goals, areas) values
      ('p_test', 'Programme test', true, '{garder_la_forme}', '{corps_entier}'),
      ('p_brouillon', 'Brouillon', false, '{}', '{}');
    insert into public.program_days (program_id, day, training_id) values
      ('p_test', 1, 't_day'), ('p_test', 2, 't_day2'), ('p_test', 3, 't_day'), ('p_brouillon', 1, 't_day');
    delete from public.workouts;
  `);
  const c = await catalog();
  const p = c.programs.find((x) => x.id === 'p_test');
  assert.equal(p.days, 3);
  assert.ok(!c.programs.some((x) => x.id === 'p_brouillon'));
  assert.equal((await get()).plan, null);
  await rejects(startProgram('p_brouillon'), /not_found/, 'non validé');
  ok('le catalogue liste les programmes validés ; aucun programme suivi au départ');

  const status = (plan) => plan.days.map((d) => d.status);
  let plan = await startProgram('p_test');
  assert.deepEqual(status(plan), ['disponible', 'verrouille', 'verrouille']);
  assert.equal(plan.today_day, 1);
  ok('au démarrage, seul le jour 1 est ouvert');

  let r = await submitT({ training: 't_day', day: 1 });
  assert.equal(r.linked, true);
  assert.deepEqual(status(r.plan), ['fait', 'verrouille', 'verrouille']);
  assert.equal(r.plan.today_day, null);
  r = await submitT({ training: 't_day2', day: 2 });
  assert.equal(r.status, 'ok');
  assert.equal(r.linked, false);
  assert.deepEqual(status(r.plan), ['fait', 'verrouille', 'verrouille']);
  ok('un jour fait, le suivant reste verrouillé jusqu\'au lendemain (la séance est gardée, sans compter pour le plan)');

  await ageAll();
  plan = (await get()).plan;
  assert.deepEqual(status(plan), ['fait', 'disponible', 'verrouille']);
  r = await submitT({ training: 't_day', day: 2 });
  assert.equal(r.linked, false, 'mauvais entraînement pour ce jour');
  r = await submitT({ training: 't_day2', day: 2 });
  assert.equal(r.linked, true);
  ok('le lendemain, le jour 2 s\'ouvre ; seul le bon entraînement le valide');

  await rejects(as('authenticated', STRANGER, () => db.query(`select public.coach_unlock_day($1,3)`, [alice.id])), /forbidden/, 'non-coach');
  await asCoach(`select public.coach_unlock_day($1,3)`, [alice.id]);
  assert.deepEqual(status((await get()).plan), ['fait', 'fait', 'disponible']);
  ok('l\'espace admin peut débloquer un jour en avance');

  const cid = crypto.randomUUID();
  await ageAll();
  r = await submitT({ client_id: cid, training: 't_day', day: 3, items: [{ exercise_id: 'v5_t', feeling: 'douleur' }] });
  assert.equal(r.linked, true);
  assert.equal(r.plan, null, 'programme terminé');
  assert.equal((await row(`select status from public.athlete_programs where program_id = 'p_test'`)).status, 'termine');
  assert.equal(r.blocked[0].exercise_id, 'v5_t');
  assert.equal((await submitT({ client_id: cid, training: 't_day', day: 3 })).status, 'duplicate');
  ok('dernier jour fait : programme terminé ; « douleur » pose le tampon ; un renvoi ne crée pas de doublon');

  await startProgram('p_test');
  await startProgram('p_test');
  const enr = (await db.query(`select status from public.athlete_programs where athlete_id = $1 order by created_at`, [alice.id])).rows.map((x) => x.status);
  assert.deepEqual(enr, ['termine', 'abandonne', 'actif']);
  ok('un seul programme suivi à la fois : en démarrer un autre abandonne le précédent');

  await rejects(submitT({ training: 'inconnu' }), /not_found/, 'entraînement inconnu');
  await rejects(submitT({ training: 't_test', rpe: 11 }), /invalid_rpe/, 'effort hors échelle');
  await rejects(submitT({ training: 't_test', items: [{ exercise_id: 'v5_t', feeling: 'super' }] }), /invalid_feeling/, 'ressenti inconnu');
  ok('les valeurs invalides d\'un entraînement sont refusées');
  await db.exec(`delete from public.exercise_blocks; delete from public.workouts; delete from public.athlete_programs`);
}

console.log('V5 : profil sportif');
{
  assert.equal((await get()).profile, null);
  let p = await saveProfile({ goal: 'tonifier', areas: ['fessiers', 'abdos'], height_cm: 168, weight_kg: 60 });
  assert.equal(p.goal, 'tonifier');
  assert.equal(Number(p.bmi), 21.3);
  p = await saveProfile({ level: 'debutant', session_minutes: 20, adherence: { ennui: true }, complete: true });
  assert.equal(p.goal, 'tonifier', 'les réponses précédentes sont gardées');
  assert.deepEqual(p.areas, ['fessiers', 'abdos']);
  assert.ok(p.completed_at);
  assert.deepEqual((await get()).profile.adherence, { ennui: true });
  ok('le profil s\'enregistre par morceaux, garde les réponses précédentes, calcule l\'IMC');

  p = await saveProfile({ areas: null, weight_kg: null });
  assert.deepEqual(p.areas, []);
  assert.equal(p.bmi, null);
  ok('effacer une réponse est possible (une liste effacée redevient vide)');

  await rejects(saveProfile({ height_cm: 300 }), /invalid_profile/, 'taille');
  await rejects(saveProfile({ areas: ['pieds'] }), /invalid_profile/, 'zone');
  await rejects(saveProfile({ session_minutes: 12 }), /invalid_profile/, 'durée');
  await rejects(saveProfile({ birth_year: 'abc' }), /invalid_profile/, 'année');
  await rejects(saveProfile({ adherence: { ennui: 'oui' } }), /invalid_profile/, 'adhésion');
  await rejects(saveProfile({ diagnostic: 'x' }), /invalid_profile_field/, 'champ inconnu');
  await rejects(saveProfile({ goal: 'x' }, 'x'.repeat(48)), /invalid_token/, 'mauvais lien');
  assert.equal((await get()).profile.goal, 'tonifier', 'une erreur ne modifie rien');
  ok('une valeur hors liste ou un champ inconnu sont refusés sans rien modifier');

  await as('anon', null, () => db.query(`select public.athlete_delete_profile($1)`, [TOKEN]));
  assert.equal((await get()).profile, null);
  ok('l\'utilisateur peut effacer tout son profil');
}

console.log('V5 : sécurité des nouvelles tables');
{
  for (const t of ['trainings', 'training_items', 'programs', 'program_days', 'athlete_programs', 'athlete_profiles', 'exercise_blocks']) {
    await rejects(as('anon', null, () => db.query(`select * from public.${t}`)), /permission denied/, 'anon lit ' + t);
    const n = await as('authenticated', STRANGER, async () => (await db.query(`select count(*)::int n from public.${t}`)).rows[0].n);
    assert.equal(n, 0, 'non-coach lit ' + t);
  }
  for (const f of [`select public._training_json('t_test', null)`, `select public._plan_json('${alice.id}')`,
                   `select public._block_exercise('${alice.id}', 'v5_t', now())`]) {
    await rejects(as('anon', null, () => db.query(f)), /permission denied/, 'anon : ' + f);
  }
  ok('un visiteur anonyme ne lit aucune nouvelle table ni fonction interne ; un non-coach ne voit rien');
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

  for (const t of ['exercise_blocks', 'athlete_profiles', 'athlete_programs']) {
    assert.equal((await row(`select count(*)::int n from public.${t} where athlete_id = $1`, [alice.id])).n, 0, t);
  }
  ok('reset-alice.sql efface aussi le profil, les tampons et les programmes suivis');
}

console.log(`\n${passed} vérifications réussies.`);
