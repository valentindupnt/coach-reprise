# FLEXO, bloc Étirements : étiquettes et sets guidés

*8 novembre 2026. Branche `flexo-etirements`, partie de `v5-bloc2`. Complète `docs/MODELE-V5.md` et `docs/CONTENU-V5.md`.*

## 1. En bref

| Quoi | Nombre | Où |
|---|---|---|
| Sets guidés de 10 minutes | 7 | `content/v5/etirements.mjs` (`SETS`), entraînements de type `etirement` |
| Nouveaux étirements et mobilités | 8 | idem (`ETIREMENTS`) |
| Exercices étiquetés | 53 | idem (`TAGS`) |
| Schémas dessinés pour l'app | 30 nouveaux (39 utilisés par les sets) | `src/components/Figure.tsx` |
| Liens vidéo ajoutés (à valider) | 8 | `content/v5/videos.mjs` |

Rien n'apparaît dans l'app avant validation : les 8 nouveaux étirements et les 7 sets arrivent `approved = false`.

## 2. Les étiquettes

Quatre colonnes ajoutées à `exercises` (additives, contrôlées par la base) :

| Colonne | Valeurs | Sens |
|---|---|---|
| `moments` | `avant`, `apres`, `hors_seance` | Quand l'exercice se fait |
| `sports` | `velo`, `course`, `muscu`, ou `tous` seul | Sport associé |
| `stretch_mode` | `statique`, `dynamique`, `activation` | Position tenue, mobilité en mouvement, ou mise en route |
| `hold_seconds` | 5 à 120 | Durée de maintien **par côté**, seulement pour un étirement statique |

La fiche envoyée à l'app (`_exercise_json`) les expose. Contenu identique pour tous : aucune règle par profil.

## 3. Les sept sets

| Set | Identifiant | Durée | Postures | Principe |
|---|---|---|---|---|
| Échauffement avant effort | `etir_echauffement` | 9 min 55 | 13 | Mobilité dynamique et activation, aucun étirement tenu |
| Après le vélo | `etir_apres_velo` | 10 min | 11 | Cuisses, hanches, mollets, dos, poignets, poitrine, nuque |
| Après la course | `etir_apres_course` | 9 min 50 | 9 | Mollets (dont soléaire), cuisses, hanches, fessiers |
| Après la muscu | `etir_apres_muscu` | 9 min 40 | 11 | Haut du corps puis jambes |
| Hanches et dos | `etir_hanches_dos` | 9 min 50 | 11 | Ouverture des hanches, dos |
| Soir, avant de dormir | `etir_soir` | 9 min 35 | 10 | Postures lentes au sol, une minute de respiration |
| Nuque et épaules | `etir_nuque_epaules` | 9 min 35 | 12 | Nuque, épaules, haut du dos (bureau, guidon) |

Un set se joue d'un trait : un tour, 5 s de transition entre deux postures, aucun matériel, aucun saut. La durée est calculée par la base comme pour tout entraînement (`_training_stats`).

## 4. Règles vérifiées par le générateur

`npm run content` refuse de produire le SQL si :

- un set ne dure pas entre 560 et 600 s, contient du matériel ou un saut ;
- une posture d'un set n'a pas d'étiquettes, de schéma, de vidéo ou de source ;
- l'échauffement contient un étirement statique ou un exercice non étiqueté « avant » ;
- un set « après vélo / course / muscu » contient un exercice non étiqueté « après », ou moins de 80 % d'exercices associés à son sport ;
- un étirement statique n'a pas de durée de maintien, ou un exercice non statique en a une ;
- un nouvel étirement ou une nouvelle mobilité n'a pas d'étiquettes.

## 5. Repères (sources)

| Règle | Source |
|---|---|
| Avant l'effort : échauffement dynamique, pas d'étirement statique | NHS, *How to warm up before exercising* |
| Un étirement statique de 60 s ou plus baisse la performance qui suit (-4,6 %, contre -1,1 % sous 60 s) | Behm et al., 2016, *Applied Physiology, Nutrition, and Metabolism* |
| Après l'effort : tenir 15 à 20 s | NHS, *How to stretch after exercising* |
| Tenir 10 à 30 s, au moins 2 à 3 jours par semaine | ACSM, *Stretching and flexibility guidelines update* |

Chaque nouvel étirement cite sa fiche free-exercise-db et une page NHS. Le choix des sports associés est éditorial (muscles sollicités par chaque sport) : à relire.

## 6. Relecture et mise en ligne

1. `content/v5/relecture-etirements.xlsx` : onglets Sets guidés, Nouveaux étirements, Étiquettes, Sources. Le tableur du bloc 2 est inchangé.
2. `content/v5/schemas-etirements.svg` : planche des 39 schémas utilisés par les sets (`node scripts/render-figures.mjs`).
3. Après relecture : `python3 scripts/build-validation.py relecture-etirements-rempli.xlsx` génère `supabase/content-etirements-validation.sql`, distinct de celui du bloc 2.
4. Ordre dans Supabase : `schema.sql`, `seed.sql`, `content-v5.sql`, `content-v5-validation.sql`, puis `content-etirements-validation.sql`.

Les étiquettes et les schémas s'appliquent aussi aux exercices du bloc 2 déjà validés (section « 2 bis » de `content-v5.sql`), sans toucher à leur nom, leurs consignes, leurs niveaux ni leur validation.

## 7. Autre changement

`_training_stats` arrondit maintenant les MET-minutes en une seule division (`(met_sec + rest) / 60`). L'ancienne formule additionnait deux quotients tronqués et pouvait arrondir 21,75 à 21,7. Sans effet sur les 75 entraînements existants (tests identiques) ; les calories restent de toute façon à retirer.

## 8. Ce qui reste ouvert

- La séance Découverte « Étirements du soir » (9 min, bloc 2) fait doublon avec le set « Soir, avant de dormir » : la garder ou la retirer.
- Les écrans : ce bloc livre les données, pas d'écran. Les sets sont servis par `athlete_catalog` et `athlete_training` (et `fetchTraining` côté app), mais aucun écran n'ouvre encore un entraînement V5 : c'est le bloc 4 (onglet Récup et zen, page d'un entraînement).
- Minuteur par posture et changement de côté signalé : à faire dans le lecteur du bloc 4. La donnée est prête (`hold_seconds` par côté, niveaux « 20 s par côté »).
