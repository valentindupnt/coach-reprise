# Modèle de données V5 (bloc 1)

*26 octobre 2026. Complète `docs/CADRAGE-V5.md`. Tout est dans `supabase/schema.sql`, section « V5, bloc 1 ». Les changements sont additifs : aucune table ni colonne existante n'est supprimée, et le script reste relançable.*

## Vue d'ensemble

| Brique | Table | Rôle |
|---|---|---|
| Exercice | `exercises` (colonnes ajoutées) | Étiquettes : muscles, zones, objectifs, discipline, impact, mode temps ou répétitions, MET |
| Entraînement | `trainings` + `training_items` | Une suite d'exercices en trois phases (échauffement, corps de séance, retour au calme) |
| Programme | `programs` + `program_days` | Un entraînement par jour, sur N jours |
| Programme suivi | `athlete_programs` | Le programme d'un utilisateur, un seul actif à la fois |
| Séance faite | `workouts` (colonnes ajoutées) | `session_key = 'T'`, entraînement fait, jour de programme validé |
| Profil | `athlete_profiles` | Réponses du questionnaire et données corporelles |
| Tampon | `exercise_blocks` | Exercice écarté 10 jours après « Ça fait mal » |

## 1.1 Étiquettes d'un exercice

| Colonne | Valeurs |
|---|---|
| `muscles_primary`, `muscles_secondary` | Muscles affichés sur la silhouette (vif / atténué) |
| `areas` | bras, epaules, abdos, fessiers, jambes, dos, corps_entier |
| `goals` | renforcer, tonifier, mobilite, cardio, detente |
| `discipline` | renforcement, gainage, calisthenie, cardio, hiit, yoga, etirement, pilates, meditation |
| `impact` | true = avec sauts |
| `mode`, `default_value` | `time` (secondes) ou `reps` (répétitions), valeur par défaut |
| `met`, `met_code` | Valeur MET et code d'activité du Compendium 2024 |
| `tutorial` | `{"steps": [...], "breathing": "...", "mistakes": [...]}` |

Le type historique `kind` accepte désormais `cardio`. Les 43 exercices existants ont reçu des étiquettes déduites de leur type et de leurs zones (fonction `_v5_backfill_exercise_tags`, rappelée par `seed.sql` et à chaque création d'exercice depuis le panneau). Le bloc 2 les remplacera par des étiquettes sourcées.

## 1.2 Entraînements

- `kind` : `programme` (jour d'un programme), `rapide` (démarrage rapide par zone), `decouverte` (moments pour soi), `express` (3 à 5 min sans matériel, gardé hors ligne).
- `level` : 1 débutant, 2 intermédiaire, 3 avancé. `rounds` : tours du corps de séance. `rest_seconds` : pause entre deux exercices.
- Chaque ligne de `training_items` a une phase, une position, un exercice, un niveau, et peut imposer une valeur (`value`) ou un nombre de tours (`sets`).

**Durée calculée** (`_training_stats`) : échauffement et retour au calme une fois, corps de séance `sets` ou `rounds` fois. Temps : valeur imposée, sinon secondes du niveau, sinon valeur par défaut, sinon 45 s. Répétitions : 3 s par répétition. Une pause entre chaque passage.

**Calories** : la fonction renvoie `met_minutes` (effort × MET, pauses à 1 MET). Calories ≈ `met_minutes` × poids (kg) / 60, conformément à la méthode du cadrage.

Elle renvoie aussi le matériel nécessaire et la présence de sauts.

## 1.3 Programmes et déblocage jour par jour

- Le jour 1 est ouvert dès le démarrage.
- Le jour suivant s'ouvre **le lendemain** (date locale de l'utilisateur, `athletes.timezone`) du dernier jour fait.
- L'espace admin peut ouvrir des jours en avance (`coach_unlock_day`).
- Une séance valide un jour seulement si c'est le bon entraînement, que le jour n'est pas déjà fait et qu'il est ouvert à la date de la séance. Sinon elle est enregistrée quand même, sans compter pour le plan.
- Quand tous les jours sont faits, le programme passe à `termine`. Démarrer un autre programme marque le précédent `abandonne`.

## 1.4 Profil sportif

Toutes les réponses du questionnaire (section 3 du cadrage), chacune facultative et contrôlée par la base. `athlete_save_profile` enregistre par morceaux : seules les clés envoyées changent, `null` efface une réponse, `complete: true` date la fin du questionnaire. L'IMC est calculé à la lecture. `athlete_delete_profile` efface tout.

## 1.4 bis Tampon « Ça fait mal »

- `douleur` sur un exercice (bouton en séance via `athlete_flag_pain`, ou bilan via les fonctions d'envoi) : tampon de 10 jours à partir du moment de la douleur.
- Pendant le tampon, l'exercice n'est proposé nulle part : remplacements (en ligne et hors ligne), et dans un entraînement il est **remplacé automatiquement à l'ouverture** (`replaced_from` indique l'exercice d'origine). Sans remplaçant compatible (même type, intensité ± 1, matériel du profil), il est retiré de la séance.
- Le tampon se lève seul au bout de 10 jours, ou plus tôt avec `coach_lift_block`.
- **Supprimés** : la baisse de niveau automatique sur douleur, le gel du programme sur symptôme, et la question des symptômes au bilan. La migration libère les utilisateurs gelés auparavant.

## Fonctions disponibles pour l'app

| Fonction | Rôle |
|---|---|
| `athlete_get` | Ajoute `profile`, `plan` (programme jour par jour) et `blocks` |
| `athlete_catalog` | Programmes et entraînements hors programme validés |
| `athlete_training` | Un entraînement prêt à lancer, tampons déjà remplacés |
| `athlete_start_program` | Démarre un programme |
| `athlete_submit_training` | Enregistre un entraînement V5, rattache le jour, pose les tampons |
| `athlete_save_profile`, `athlete_delete_profile` | Profil |
| `athlete_flag_pain` | Tampon immédiat |
| `coach_lift_block`, `coach_unlock_day` | Amorce de l'espace admin |

Les écrans qui utilisent ces fonctions arrivent aux blocs 3 (questionnaire), 4 (onglets) et 7 (espace admin). Les anciennes séances A, B, M restent en place jusqu'à la migration du bloc 1.5.

## Mise en ligne

1. Supabase, SQL Editor : lancer `supabase/schema.sql` (additif, ne supprime aucune donnée).
2. Lancer `supabase/seed.sql` (étiquette les exercices encore sans étiquettes).
3. Fusionner la branche dans `main` : Vercel redéploie l'app.

L'ordre n'est pas bloquant : l'app tolère une base pas encore migrée, et l'ancienne app tolère la base migrée.
