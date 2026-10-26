// Parcours complets dans un navigateur au format iPhone, contre le faux Supabase.
//   npm run test:e2e   (construit l'app puis lance les scénarios)
import { chromium, devices } from 'playwright';
import { spawn } from 'node:child_process';
import { mkdirSync } from 'node:fs';
import assert from 'node:assert/strict';
import { startMock, COACH_EMAIL, COACH_PASSWORD } from './mock-supabase.mjs';

const SHOTS = new URL('./screens/', import.meta.url).pathname;
mkdirSync(SHOTS, { recursive: true });
const APP = 'http://localhost:4173';

const mock = await startMock(54321);
// par défaut Alice choisit son niveau librement ; les premiers scénarios testent le circuit « le coach valide »
await mock.db.query(`update public.athletes set levelup_mode = 'coach'`);
const preview = spawn('npx', ['vite', 'preview', '--port', '4173', '--strictPort'], { stdio: 'ignore' });
await new Promise((r) => setTimeout(r, 2500));

const browserOpts = process.env.PW_CHROMIUM ? { executablePath: process.env.PW_CHROMIUM } : {};
const browser = await chromium.launch(browserOpts);
const iphone = { ...devices['iPhone 13'], defaultBrowserType: undefined };
delete iphone.defaultBrowserType;

let passed = 0;
const ok = (m) => { passed++; console.log('  ✓ ' + m); };
const errors = [];
function watch(page, who) {
  page.on('pageerror', (e) => errors.push(`${who}: ${e.message}`));
  page.on('console', (m) => {
    if (m.type() === 'error' && !/Failed to load resource|ERR_INTERNET_DISCONNECTED|fonts\.g/.test(m.text())) errors.push(`${who}: ${m.text()}`);
  });
}

// avance de n étapes dans le lecteur
const next = async (page, n) => {
  for (let i = 0; i < n; i++) await page.getByRole('button', { name: 'Étape suivante' }).click();
};
// fait vraiment passer le temps : chaque étape va au bout de son minuteur (horloge simulée)
const advance = async (page, n) => {
  const secs = (t) => t.split(':').reduce((a, x) => a * 60 + Number(x), 0);
  for (let i = 0; i < n; i++) {
    const left = secs(await page.getByRole('timer').innerText());
    await page.clock.fastForward((left + 1) * 1000);
    await page.waitForTimeout(250);
  }
};
// attend (jusqu'à 5 s) qu'une condition devienne vraie
const poll = async (fn) => {
  for (let i = 0; i < 40; i++) {
    if (await fn()) return;
    await new Promise((r) => setTimeout(r, 125));
  }
  assert.fail('condition jamais remplie');
};
const endSession = async (page) => {
  await page.getByRole('button', { name: 'Terminer la séance' }).click();
  await page.getByRole('button', { name: 'Oui, terminer' }).click();
  // la séance est finie : l'horloge simulée redevient l'heure réelle (les dates enregistrées restent exactes)
  await page.clock.setSystemTime(new Date());
};
// V5 : le bilan ne pose plus la question des symptômes (le gel du programme est supprimé)
const noSymptom = async () => {};
const exerciseBox = (page, name) => page.locator('fieldset', { hasText: name });

try {
  // ------------------------------------------------------------------
  console.log('Coach : connexion et préparation');
  const coachCtx = await browser.newContext({ viewport: { width: 1280, height: 900 } });
  const coach = await coachCtx.newPage();
  watch(coach, 'coach');
  await coach.goto(`${APP}/coach`);
  await coach.getByLabel('E-mail').fill(COACH_EMAIL);
  await coach.getByLabel('Mot de passe').fill('mauvais');
  await coach.getByRole('button', { name: 'Se connecter' }).click();
  await coach.getByText('E-mail ou mot de passe incorrect.').waitFor();
  ok('mauvais mot de passe refusé avec un message clair');

  await coach.getByLabel('Mot de passe').fill(COACH_PASSWORD);
  await coach.getByRole('button', { name: 'Se connecter' }).click();
  await coach.getByRole('heading', { name: 'Tableau de bord' }).waitFor();
  await coach.getByRole('heading', { name: 'Alice', exact: true }).waitFor();
  ok('connexion coach et fiche d\'Alice affichées');

  await coach.getByRole('button', { name: 'Monter Dead bug' }).click();
  await coach.locator('output', { hasText: '2/4' }).first().waitFor();
  ok('le coach monte le dead bug au niveau 2');

  await coach.getByPlaceholder('Ex. : Super semaine').fill('Bienvenue Alice ! On y va en douceur.');
  await coach.getByRole('button', { name: 'Enregistrer', exact: true }).click();
  await coach.getByRole('status').filter({ hasText: 'Enregistré' }).waitFor();
  ok('message du coach enregistré');
  await coach.screenshot({ path: SHOTS + 'coach-1-tableau.png', fullPage: true });

  const link = await coach.getByLabel('Lien personnel').inputValue();
  assert.match(link, /\/a\/[a-f0-9]{48}$/);
  ok('lien personnel affiché');

  // ------------------------------------------------------------------
  console.log('Alice : accueil et séance');
  const aliceCtx = await browser.newContext(iphone);
  const alice = await aliceCtx.newPage();
  await alice.clock.install();
  watch(alice, 'alice');
  await alice.goto(`${APP}/a/${'0'.repeat(48)}`);
  await alice.getByText('Lien non reconnu').waitFor();
  ok('un faux lien affiche un message, pas un écran blanc');

  await alice.goto(link);
  await alice.getByRole('heading', { name: 'Bonjour Alice !' }).waitFor();
  await alice.getByText('Bienvenue Alice ! On y va en douceur.').waitFor();
  await alice.getByText('Nouveau niveau débloqué').waitFor();
  ok('accueil : prénom, message du coach et niveau débloqué');
  await alice.screenshot({ path: SHOTS + 'alice-1-accueil.png', fullPage: true });

  await alice.getByRole('button', { name: 'Séances' }).click();
  const tileTexts = await alice.locator('.day-tile').allInnerTexts();
  assert.ok(tileTexts.some((t) => /≈ \d+ min/.test(t)), 'les durées affichées sont estimées');
  assert.ok(!tileTexts.some((t) => /^\s*30 min/m.test(t) && /Renforcement/.test(t)), 'plus de « 30 min » en dur sur les séances de renforcement');
  ok('les durées des séances sont estimées d\'après le contenu réel');

  await alice.getByRole('button', { name: /^A Renforcement A/ }).click();
  await alice.getByRole('heading', { name: 'Renforcement A' }).waitFor();
  const estimate = Number((await alice.getByText(/Environ \d+ min/).innerText()).match(/(\d+)/)[1]);
  assert.ok(estimate >= 15 && estimate <= 35, `durée estimée plausible (${estimate} min)`);
  await alice.getByText('Échauffement', { exact: true }).waitFor();
  await alice.getByText('Retour au calme', { exact: true }).waitFor();
  ok(`écran de départ : échauffement, circuit et retour au calme, environ ${estimate} min`);
  await alice.screenshot({ path: SHOTS + 'alice-2-intro.png', fullPage: true });
  await alice.getByRole('button', { name: "C'est parti" }).click();
  await alice.getByRole('heading', { name: 'Respiration costale' }).waitFor();
  await alice.getByText('Échauffement · 1 sur 3').waitFor();
  const t1 = await alice.getByRole('timer').innerText();
  await alice.waitForTimeout(1600);
  const t2 = await alice.getByRole('timer').innerText();
  const secs = (t) => t.split(':').reduce((a, x) => a * 60 + Number(x), 0);
  assert.ok(secs(t2) < secs(t1), `le minuteur doit défiler (${t1} -> ${t2})`);
  ok('le minuteur défile');
  await alice.screenshot({ path: SHOTS + 'alice-3-exercice.png', fullPage: true });

  await alice.getByRole('button', { name: 'Pause' }).click();
  const p1 = await alice.getByRole('timer').innerText();
  await alice.waitForTimeout(1300);
  assert.equal(await alice.getByRole('timer').innerText(), p1);
  await alice.getByRole('button', { name: 'Reprendre' }).click();
  ok('pause et reprise du minuteur');

  // jusqu'au dead bug (4e du circuit) : 3 échauffements + 3 repos, puis 3 exercices + 3 repos
  await advance(alice, 12);
  await alice.getByRole('heading', { name: 'Dead bug' }).waitFor();
  await alice.getByText('Tour 1 sur 2 · Exercice 4 sur 6').waitFor();
  await alice.getByText('Niveau 2 : Bras et jambe opposés').waitFor();

  await alice.getByRole('button', { name: 'Ça fait mal' }).click();
  const chooser = alice.getByRole('dialog', { name: "Changer d'exercice" });
  await chooser.waitFor();
  await chooser.locator('.swap-option').first().waitFor();
  const proposed = await chooser.locator('.swap-option').count();
  assert.ok(proposed >= 1 && proposed <= 2, `1 à 2 propositions (${proposed})`);
  assert.equal(await alice.getByRole('heading', { name: "Comment ça s'est passé ?" }).count(), 0);
  await alice.screenshot({ path: SHOTS + 'alice-3b-ca-fait-mal.png', fullPage: true });
  ok('« Ça fait mal » propose un autre exercice sans couper la séance');

  const replacement = (await chooser.locator('.swap-option').first().locator('.grow > div').first().innerText()).trim();
  await chooser.getByRole('button', { name: 'Choisir' }).first().click();
  await alice.getByRole('heading', { name: replacement }).waitFor();
  await alice.getByText(/remplace « Dead bug »/).waitFor();
  ok(`la séance continue avec « ${replacement} » à la place du dead bug`);
  await alice.getByRole('button', { name: 'Reprendre' }).click();
  await advance(alice, 1);
  await endSession(alice);
  await alice.getByRole('heading', { name: "Comment ça s'est passé ?" }).waitFor();

  // bilan fidèle : seuls les exercices faits, aucune pré-coche
  const rowing = exerciseBox(alice, "Rowing assis");
  const pallof = exerciseBox(alice, 'Pallof press');
  await rowing.waitFor();
  await pallof.waitFor();
  assert.equal(await pallof.locator('[aria-pressed="true"]').count(), 0);
  assert.equal(await exerciseBox(alice, 'Bird-dog').count(), 0);
  assert.equal(await exerciseBox(alice, 'Étirement').count(), 0);
  ok('le bilan ne liste que les exercices faits, sans « Bien » pré-coché');
  const deadBug = exerciseBox(alice, 'Dead bug');
  await deadBug.getByText('Douleur signalée').waitFor();
  await exerciseBox(alice, replacement).getByText(/Pris à la place de « Dead bug »/).waitFor();
  ok('le dead bug est marqué douloureux, son remplaçant est rattaché');

  const submit = alice.getByRole('button', { name: 'Enregistrer ma séance' });
  assert.equal(await submit.isDisabled(), true);
  await alice.getByRole('button', { name: 'Douleur 5 sur 10' }).click();
  await noSymptom(alice);
  assert.equal(await submit.isDisabled(), true);
  ok('impossible d\'enregistrer sans score d\'effort (RPE)');
  await alice.getByRole('button', { name: 'Effort 6 sur 10' }).click();
  await alice.getByText('6 · Dur +').waitFor();
  await pallof.getByRole('button', { name: 'Trop facile' }).click();
  await rowing.getByRole('button', { name: "J'aime" }).click();
  const pull = exerciseBox(alice, 'Écarté');
  await pull.getByRole('button', { name: 'À changer' }).click();
  await pull.locator('.swap-option').nth(1).waitFor();
  assert.equal(await pull.locator('.swap-option').count(), 2);
  const pullTo = (await pull.locator('.swap-option').first().locator('.grow > div').first().innerText()).trim();
  await pull.getByRole('button', { name: 'Choisir' }).first().click();
  await alice.getByLabel('Un mot pour ton coach').fill('Un peu tiré entre les omoplates.');
  await alice.screenshot({ path: SHOTS + 'alice-4-bilan.png', fullPage: true });
  ok('« À changer » propose 2 exercices équivalents, un est choisi');
  await submit.click();
  await alice.getByRole('heading', { name: 'Bravo Alice !' }).waitFor();
  await alice.getByText('Mis de côté 10 jours').waitFor();
  await alice.getByText('Douleur au-dessus de 3').waitFor();
  await alice.getByText('Programme adapté').waitFor();
  ok('séance enregistrée : dead bug mis de côté 10 jours, conseil douleur > 3, remplacement annoncé');
  await alice.screenshot({ path: SHOTS + 'alice-5-resultat.png', fullPage: true });

  const { rows: [w1] } = await mock.db.query(
    `select rpe, duration_min, extract(epoch from (now() - done_at)) as age from public.workouts where session_key = 'A' order by done_at desc limit 1`);
  assert.equal(w1.rpe, 6);
  assert.ok(w1.duration_min >= 1);
  assert.ok(Number(w1.age) < 60);
  const { rows: prefs } = await mock.db.query(
    `select wi.exercise_id, wi.preference, wi.feeling from public.workout_items wi order by wi.exercise_id`);
  assert.ok(prefs.some((r) => r.exercise_id === 'rowing' && r.preference === 'aime'));
  assert.ok(prefs.some((r) => r.exercise_id === 'dead_bug' && r.feeling === 'douleur'));
  ok('durée, effort, date réelle et préférences bien enregistrés');
  const { rows: progA } = await mock.db.query(`select exercise_id from public.program_items where session_key = 'A' and active`);
  assert.equal(progA.some((r) => r.exercise_id === 'pull_apart'), false);
  assert.equal(progA.some((r) => r.exercise_id === 'dead_bug'), true);
  ok('le remplacement choisi à l\'écran de bilan est appliqué au programme');

  const { rows: blocks } = await mock.db.query(
    `select exercise_id, extract(epoch from (until - now())) / 86400 as days from public.exercise_blocks`);
  const deadBugBlock = blocks.find((b) => b.exercise_id === 'dead_bug');
  assert.ok(deadBugBlock && Number(deadBugBlock.days) > 9.9, 'tampon de 10 jours sur le dead bug');
  const { rows: autoLc } = await mock.db.query(`select count(*)::int n from public.level_changes where source = 'auto'`);
  assert.equal(autoLc[0].n, 0, 'plus de baisse de niveau automatique');
  ok('« Ça fait mal » pose un tampon de 10 jours, sans baisse de niveau');
  await alice.getByRole('button', { name: "Retour à l'accueil" }).click();

  // ------------------------------------------------------------------
  console.log('Coach : alertes et propositions');
  await coach.getByRole('button', { name: 'Actualiser' }).click();
  await coach.getByText('Un peu tiré entre les omoplates.').first().waitFor();
  await coach.getByText(/douleur 5\/10/).first().waitFor();
  await coach.getByText(/effort 6\/10/).first().waitFor();
  ok('alerte visible avec douleur, effort et commentaire');
  await coach.locator('output', { hasText: '1/4' }).first().waitFor();
  assert.equal(await coach.getByText(/Dead bug.*: 2 → 1/).count(), 0);
  ok('plus de baisse de niveau automatique au journal (V5 : tampon de 10 jours à la place)');
  await coach.getByText("Changements d'exercices").waitFor();
  await coach.locator('.list-row', { hasText: 'athlète' }).first().waitFor();
  ok('le remplacement fait par Alice apparaît au journal, signé « athlète »');

  // 2e séance « trop facile » sur le Pallof press, sans douleur
  const quickSession = async (pain) => {
    await alice.getByRole('button', { name: 'Séances' }).click();
    await alice.getByRole('button', { name: /^A Renforcement A/ }).click();
    await alice.getByRole('button', { name: "C'est parti" }).click();
    await advance(alice, 11); // jusqu'à la fin du Pallof press
    await endSession(alice);
    await alice.getByRole('button', { name: `Douleur ${pain} sur 10` }).click();
    await noSymptom(alice);
    await alice.getByRole('button', { name: 'Effort 4 sur 10' }).click();
    await exerciseBox(alice, 'Pallof press').getByRole('button', { name: 'Trop facile' }).click();
    await alice.getByRole('button', { name: 'Enregistrer ma séance' }).click();
    await alice.getByRole('heading', { name: 'Bravo Alice !' }).waitFor();
  };
  await quickSession(1);

  await coach.getByRole('button', { name: 'Actualiser' }).click();
  // le premier « trop facile » était avec douleur 5 : pas de proposition
  assert.equal(await coach.getByText(/Alice · Pallof press/).count(), 0);
  ok('pas de proposition quand une des deux séances avait une douleur > 3');

  await alice.getByRole('button', { name: "Retour à l'accueil" }).click();
  await quickSession(0);

  await coach.getByRole('button', { name: 'Actualiser' }).click();
  await coach.getByText('Alice · Pallof press').waitFor();
  ok('deux « trop facile » sans douleur : proposition à valider');
  await coach.screenshot({ path: SHOTS + 'coach-2-proposition.png', fullPage: true });
  await coach.getByRole('button', { name: 'Valider' }).click();
  await coach.getByText('Aucune proposition de montée de niveau.').waitFor();
  await coach.getByText(/Pallof press.*: 1 → 2/).waitFor();
  ok('validation : Pallof press passe au niveau 2');

  // ------------------------------------------------------------------
  console.log('Bibliothèque');
  await alice.getByRole('button', { name: "Retour à l'accueil" }).click();
  await alice.getByRole('button', { name: 'Exercices' }).click();
  await alice.getByRole('heading', { name: 'Bibliothèque' }).waitFor();
  await alice.getByPlaceholder('Chercher un exercice').fill('clamshell');
  await alice.getByText('Aucun exercice ne correspond.').waitFor();
  ok('côté Alice, un exercice non validé n\'apparaît pas');
  await alice.getByPlaceholder('Chercher un exercice').fill('dead bug');
  await alice.getByRole('button', { name: /Dead bug/ }).click();
  await alice.getByText('Comment faire').waitFor();
  await alice.getByText('Dans ton programme').first().waitFor();
  await alice.screenshot({ path: SHOTS + 'alice-8-bibliotheque.png', fullPage: true });
  ok('côté Alice : recherche et fiche d\'un exercice, repère « dans ton programme »');

  await coach.getByRole('tab', { name: /Bibliothèque/ }).click();
  await coach.getByRole('heading', { name: 'Bibliothèque' }).waitFor();
  await coach.getByText(/18 à valider/).first().waitFor();
  await coach.getByLabel(/Seulement ceux à valider/).check();
  await coach.getByText('18 exercices').waitFor();
  await coach.getByRole('button', { name: /Clamshell/ }).click();
  await coach.getByText(/Source :/).waitFor();
  await coach.screenshot({ path: SHOTS + 'coach-4-bibliotheque.png', fullPage: true });
  await coach.getByRole('button', { name: 'Valider', exact: true }).click();
  await coach.getByText('17 exercices').waitFor();
  ok('le coach valide un exercice de la bibliothèque (18 → 17 à valider)');

  await coach.getByRole('button', { name: '+ Nouvel exercice' }).click();
  await coach.getByLabel('Nom', { exact: true }).fill('Montée de genou sur élastique');
  await coach.getByRole('button', { name: 'Fessiers' }).click();
  await coach.getByRole('button', { name: 'Élastique', exact: true }).click();
  await coach.getByLabel(/Niveaux/).fill('Facile | 30\nNormal | 45');
  await coach.getByLabel(/Consignes/).fill('Dos neutre\nSouffle régulier');
  await coach.getByRole('button', { name: 'Enregistrer', exact: true }).click();
  await coach.getByRole('heading', { name: 'Bibliothèque' }).waitFor();
  await coach.getByLabel(/Seulement ceux à valider/).uncheck();
  await coach.getByPlaceholder('Chercher un exercice').fill('montée de genou');
  await coach.getByRole('button', { name: /Montée de genou sur élastique/ }).click();
  await coach.getByRole('button', { name: 'Valider', exact: true }).click();
  await coach.getByRole('button', { name: 'Retirer la validation' }).waitFor();
  ok('le coach crée un exercice, puis le valide');

  await alice.reload();
  await alice.getByRole('button', { name: 'Exercices' }).click();
  await alice.getByPlaceholder('Chercher un exercice').fill('clamshell');
  await alice.getByRole('button', { name: /Clamshell/ }).waitFor();
  await alice.getByPlaceholder('Chercher un exercice').fill('montée de genou');
  await alice.getByRole('button', { name: /Montée de genou sur élastique/ }).waitFor();
  ok('une fois validés, les exercices apparaissent chez Alice');

  // ------------------------------------------------------------------
  console.log('Coach : éditeur de programme');
  await coach.getByRole('tab', { name: 'Athlètes' }).click();
  await coach.getByRole('heading', { name: 'Alice', exact: true }).waitFor();

  const sets = coach.getByLabel("Nombre de tours pour Rowing assis à l'élastique");
  await sets.selectOption('4');
  await coach.waitForTimeout(600);
  const { rows: [{ sets: rowingSets }] } = await mock.db.query(`select sets from public.program_items where exercise_id = 'rowing' and session_key = 'A'`);
  assert.equal(rowingSets, 4);
  ok('le coach passe le rowing à 4 tours');

  await coach.getByRole('button', { name: "Déplacer vers le bas : Rowing assis à l'élastique" }).click();
  await coach.waitForTimeout(400);
  const { rows: order } = await mock.db.query(
    `select exercise_id from public.program_items where session_key = 'A' and block = 'main' and active order by position`);
  assert.notEqual(order[0].exercise_id, 'rowing');
  ok('le coach change l\'ordre des exercices');

  await coach.getByRole('button', { name: 'Changer' }).nth(0).waitFor();
  await coach.locator('.list-row', { hasText: 'Bird-dog' }).getByRole('button', { name: 'Changer' }).click();
  await coach.getByRole('dialog', { name: /Remplacer/ }).waitFor();
  await coach.getByRole('dialog').getByRole('button', { name: /Planche latérale/ }).click();
  await coach.getByRole('dialog').getByRole('button', { name: 'Remplacer par celui-ci' }).click();
  await coach.getByRole('dialog').waitFor({ state: 'detached' });
  const { rows: afterSwap } = await mock.db.query(`select exercise_id from public.program_items where session_key = 'A' and active`);
  assert.equal(afterSwap.some((r) => r.exercise_id === 'bird_dog'), false);
  assert.equal(afterSwap.some((r) => r.exercise_id === 'planche_laterale'), true);
  ok('le coach remplace le bird-dog par la planche latérale');

  await coach.getByRole('button', { name: '+ Ajouter' }).first().click();
  await coach.getByRole('dialog', { name: /Ajouter/ }).getByPlaceholder('Chercher un exercice').fill('clamshell');
  await coach.getByRole('dialog').getByRole('button', { name: /Clamshell/ }).click();
  await coach.getByRole('dialog').getByRole('button', { name: 'Ajouter', exact: true }).click();
  await coach.getByRole('dialog').waitFor({ state: 'detached' });
  const { rows: afterAdd } = await mock.db.query(`select 1 from public.program_items where session_key = 'A' and exercise_id = 'clamshell' and active`);
  assert.equal(afterAdd.length, 1);
  ok('le coach ajoute un exercice du catalogue');
  await coach.screenshot({ path: SHOTS + 'coach-5-programme.png', fullPage: true });

  await coach.getByRole('button', { name: 'Retirer Clamshell (coquillage)' }).click();
  await coach.waitForTimeout(400);
  const { rows: afterRemove } = await mock.db.query(`select 1 from public.program_items where session_key = 'A' and exercise_id = 'clamshell' and active`);
  assert.equal(afterRemove.length, 0);
  ok('le coach retire un exercice');

  // Alice voit les 4 tours dans le lecteur
  await alice.reload();
  await alice.getByRole('button', { name: 'Séances' }).click();
  await alice.getByRole('button', { name: /^A Renforcement A/ }).click();
  await alice.getByText(/4 tours/).first().waitFor();
  ok('Alice voit le nouveau nombre de tours avant de commencer');
  await alice.getByRole('button', { name: "C'est parti" }).click();
  await next(alice, 6); // sortie de l'échauffement
  await alice.getByText(/Tour 1 sur 4/).waitFor();
  ok('le circuit passe à 4 tours pour cet exercice');

  // le coach garde la main : plus de changement possible côté Alice
  await coach.getByLabel(/peut changer un exercice elle-même/).click();
  await coach.waitForTimeout(500);
  await alice.getByRole('button', { name: 'Terminer la séance' }).click();
  await alice.getByRole('button', { name: 'Oui, terminer' }).click();
  await alice.getByRole('button', { name: 'Douleur 0 sur 10' }).click();
  await noSymptom(alice);
  await alice.getByRole('button', { name: 'Effort 2 sur 10' }).click();
  await alice.getByRole('button', { name: 'Enregistrer ma séance' }).click();
  await alice.getByRole('heading', { name: 'Bravo Alice !' }).waitFor();
  await alice.getByRole('button', { name: "Retour à l'accueil" }).click();
  await alice.reload();
  await alice.getByRole('button', { name: 'Séances' }).click();
  await alice.getByRole('button', { name: /^A Renforcement A/ }).click();
  await alice.getByRole('button', { name: "C'est parti" }).click();
  await next(alice, 6);
  assert.equal(await alice.getByRole('button', { name: 'Ne me convient pas' }).count(), 0);
  await alice.getByRole('button', { name: 'Ça fait mal' }).click();
  await alice.getByText(/garder la main/).waitFor();
  await alice.getByRole('button', { name: 'Annuler' }).click();
  await endSession(alice);
  await alice.getByRole('button', { name: 'Douleur 0 sur 10' }).click();
  await noSymptom(alice);
  await alice.getByRole('button', { name: 'Effort 1 sur 10' }).click();
  await alice.getByRole('button', { name: 'Enregistrer ma séance' }).click();
  await alice.getByRole('heading', { name: 'Bravo Alice !' }).waitFor();
  ok('quand le coach garde la main, Alice ne peut plus changer d\'exercice');
  await coach.getByLabel(/peut changer un exercice elle-même/).click();
  await coach.waitForTimeout(400);
  await alice.getByRole('button', { name: "Retour à l'accueil" }).click();

  // ------------------------------------------------------------------
  console.log('Hors connexion');
  await alice.getByRole('button', { name: 'Séances' }).click();
  await alice.getByRole('button', { name: /^♡ Cardio doux/ }).click();
  await aliceCtx.setOffline(true);
  await alice.getByRole('button', { name: "J'ai terminé" }).click();
  await alice.getByRole('button', { name: 'Douleur 2 sur 10' }).click();
  // V5 : plus de question sur les symptômes
  await alice.getByRole('button', { name: 'Effort 3 sur 10' }).click();
  await alice.getByRole('button', { name: 'Enregistrer ma séance' }).click();
  await alice.getByText(/ta séance est gardée sur ton téléphone/).waitFor();
  ok('sans réseau, la séance est gardée sur le téléphone');
  await alice.getByRole('button', { name: "Retour à l'accueil" }).click();
  await alice.getByText(/1 séance en attente d'envoi/).waitFor();
  await alice.waitForTimeout(2000);
  await aliceCtx.setOffline(false);
  // l'app renvoie d'elle-même au retour du réseau (événement « online ») ;
  // sinon, le bouton Réessayer le fait
  await alice.evaluate(() => window.dispatchEvent(new Event('online')));
  await alice.getByText(/en attente d'envoi/).waitFor({ state: 'detached' });
  const { rows: [{ n, lag }] } = await mock.db.query(
    `select count(*)::int n, max(extract(epoch from (now() - done_at))) lag from public.workouts where session_key = 'C'`);
  assert.equal(n, 1);
  assert.ok(Number(lag) >= 1.5, `la séance garde l'heure à laquelle elle a été faite (écart ${lag} s)`);
  ok('au retour du réseau, la séance est envoyée une seule fois, avec sa vraie date');

  // propositions de remplacement sans réseau : calculées sur la bibliothèque gardée sur le téléphone
  await alice.getByRole('button', { name: 'Séances' }).click();
  await alice.getByRole('button', { name: /^A Renforcement A/ }).click();
  await alice.getByRole('button', { name: "C'est parti" }).click();
  await next(alice, 6);
  await aliceCtx.setOffline(true);
  await alice.getByRole('button', { name: 'Ça fait mal' }).click();
  await alice.getByRole('dialog').locator('.swap-option').first().waitFor();
  ok('sans réseau, « Ça fait mal » propose quand même des exercices');
  await aliceCtx.setOffline(false);
  await alice.getByRole('button', { name: 'Annuler' }).click();
  await endSession(alice);
  await alice.getByRole('button', { name: 'Douleur 0 sur 10' }).click();
  await noSymptom(alice);
  await alice.getByRole('button', { name: 'Effort 1 sur 10' }).click();
  await alice.getByRole('button', { name: 'Enregistrer ma séance' }).click();
  await alice.getByRole('heading', { name: 'Bravo Alice !' }).waitFor();
  await alice.getByRole('button', { name: "Retour à l'accueil" }).click();

  // ------------------------------------------------------------------
  console.log('Plus de gel du programme');
  await alice.getByRole('button', { name: 'Séances' }).click();
  await alice.getByRole('button', { name: /^M Mobilité/ }).click();
  await alice.getByRole('button', { name: "C'est parti" }).click();
  await alice.getByRole('heading', { name: 'Respiration costale' }).waitFor();
  await endSession(alice);
  await alice.getByRole('button', { name: 'Douleur 2 sur 10' }).click();
  await alice.getByRole('button', { name: 'Effort 2 sur 10' }).click();
  assert.equal(await alice.locator('fieldset', { hasText: 'fourmillements' }).count(), 0);
  await alice.getByRole('button', { name: 'Enregistrer ma séance' }).click();
  await alice.getByRole('heading', { name: 'Bravo Alice !' }).waitFor();
  assert.equal(await alice.getByRole('heading', { name: 'On fait une pause, Alice.' }).count(), 0);
  ok('le bilan ne demande plus les symptômes et ne met jamais le programme en pause');
  await alice.getByRole('button', { name: "Retour à l'accueil" }).click();
  await alice.getByRole('button', { name: 'Aujourd\'hui' }).click();
  await alice.getByRole('heading', { name: 'Bonjour Alice !' }).waitFor();

  await alice.getByRole('button', { name: 'Progrès' }).click();
  await alice.getByRole('heading', { name: 'Ma progression' }).waitFor();
  await alice.getByText('Mes dernières séances').waitFor();
  await alice.screenshot({ path: SHOTS + 'alice-7-progres.png', fullPage: true });
  ok('écran de progression avec durée et effort des dernières séances');

  // ------------------------------------------------------------------
  console.log('V3 : séance honnête, reprise, semaine, compteur, montée autonome');

  // Appuyer sur « Étape suivante » sans rien faire ne valide aucun exercice
  await alice.getByRole('button', { name: 'Séances' }).click();
  await alice.getByRole('button', { name: /^B Renforcement B/ }).click();
  await alice.getByRole('button', { name: "C'est parti" }).click();
  await alice.getByRole('timer').waitFor();
  while (await alice.getByRole('button', { name: 'Étape suivante' }).count()) {
    await alice.getByRole('button', { name: 'Étape suivante' }).click();
  }
  await alice.getByRole('heading', { name: "Comment ça s'est passé ?" }).waitFor();
  assert.equal(await alice.locator('fieldset', { hasText: 'Pont fessier' }).count(), 0, 'aucun exercice faux « fait »');
  assert.equal(await alice.locator('fieldset', { hasText: 'Hip thrust' }).count(), 0);
  ok('passer toutes les étapes sans faire les exercices n\'en valide aucun');

  // La page se recharge avant l'envoi du ressenti : la séance terminée est retrouvée
  await alice.reload();
  await alice.getByRole('heading', { name: 'Bonjour Alice !' }).waitFor();
  await alice.getByText('Ta séance est terminée').waitFor();
  await alice.getByRole('button', { name: 'Donner mon ressenti' }).click();
  await alice.getByRole('heading', { name: "Comment ça s'est passé ?" }).waitFor();
  ok('après un rechargement, le ressenti d\'une séance terminée peut encore être donné');
  const total0 = (await mock.db.query(`select count(*)::int n from public.workouts`)).rows[0].n;
  await alice.getByRole('button', { name: 'Douleur 0 sur 10' }).click();
  await noSymptom(alice);
  await alice.getByRole('button', { name: 'Effort 1 sur 10' }).click();
  await alice.getByRole('button', { name: 'Enregistrer ma séance' }).click();
  await alice.getByRole('heading', { name: 'Bravo Alice !' }).waitFor();
  await alice.getByRole('button', { name: "Retour à l'accueil" }).click();
  assert.equal(await alice.getByText('Ta séance est terminée').count(), 0);
  ok('une fois envoyée, la séance en attente disparaît de l\'accueil');

  // Reprise en cours de séance
  await alice.getByRole('button', { name: 'Séances' }).click();
  await alice.getByRole('button', { name: /^A Renforcement A/ }).click();
  await alice.getByRole('button', { name: "C'est parti" }).click();
  await alice.getByRole('heading', { name: 'Respiration costale' }).waitFor();
  await advance(alice, 3);
  const headingBefore = await alice.getByRole('heading').first().innerText();
  await alice.waitForTimeout(300);
  await alice.reload();
  await alice.getByText('Séance en cours').waitFor();
  await alice.getByRole('button', { name: 'Reprendre la séance' }).click();
  await alice.getByRole('timer').waitFor();
  assert.equal(await alice.getByRole('heading').first().innerText(), headingBefore);
  assert.equal(await alice.getByRole('button', { name: 'Reprendre' }).count(), 1, 'la séance reprend en pause');
  ok('après un rechargement, la séance en cours reprend au même exercice');
  await alice.screenshot({ path: SHOTS + 'alice-8-reprise.png', fullPage: true });
  await endSession(alice);
  await alice.getByRole('heading', { name: "Comment ça s'est passé ?" }).waitFor();
  const done = await alice.locator('fieldset').count();
  // les 3 étapes d'échauffement déjà faites ne sont pas des exercices du circuit : le bilan reste vide de circuit
  assert.ok(done <= 6, 'seul ce qui a été fait est listé');
  await alice.getByRole('button', { name: 'Douleur 0 sur 10' }).click();
  await noSymptom(alice);
  await alice.getByRole('button', { name: 'Effort 2 sur 10' }).click();
  await alice.getByRole('button', { name: 'Enregistrer ma séance' }).click();
  await alice.getByRole('heading', { name: 'Bravo Alice !' }).waitFor();
  await alice.getByRole('button', { name: "Retour à l'accueil" }).click();
  assert.equal(await alice.getByText('Séance en cours').count(), 0);
  ok('la séance reprise puis enregistrée ne laisse rien en attente');

  // Compteur de séances
  const totalNow = (await mock.db.query(`select count(*)::int n from public.workouts`)).rows[0].n;
  assert.equal(totalNow, total0 + 2);
  await alice.reload();
  await alice.getByRole('heading', { name: 'Bonjour Alice !' }).waitFor();
  const nums = await alice.locator('.stats-row .stat-n').allInnerTexts();
  assert.equal(Number(nums[0]), totalNow, `compteur total (${nums})`);
  assert.ok(Number(nums[1]) >= 2 && Number(nums[2]) >= 1);
  ok(`le compteur affiche ${nums[0]} séances, ${nums[1]} cette semaine, ${nums[2]} semaine(s) de suite`);
  await alice.screenshot({ path: SHOTS + 'alice-9-compteur.png', fullPage: true });

  // Organiser sa semaine
  const DAYS = ['Dimanche', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'];
  const dow = new Date().getDay();
  const todayIdx = (dow + 6) % 7;
  await alice.getByRole('button', { name: 'Séances' }).click();
  await alice.getByRole('button', { name: 'Organiser ma semaine' }).click();
  const daySelect = (name) => alice.getByLabel(new RegExp(`^${name}`));
  for (const d of ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi']) await daySelect(d).selectOption('A');
  await alice.getByText(/5 jours de renforcement/).waitFor();
  assert.equal(await alice.getByRole('button', { name: 'Enregistrer ma semaine' }).isDisabled(), true);
  ok('plus de 4 jours de renforcement : avertissement et enregistrement bloqué');
  await daySelect('Vendredi').selectOption('R');
  await daySelect(DAYS[dow]).selectOption('R');
  await alice.getByRole('button', { name: 'Enregistrer ma semaine' }).click();
  await alice.getByRole('button', { name: 'Organiser ma semaine' }).waitFor();
  const plan = (await mock.db.query(`select week_plan from public.athletes limit 1`)).rows[0].week_plan;
  assert.equal(plan[todayIdx], 'R');
  ok('Alice enregistre sa semaine type');
  await alice.getByRole('button', { name: "Aujourd'hui" }).click();
  await alice.getByText('Jour de repos').waitFor();
  await alice.getByRole('button', { name: "J'ai quand même envie de bouger" }).waitFor();
  ok('un jour de repos choisi s\'affiche à l\'accueil, avec la possibilité de bouger quand même');
  await alice.screenshot({ path: SHOTS + 'alice-10-repos.png', fullPage: true });

  await coach.getByRole('button', { name: 'Actualiser' }).click();
  await coach.getByRole('heading', { name: 'Autonomie de Alice' }).waitFor();
  await poll(async () => (await coach.getByLabel(new RegExp(`^${DAYS[dow]}`)).inputValue()) === 'R');
  await coach.getByRole('button', { name: 'Semaine par défaut' }).click();
  await poll(async () => (await mock.db.query(`select week_plan from public.athletes limit 1`)).rows[0].week_plan === null);
  await alice.reload();
  await alice.getByRole('heading', { name: 'Bonjour Alice !' }).waitFor();
  await alice.getByText('Jour de repos').waitFor({ state: 'detached', timeout: 5000 });
  assert.equal((await mock.db.query(`select week_plan from public.athletes limit 1`)).rows[0].week_plan, null);
  ok('le coach voit la semaine d\'Alice et peut remettre la semaine par défaut');

  // Montée de niveau autonome (on vieillit les séances d'un jour : la limite anti-abus est de 12 séances par 24 h)
  await mock.db.query(`update public.workouts set done_at = done_at - interval '1 day'`);
  await coach.getByLabel(/Alice choisit librement/).click();
  await poll(async () => (await mock.db.query(`select levelup_mode from public.athletes limit 1`)).rows[0].levelup_mode === 'self');
  ok('le coach active la montée autonome pour Alice');
  // un « trop facile » déjà noté sur le rowing à la séance précédente (les deux derniers ressentis comptent), au niveau actuel
  await mock.db.query(`
    with w as (insert into public.workouts (athlete_id, session_key, done_at, pain, neuro)
               select id, 'A', now() - interval '1 second', 1, false from public.athletes limit 1 returning id)
    insert into public.workout_items (workout_id, exercise_id, level, feeling)
    select w.id, 'rowing', (select level from public.program_items where exercise_id = 'rowing' and active limit 1), 'facile' from w`);
  await alice.getByRole('button', { name: 'Séances' }).click();
  await alice.getByRole('button', { name: /^A Renforcement A/ }).click();
  await alice.getByRole('button', { name: "C'est parti" }).click();
  await alice.getByRole('timer').waitFor();
  for (let i = 0; i < 60; i++) {
    if (await alice.getByRole('heading', { name: /^Rowing assis/ }).count()) break;
    await advance(alice, 1);
  }
  await alice.getByRole('heading', { name: /^Rowing assis/ }).waitFor();
  await advance(alice, 1);
  await endSession(alice);
  await alice.getByRole('heading', { name: "Comment ça s'est passé ?" }).waitFor();
  await alice.getByRole('button', { name: 'Douleur 1 sur 10' }).click();
  await noSymptom(alice);
  await alice.getByRole('button', { name: 'Effort 3 sur 10' }).click();
  await exerciseBox(alice, 'Rowing assis').getByRole('button', { name: 'Trop facile' }).click();
  await alice.getByRole('button', { name: 'Enregistrer ma séance' }).click();
  await alice.getByRole('heading', { name: 'Bravo Alice !' }).waitFor();
  await alice.getByText("Tu montes d'un niveau").waitFor();
  const rowLvl = (await mock.db.query(`select level from public.program_items where exercise_id = 'rowing' and active limit 1`)).rows[0].level;
  assert.equal(rowLvl, 2);
  ok('en mode autonome, Alice monte d\'un niveau et en est informée');
  await alice.screenshot({ path: SHOTS + 'alice-11-monte.png', fullPage: true });
  // niveau choisi pendant la séance : « Plus dur » sur le premier exercice
  await alice.getByRole('button', { name: "Retour à l'accueil" }).click();
  await alice.getByRole('button', { name: 'Séances' }).click();
  await alice.getByRole('button', { name: /^M Mobilité/ }).click();
  await alice.getByRole('button', { name: "C'est parti" }).click();
  await alice.getByRole('timer').waitFor();
  const exName1 = await alice.getByRole('heading').first().innerText();
  const lvText = await alice.getByText(/^Niveau \d+ sur \d+$/).innerText();
  const [, lvNow, lvMax] = lvText.match(/(\d+) sur (\d+)/).map(Number);
  assert.ok(lvNow < lvMax, `un niveau plus dur existe pour ${exName1}`);
  await alice.getByRole('button', { name: 'Plus dur' }).click();
  await alice.getByText(`Niveau ${lvNow + 1} sur ${lvMax}`).waitFor();
  await alice.screenshot({ path: SHOTS + 'alice-12-plus-dur.png', fullPage: true });
  await endSession(alice);
  await alice.getByRole('button', { name: 'Douleur 0 sur 10' }).click();
  await noSymptom(alice);
  await alice.getByRole('button', { name: 'Effort 2 sur 10' }).click();
  await alice.getByRole('button', { name: 'Enregistrer ma séance' }).click();
  await alice.getByRole('heading', { name: 'Bravo Alice !' }).waitFor();
  const lvlDb = (await mock.db.query(
    `select pi.level from public.program_items pi join public.exercises e on e.id = pi.exercise_id where e.name = $1 and pi.session_key = 'M' and pi.active limit 1`, [exName1])).rows[0].level;
  assert.equal(lvlDb, lvNow + 1);
  ok(`« Plus dur » en séance : ${exName1} passe au niveau ${lvNow + 1}, sans validation`);

  // niveau choisi depuis l'écran Progrès, dans l'autre sens
  await alice.getByRole('button', { name: "Retour à l'accueil" }).click();
  await alice.getByRole('button', { name: 'Progrès' }).click();
  await alice.getByRole('button', { name: /^Plus facile : Rowing assis/ }).click();
  await poll(async () => (await mock.db.query(`select level from public.program_items where exercise_id = 'rowing' and active limit 1`)).rows[0].level === 1);
  ok('depuis « Progrès », Alice redescend un exercice d\'un niveau');
  await alice.screenshot({ path: SHOTS + 'alice-13-progres-niveaux.png', fullPage: true });

  await coach.getByRole('button', { name: 'Actualiser' }).click();
  await coach.getByText('athlète (autonome)').first().waitFor();
  ok('le journal des niveaux du coach indique la montée autonome');
  await coach.getByLabel(/Moi, après proposition/).click();
  await poll(async () => (await mock.db.query(`select levelup_mode from public.athletes limit 1`)).rows[0].levelup_mode === 'coach');
  ok('le coach peut revenir à la validation par ses soins');

  // ------------------------------------------------------------------
  console.log('Changement de lien');
  await coach.getByRole('button', { name: 'Changer le lien…' }).click();
  await coach.getByRole('button', { name: 'Confirmer' }).click();
  await coach.waitForFunction((old) => document.querySelector('input[aria-label="Lien personnel"]')?.value !== old, link);
  await alice.reload();
  await alice.getByRole('button', { name: 'Aujourd\'hui' }).click();
  // l'ancien lien affiche la version gardée en cache mais le serveur le refuse
  const { rows: [{ ok: stillValid }] } = await mock.db.query(`select exists(select 1 from public.athletes where access_token = $1) ok`, [link.split('/a/')[1]]);
  assert.equal(stillValid, false);
  ok('l\'ancien lien est désactivé');

  assert.deepEqual(errors, [], 'aucune erreur JavaScript dans la console');
  ok('aucune erreur JavaScript pendant les parcours');
  console.log(`\n${passed} vérifications réussies. Captures : tests/screens/`);
} catch (e) {
  console.error('\nÉCHEC :', e.message);
  if (errors.length) console.error('Erreurs console :', errors);
  process.exitCode = 1;
} finally {
  await browser.close();
  preview.kill();
  await mock.close();
}
