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
  await coach.getByRole('button', { name: 'Enregistrer' }).click();
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
  await alice.getByRole('button', { name: /^A Renforcement A/ }).click();
  await alice.getByRole('heading', { name: 'Renforcement A' }).waitFor();
  await alice.screenshot({ path: SHOTS + 'alice-2-intro.png', fullPage: true });
  await alice.getByRole('button', { name: "C'est parti" }).click();
  await alice.getByRole('heading', { name: 'Rowing assis à l\'élastique' }).waitFor();
  const t1 = await alice.getByRole('timer').innerText();
  await alice.waitForTimeout(1600);
  const t2 = await alice.getByRole('timer').innerText();
  assert.ok(Number(t2) < Number(t1), `le minuteur doit défiler (${t1} -> ${t2})`);
  ok('le minuteur défile');
  await alice.screenshot({ path: SHOTS + 'alice-3-exercice.png', fullPage: true });

  await alice.getByRole('button', { name: 'Pause' }).click();
  const p1 = await alice.getByRole('timer').innerText();
  await alice.waitForTimeout(1300);
  assert.equal(await alice.getByRole('timer').innerText(), p1);
  await alice.getByRole('button', { name: 'Reprendre' }).click();
  ok('pause et reprise du minuteur');

  // avancer jusqu'au dead bug (exercice 4) : 3 exercices + 3 repos
  for (let i = 0; i < 6; i++) await alice.getByRole('button', { name: 'Étape suivante' }).click();
  await alice.getByRole('heading', { name: 'Dead bug' }).waitFor();
  await alice.getByText('Niveau 2 : Bras et jambe opposés').waitFor();
  await alice.getByRole('button', { name: 'Ça fait mal' }).click();
  await alice.getByRole('heading', { name: "Comment ça s'est passé ?" }).waitFor();
  const deadBugGroup = alice.locator('fieldset', { hasText: 'Dead bug' });
  assert.equal(await deadBugGroup.getByRole('button', { name: 'Douleur' }).getAttribute('aria-pressed'), 'true');
  ok('« Ça fait mal » ouvre le bilan avec l\'exercice marqué douloureux');

  const submit = alice.getByRole('button', { name: 'Enregistrer ma séance' });
  assert.equal(await submit.isDisabled(), true);
  ok('impossible d\'enregistrer sans douleur ni réponse sur les symptômes');
  await alice.getByRole('button', { name: 'Douleur 5 sur 10' }).click();
  await alice.locator('fieldset', { hasText: 'fourmillements' }).getByRole('button', { name: 'Non' }).click();
  await alice.locator('fieldset', { hasText: 'Pallof press' }).getByRole('button', { name: 'Trop facile' }).click();
  await alice.getByLabel('Un mot pour ton coach').fill('Un peu tiré entre les omoplates.');
  await alice.screenshot({ path: SHOTS + 'alice-4-bilan.png', fullPage: true });
  await submit.click();
  await alice.getByRole('heading', { name: 'Bravo Alice !' }).waitFor();
  await alice.getByText('On allège un peu').waitFor();
  await alice.getByText('Douleur au-dessus de 3').waitFor();
  ok('séance enregistrée : dead bug allégé et conseil douleur > 3');
  await alice.screenshot({ path: SHOTS + 'alice-5-resultat.png', fullPage: true });

  await alice.getByRole('button', { name: "Retour à l'accueil" }).click();
  await alice.getByText(/On a allégé : Dead bug \(niveau 1\)/).waitFor({ timeout: 5000 });
  ok('l\'accueil rappelle l\'allègement');

  // ------------------------------------------------------------------
  console.log('Coach : alertes et propositions');
  await coach.getByRole('button', { name: 'Actualiser' }).click();
  await coach.getByText('Un peu tiré entre les omoplates.').first().waitFor();
  await coach.getByText(/douleur 5\/10/).first().waitFor();
  ok('alerte visible avec douleur et commentaire');
  await coach.locator('output', { hasText: '1/4' }).first().waitFor();
  await coach.getByText(/Dead bug.*: 2 → 1/).waitFor();
  ok('régression automatique visible au journal');

  // 2e séance « trop facile » sur le Pallof press, sans douleur
  await alice.getByRole('button', { name: 'Séances' }).click();
  await alice.getByRole('button', { name: /^A Renforcement A/ }).click();
  await alice.getByRole('button', { name: "C'est parti" }).click();
  await alice.getByRole('button', { name: 'Terminer la séance' }).click();
  await alice.getByRole('button', { name: 'Oui, terminer' }).click();
  await alice.getByRole('button', { name: 'Douleur 1 sur 10' }).click();
  await alice.locator('fieldset', { hasText: 'fourmillements' }).getByRole('button', { name: 'Non' }).click();
  await alice.locator('fieldset', { hasText: 'Pallof press' }).getByRole('button', { name: 'Trop facile' }).click();
  await alice.getByRole('button', { name: 'Enregistrer ma séance' }).click();
  await alice.getByRole('heading', { name: 'Bravo Alice !' }).waitFor();

  await coach.getByRole('button', { name: 'Actualiser' }).click();
  // le premier « trop facile » était avec douleur 5 : pas de proposition
  assert.equal(await coach.getByText(/Alice · Pallof press/).count(), 0);
  ok('pas de proposition quand une des deux séances avait une douleur > 3');

  await alice.getByRole('button', { name: "Retour à l'accueil" }).click();
  await alice.getByRole('button', { name: 'Séances' }).click();
  await alice.getByRole('button', { name: /^A Renforcement A/ }).click();
  await alice.getByRole('button', { name: "C'est parti" }).click();
  await alice.getByRole('button', { name: 'Terminer la séance' }).click();
  await alice.getByRole('button', { name: 'Oui, terminer' }).click();
  await alice.getByRole('button', { name: 'Douleur 0 sur 10' }).click();
  await alice.locator('fieldset', { hasText: 'fourmillements' }).getByRole('button', { name: 'Non' }).click();
  await alice.locator('fieldset', { hasText: 'Pallof press' }).getByRole('button', { name: 'Trop facile' }).click();
  await alice.getByRole('button', { name: 'Enregistrer ma séance' }).click();
  await alice.getByRole('heading', { name: 'Bravo Alice !' }).waitFor();

  await coach.getByRole('button', { name: 'Actualiser' }).click();
  await coach.getByText('Alice · Pallof press').waitFor();
  ok('deux « trop facile » sans douleur : proposition à valider');
  await coach.screenshot({ path: SHOTS + 'coach-2-proposition.png', fullPage: true });
  await coach.getByRole('button', { name: 'Valider' }).click();
  await coach.getByText('Aucune proposition de montée de niveau.').waitFor();
  await coach.getByText(/Pallof press.*: 1 → 2/).waitFor();
  ok('validation : Pallof press passe au niveau 2');

  // ------------------------------------------------------------------
  console.log('Hors connexion');
  await alice.getByRole('button', { name: "Retour à l'accueil" }).click();
  await alice.getByRole('button', { name: 'Séances' }).click();
  await alice.getByRole('button', { name: /^♡ Cardio doux/ }).click();
  await aliceCtx.setOffline(true);
  await alice.getByRole('button', { name: "J'ai terminé" }).click();
  await alice.getByRole('button', { name: 'Douleur 2 sur 10' }).click();
  await alice.getByRole('button', { name: 'Non' }).click();
  await alice.getByRole('button', { name: 'Enregistrer ma séance' }).click();
  await alice.getByText(/ta séance est gardée sur ton téléphone/).waitFor();
  ok('sans réseau, la séance est gardée sur le téléphone');
  await alice.getByRole('button', { name: "Retour à l'accueil" }).click();
  await alice.getByText(/1 séance en attente d'envoi/).waitFor();
  await aliceCtx.setOffline(false);
  // l'app renvoie d'elle-même au retour du réseau (événement « online ») ;
  // sinon, le bouton Réessayer le fait
  await alice.evaluate(() => window.dispatchEvent(new Event('online')));
  await alice.getByText(/en attente d'envoi/).waitFor({ state: 'detached' });
  const { rows: [{ n }] } = await mock.db.query(`select count(*)::int n from public.workouts where session_key = 'C'`);
  assert.equal(n, 1);
  ok('au retour du réseau, la séance est envoyée une seule fois');

  // ------------------------------------------------------------------
  console.log('Symptôme neurologique');
  await alice.getByRole('button', { name: 'Séances' }).click();
  await alice.getByRole('button', { name: /^M Mobilité/ }).click();
  await alice.getByRole('button', { name: "C'est parti" }).click();
  await alice.getByRole('heading', { name: 'Respiration costale' }).waitFor();
  await alice.getByRole('button', { name: 'Terminer la séance' }).click();
  await alice.getByRole('button', { name: 'Oui, terminer' }).click();
  await alice.getByRole('button', { name: 'Douleur 2 sur 10' }).click();
  await alice.locator('fieldset', { hasText: 'fourmillements' }).getByRole('button', { name: 'Oui' }).click();
  await alice.getByRole('button', { name: 'Enregistrer ma séance' }).click();
  await alice.getByRole('heading', { name: 'On fait une pause, Alice.' }).waitFor();
  ok('symptôme signalé : écran de pause');
  await alice.screenshot({ path: SHOTS + 'alice-6-pause.png', fullPage: true });
  await alice.getByRole('button', { name: "Retour à l'accueil" }).click();
  await alice.getByRole('heading', { name: 'On fait une pause, Alice.' }).waitFor();
  await alice.getByRole('button', { name: 'Séances' }).click();
  assert.equal(await alice.getByRole('button', { name: /^A Renforcement A/ }).isDisabled(), true);
  ok('les séances sont bloquées tant que le programme est en pause');

  await coach.getByRole('button', { name: 'Actualiser' }).click();
  await coach.getByText('Programme en pause : Alice').waitFor();
  await coach.screenshot({ path: SHOTS + 'coach-3-pause.png', fullPage: true });
  await coach.getByRole('button', { name: 'Réactiver…' }).click();
  await coach.getByRole('button', { name: 'Oui, réactiver' }).click();
  await coach.getByText('Programme en pause : Alice').waitFor({ state: 'detached' });
  await alice.reload();
  await alice.getByRole('button', { name: 'Aujourd\'hui' }).click();
  await alice.getByRole('heading', { name: 'Bonjour Alice !' }).waitFor();
  ok('le coach réactive, Alice retrouve son programme');

  await alice.getByRole('button', { name: 'Progrès' }).click();
  await alice.getByRole('heading', { name: 'Ma progression' }).waitFor();
  await alice.screenshot({ path: SHOTS + 'alice-7-progres.png', fullPage: true });
  ok('écran de progression');

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
