# Coach Reprise

Web app de reprise sportive pour Alice (hernie dorsale haute), avec un panneau coach.

- **Alice** ouvre son lien personnel secret (`/a/<lien>`) sur son iPhone : séance du jour, minuteur, consignes illustrées, bilan de fin de séance (douleur, symptômes, ressenti par exercice).
- **Le coach** se connecte sur `/coach` : alertes, propositions de montée de niveau à valider, niveaux par exercice, message pour Alice, régularité, historique, journal des niveaux, changement de lien.

Cadrage complet du projet : [docs/CADRAGE.md](docs/CADRAGE.md). Guide de reprise et d'utilisation : [docs/GUIDE.md](docs/GUIDE.md).

## Règles de sécurité (dans la base de données, impossibles à contourner depuis l'app)

| Situation | Effet |
|---|---|
| Alice marque un exercice « Douleur » (ou appuie sur « Ça fait mal ») | L'exercice descend automatiquement d'un niveau |
| Douleur > 3/10 sur la séance | Alerte orange chez le coach, conseil d'alléger chez Alice |
| Fourmillements / engourdissement / faiblesse | Programme gelé, écran « pause, contacte ton médecin », alerte rouge chez le coach |
| « Trop facile » 2 séances de suite, douleur ≤ 3, sans symptôme, pas de changement depuis 7 jours | Proposition « À valider » chez le coach. **Jamais de montée automatique.** |

## Architecture

| Élément | Rôle |
|---|---|
| `src/athlete/` | App d'Alice (accueil, séances, lecteur avec minuteur, bilan, progression) |
| `src/coach/` | Panneau coach |
| `src/components/Figure.tsx` | Illustrations des exercices |
| `src/lib/plan.ts` | Semaine type, phases sur 8 semaines, nombre de tours |
| `supabase/schema.sql` | Tables, sécurité (RLS), règles de progression |
| `supabase/seed.sql` | Catalogue de 43 exercices (dont 18 à valider par le coach) + programme d'Alice |
| `supabase/reset-alice.sql` | Remise à zéro après les tests |
| `tests/` | Tests des règles en base (`npm run test:db`) et parcours complets dans un navigateur iPhone (`npm run test:e2e`) |

Alice n'a pas de compte : elle accède à ses données uniquement par deux fonctions qui exigent son lien secret (48 caractères aléatoires). Aucune table n'est lisible sans être connecté comme coach. Données minimales : prénom uniquement.

## Mise en ligne

### 1. Supabase (base de données)

1. Sur supabase.com : **New project**, région **Europe (Paris ou Frankfurt)**, choisis un mot de passe de base (garde-le, il ne sert pas dans l'app).
2. **SQL Editor → New query** : colle tout le contenu de `supabase/schema.sql`, clique **Run**. Puis nouvelle requête avec `supabase/seed.sql`, **Run**.
3. **Authentication → Users → Add user → Create new user** : ton e-mail et un mot de passe solide, coche **Auto Confirm User**.
4. **Te déclarer coach** : SQL Editor, lance (avec ton e-mail) :
   ```sql
   insert into public.coaches (user_id)
   select id from auth.users where email = 'ton-email@exemple.com';
   ```
5. **Authentication → Sign In / Providers** : désactive **Allow new users to sign up** (personne d'autre ne peut créer de compte).
6. **Project Settings → API Keys** (ou **Data API**) : note la **Project URL** et la clé **publishable** (`sb_publishable_...`, ou à défaut la clé `anon`). Ne jamais utiliser la clé `secret` / `service_role` dans l'app.

### 2. Vercel (hébergement)

1. Projet relié au dépôt GitHub, framework **Vite** (détecté automatiquement).
2. **Settings → Environment Variables** :
   - `VITE_SUPABASE_URL` = la Project URL
   - `VITE_SUPABASE_KEY` = la clé publishable
3. **Deployments → … → Redeploy** (les variables ne sont prises en compte qu'au déploiement suivant).

### 3. Vérifier

1. Ouvre `https://<ton-projet>.vercel.app/coach`, connecte-toi.
2. Copie le lien personnel d'Alice et teste-le toi-même sur ton iPhone (Safari → Partager → **Sur l'écran d'accueil**).
3. Après tes tests : lance `supabase/reset-alice.sql`, recharge le panneau coach, et envoie à Alice le **nouveau** lien.

## Mettre à jour

- **Niveaux, message, déblocage** : depuis le panneau coach, effet immédiat, sans redéployer.
- **Exercices, séances, nombre de tours** : depuis le panneau coach (onglet Bibliothèque et fiche de l'athlète). Voir `docs/BIBLIOTHEQUE.md`. Mise à jour d'une installation existante : relancer `schema.sql` puis `seed.sql`, sans perte de données.
- **Code** : chaque commit sur `main` est redéployé automatiquement par Vercel.

## Développement

```bash
npm install
cp .env.example .env.local   # puis remplir les deux variables
npm run dev
npm run test:db              # règles de la base (PGlite, sans Supabase)
npm run test:e2e             # parcours Alice + coach dans un navigateur iPhone
```

Limites connues : un projet Supabase gratuit se met en pause après 7 jours sans activité (réactivation en un clic) ; Vercel Hobby est réservé à un usage non commercial.
