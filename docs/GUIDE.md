# Guide d'utilisation et de reprise du projet

*Application de reprise d'Alice, version 1. Pour reprendre le projet dans quelques semaines sans rien avoir en tête.*

## 1. En bref

| | |
|---|---|
| **But** | Accompagner la reprise sportive d'Alice (hernie dorsale haute) avec un programme de 30 min/jour, et ajuster le programme à distance |
| **Côté Alice** | Un lien personnel secret, ouvert sur son iPhone (`https://coach-reprise.vercel.app/a/<code>`) |
| **Côté coach** | `https://coach-reprise.vercel.app/coach`, connexion par e-mail et mot de passe |
| **Code** | GitHub : `valentindupnt/coach-reprise`, branche `main` |
| **Hébergement** | Vercel (offre Hobby, gratuite) |
| **Base de données** | Supabase (offre Free, région UE) |

## 2. Qui fait quoi (les trois briques)

```
iPhone d'Alice ──► Vercel (affiche l'app) ──► Supabase (stocke et protège les données)
                          ▲
GitHub (le code) ─────────┘   chaque modification sur « main » est redéployée automatiquement
```

- **GitHub** conserve le code et son historique.
- **Vercel** fabrique le site à partir du code et le met en ligne.
- **Supabase** garde les données (séances, niveaux, douleurs) et applique les règles de sécurité.

## 3. Pourquoi Supabase ?

Une app web seule (Vercel) n'a pas de mémoire : elle affiche des pages, mais ne conserve rien. Il fallait un endroit pour stocker les séances d'Alice, ses ressentis et ses niveaux, et pour que **toi** tu les voies et les modifies depuis un autre appareil. Il fallait donc une base de données.

Pourquoi Supabase plutôt qu'une autre solution :

| Besoin | Ce que Supabase apporte |
|---|---|
| Que ton changement de niveau apparaisse chez Alice | Une base centrale partagée : tu écris, elle lit |
| Un panneau coach protégé | Connexion par e-mail et mot de passe intégrée |
| Des données de santé légères, à protéger | Règles de sécurité **dans la base** (RLS) : même avec le code de l'app, on ne peut pas lire sans autorisation |
| Des règles de sécurité impossibles à contourner | Les règles « douleur = niveau −1 » et « fourmillements = gel » sont écrites **dans la base**, pas seulement dans l'écran |
| Pas de serveur à gérer | Aucun serveur à installer ni à surveiller ; tout est géré |
| Coût | Gratuit pour ce volume (500 Mo, largement suffisant) |
| Données en Europe | Région Paris ou Francfort |
| Évolutif | La base prévoit déjà plusieurs athlètes |

Alternatives écartées : Notion (pas conçu comme base temps réel, difficile à sécuriser), fichiers ou tableur (pas de sécurité, pas de règles automatiques), serveur maison (maintenance et coût inutiles pour une seule utilisatrice).

**Comment Alice est protégée sans compte** : elle n'a pas de connexion. Son lien contient un code secret de 48 caractères. Les deux seules fonctions ouvertes au public (`athlete_get`, `athlete_submit_workout`) exigent ce code. Aucune table n'est lisible sans être connecté comme coach.

## 4. Accès et comptes à connaître

| Service | Où | Ce que tu y fais |
|---|---|---|
| Supabase | supabase.com, projet de l'app | SQL Editor, utilisateurs, clés d'API |
| Vercel | vercel.com, projet `coach-reprise` | Déploiements, domaine, variables |
| GitHub | github.com/valentindupnt/coach-reprise | Code |
| App coach | `/coach` | Piloter Alice |

**Clés** : seule la clé **publishable** (`sb_publishable_…`) est utilisée par l'app, dans les variables Vercel `VITE_SUPABASE_URL` et `VITE_SUPABASE_KEY`. La clé **secret** (`sb_secret_…`) ne doit **jamais** être utilisée dans l'app ni partagée. Si elle a été exposée : la supprimer et en recréer une dans Supabase (**Project Settings → API Keys**).

## 5. Utilisation au quotidien (panneau coach)

1. Va sur `/coach`, connecte-toi.
2. **Alertes** (douleur élevée, fourmillements) : à traiter en premier.
3. **À valider** : propositions de montée de niveau. L'app ne monte **jamais** seule : c'est toi qui valides.
4. **Fiche d'Alice** : message pour elle, pause ou réactivation, niveaux par exercice, historique des séances, journal des niveaux, régularité sur 4 semaines, bouton pour changer le lien.

### Les règles automatiques

| Situation | Effet |
|---|---|
| « Douleur » sur un exercice | Niveau −1 automatique, inscrit au journal |
| Douleur > 3/10 sur la séance | Alerte orange chez toi, conseil d'alléger chez Alice |
| Fourmillements, engourdissement, faiblesse | Programme gelé, écran « contacte ton médecin », alerte rouge chez toi |
| « Trop facile » 2 séances de suite, douleur ≤ 3, aucun symptôme, aucun changement depuis 7 jours | Proposition « À valider » |

Quand Alice est gelée, tu la réactives depuis sa fiche, **après** avis médical.

## 6. Modifier l'application

| Je veux changer… | Comment | Redéploiement |
|---|---|---|
| Un niveau, un message, une pause | Panneau coach | Aucun, immédiat |
| Une consigne, un exercice, un lien vidéo, la composition d'une séance | Modifier `supabase/seed.sql`, le coller dans le SQL Editor de Supabase, **Run** | Aucun |
| Une règle de progression ou de sécurité | Modifier `supabase/schema.sql`, le relancer dans Supabase | Aucun (mais tester avant) |
| L'apparence, un écran, une fonction | Modifier le code, le pousser sur `main` | Automatique (1 à 2 min) |

Le plus simple : me décrire le changement. Je modifie les fichiers, je lance les tests, puis je pousse.

**Attention à `schema.sql`** : il recrée des tables. Le relancer **efface les données** (c'est ce qui a vidé la table des coachs lors de la mise en route). Pour une modification de règle, demande-moi un script de migration qui conserve les données.

## 7. Reprendre le projet (nouvelle machine ou nouvelle conversation)

```bash
git clone https://github.com/valentindupnt/coach-reprise.git
cd coach-reprise
npm install
cp .env.example .env.local     # remplir VITE_SUPABASE_URL et VITE_SUPABASE_KEY (clé publishable)
npm run dev                    # app en local
npm run test:db                # règles de la base (sans Supabase)
npm run test:e2e               # parcours Alice et coach dans un navigateur iPhone simulé
```

Pour reprendre avec Claude : donne-lui le dépôt GitHub et ce guide, ainsi que `docs/CADRAGE.md` (décisions et feuille de route).

### Carte des fichiers

| Fichier ou dossier | Contenu |
|---|---|
| `src/athlete/` | App d'Alice : accueil, séances, lecteur avec minuteur, bilan, progression |
| `src/coach/` | Panneau coach |
| `src/components/Figure.tsx` | Dessins des exercices |
| `src/lib/plan.ts` | Semaine type, phases, nombre de tours |
| `supabase/schema.sql` | Tables, sécurité, règles de progression |
| `supabase/seed.sql` | 25 exercices et programme d'Alice |
| `supabase/reset-alice.sql` | Remise à zéro avant le vrai lancement |
| `tests/` | Tests des règles et des parcours |
| `docs/CADRAGE.md` | Décisions, logique de progression, risques |

## 8. Avant de donner l'app à Alice (checklist)

- [ ] Tester 3 à 5 jours sur ton iPhone avec le lien d'Alice (séance complète, bouton « Ça fait mal », bilan, mode hors ligne)
- [ ] Vérifier dans `/coach` que les séances, douleurs et ressentis remontent bien
- [ ] Lancer `supabase/reset-alice.sql` (efface les tests, remet les niveaux à 1, crée un **nouveau** lien)
- [ ] Recharger `/coach` et copier le **nouveau** lien d'Alice
- [ ] Envoyer ce lien à Alice, avec la consigne : Safari → Partager → Sur l'écran d'accueil
- [ ] Supabase : désactiver **Allow new users to sign up** (Authentication → Sign In / Providers)
- [ ] Supabase : supprimer ou régénérer toute clé `sb_secret_…` qui a été partagée
- [ ] Vercel : vérifier que **Vercel Authentication** est désactivé (Settings → Deployment Protection)
- [ ] Vérifier que les liens vidéo des exercices sont ceux que tu valides

## 9. Dépannage

| Symptôme | Cause probable | Solution |
|---|---|---|
| « Accès refusé… pas enregistré comme coach » | Ta ligne dans la table `coaches` manque | SQL Editor : `insert into public.coaches (user_id) select id from auth.users where email = 'ton-email' on conflict (user_id) do nothing;` puis te reconnecter |
| La page demande un compte Vercel | Protection de déploiement active, ou ancienne adresse de déploiement | Désactiver Vercel Authentication, utiliser `coach-reprise.vercel.app` |
| « Ouvre le lien personnel… » | Adresse racine ouverte | Ajouter `/coach`, ou utiliser le lien d'Alice |
| L'app ne charge plus les données | Projet Supabase en pause (7 jours sans activité) | Supabase → **Restore project** (un clic) |
| Alice a perdu son lien ou l'a partagé | | Fiche d'Alice → **Changer le lien**, lui envoyer le nouveau |
| « Relation does not exist » au lancement d'un script | `seed.sql` lancé avant `schema.sql` | Lancer `schema.sql` d'abord, puis `seed.sql` |
| Erreur de syntaxe dans le SQL Editor | Nom du fichier collé au lieu de son contenu | Ouvrir le fichier, copier **son contenu** |
| Les variables Vercel ne semblent pas prises en compte | Pas de redéploiement | Deployments → … → **Redeploy** |
| Une variable `VITE_` refuse « secret » | Elle doit être publique | La mettre en **Config / plain**, pas en secret |
| Séance non enregistrée hors ligne | Réseau coupé | Elle est mise en file d'attente et envoyée au retour du réseau |

## 10. Limites à garder en tête

- L'app **ne remplace pas un avis médical**. Montée de niveau validée par toi, gel automatique sur symptôme.
- Supabase Free se met en pause après 7 jours sans activité (réactivation en un clic).
- Vercel Hobby est réservé à un usage non commercial : valable tant que le coaching est gratuit.
- Pas de notification e-mail des alertes en V1 : tu consultes le tableau de bord.
- Données minimales : prénom uniquement, aucun diagnostic dans la base.

## 11. Feuille de route

| Version | Contenu |
|---|---|
| **V1** (livrée) | Niveaux, alertes, propositions, historique, message coach, régularité, hors ligne, changement de lien |
| **V2** | Édition des exercices depuis le panneau, graphiques de douleur, export pour le kiné, modèles réutilisables, notification e-mail des alertes |
| **V3** | Résumé hebdomadaire vers Notion (Suivi des Athlètes), plusieurs athlètes dans l'interface |

Pour ajouter une athlète plus tard : la base le permet déjà (une ligne `athletes`, son programme, son lien). L'interface coach multi-athlètes est prévue en V3.
