# Contenu V5 (bloc 2) : exercices, entraînements, programmes

*27 octobre 2026. Complète `docs/CADRAGE-V5.md` et `docs/MODELE-V5.md`. Branche `v5-bloc2`, partie de `v5-bloc1`.*

## 1. En bref

| Quoi | Nombre | Où |
|---|---|---|
| Exercices nouveaux | 103 | `content/v5/exercices-renfo.mjs`, `exercices-cardio.mjs`, `exercices-yoga.mjs` |
| Exercices existants ré-étiquetés | 43 | `content/v5/exercices-existants.mjs` |
| Liens vidéo (à valider) | 146 | `content/v5/videos.mjs` |
| Entraînements | 75 | `content/v5/entrainements.mjs` |
| Programmes de 28 jours | 3 | idem |

Répartition des 146 exercices : 100 de renforcement, gainage, calisthénie, pilates, cardio et HIIT (2.1), 19 postures de yoga, 21 étirements et mouvements d'échauffement, 6 exercices de respiration ou de méditation (2.2).

Entraînements : 36 jours de programme propres (3 programmes x 4 semaines x 3 séances), 8 séances de mobilité et de récupération communes aux 3 programmes, 18 démarrages rapides (6 zones x 3 niveaux), 7 moments Découverte, 6 séances express.

**Rien n'apparaît dans l'app avant validation** : tout le nouveau contenu est importé avec `approved = false`.

## 2. Circuit de travail

```
content/v5/*.mjs  ──►  node scripts/build-content.mjs  ──►  supabase/content-v5.sql      (import)
                                                       └─►  content/v5/relecture.json
                                python3 scripts/build-relecture.py  ──►  content/v5/relecture-bloc2.xlsx  (relecture)
tableur rempli  ──►  python3 scripts/build-validation.py rempli.xlsx  ──►  supabase/content-v5-validation.sql
```

- `npm run content` régénère le SQL et le tableur. Le générateur refuse de produire quoi que ce soit au moindre problème : vocabulaire inconnu, muscle inconnu, code MET inconnu, fiche free-exercise-db introuvable, niveau mal formé, tiret long ou flèche dans un texte, durée d'un entraînement à plus de 2 minutes de sa cible, séance express hors de 3 à 5 minutes ou avec du matériel, exercice à sauts sans variante sans saut.
- `npm run test:content` charge tout dans un PostgreSQL embarqué et vérifie notamment que la base calcule exactement les mêmes durées que le générateur, puis rejoue la validation d'un tableur rempli de « oui » jusqu'au démarrage d'un programme par Alice.
- Ne jamais modifier `supabase/content-v5.sql` à la main : modifier `content/v5/*.mjs`, puis relancer `npm run content`.

## 3. Mise en ligne (après validation)

1. Supabase, SQL Editor : `schema.sql` (bloc 1), `seed.sql`, puis **`content-v5.sql`**. Tous relançables, aucun ne supprime de données.
2. Valentin remplit le tableur, Claude génère `content-v5-validation.sql`, à lancer ensuite.
3. Un entraînement n'est validé que si tous ses exercices le sont, et un programme seulement si tous ses entraînements le sont.

Relancer `content-v5.sql` met à jour le contenu encore « à valider », jamais ce qui a déjà été validé.

## 4. Choix faits pour l'app

| Sujet | Choix |
|---|---|
| Programmes | 28 jours. Semaine type : J1 A, J2 B, J3 mobilité, J4 C, J5 A, J6 B, J7 récupération. Séances de 10 min (semaine 1) à 25 min (semaine 4). |
| Niveau | Les 3 programmes sont écrits pour un débutant (niveau 1). Les exercices passent du niveau 1 au niveau 2 ou 3 au fil des semaines ; l'utilisateur peut monter librement. |
| Matériel | Programmes, démarrages rapides et séances express : **aucun matériel, aucun saut**. Les exercices avec élastique, haltères, chaise ou mur servent aux remplacements et aux futurs programmes. |
| Sauts | Seuls les démarrages rapides avancés « corps entier », « abdos » et « jambes » en contiennent. Chaque exercice à sauts a une variante sans saut de la même famille, pour le remplacement. |
| Remise en forme | Le programme `remise_en_forme` est la version revue de l'actuel : même esprit (bas du corps, haut du corps, gainage, mobilité), sans élastique. **Bloc 1.5** : faire pointer la migration d'Alice vers ce programme plutôt qu'en créer un autre. |
| Matériel des exercices | Uniquement le vocabulaire du questionnaire (`aucun`, `tapis`, `elastique`, `halteres`, `chaise`, `mur`), au sens « nécessaire ». Les anciens `mini-band`, `serviette`, `coussin` sont ramenés à `elastique` quand ils sont indispensables, sinon retirés : ils ne servaient qu'à des niveaux avancés ou au confort, et la base exclut un exercice dès qu'un de ses matériels manque. Un niveau avancé peut mentionner un matériel facultatif (« haltères en main ») sans que l'exercice l'exige. |
| Calories | Chaque exercice porte son code MET du Compendium 2024 (codes vérifiés sur pacompendium.com le 26/10/2026). |

## 5. Muscles (pour la silhouette du bloc 5)

`muscles_primary` et `muscles_secondary` utilisent ce vocabulaire, défini dans `content/v5/vocabulaire.mjs` (`MUSCLES`) :

| Identifiant | Libellé | Face ou dos |
|---|---|---|
| `pectoraux` | Pectoraux | face |
| `deltoides_anterieurs` | Épaules (avant) | face |
| `deltoides_lateraux` | Épaules (côté) | face |
| `deltoides_posterieurs` | Épaules (arrière) | dos |
| `coiffe_rotateurs` | Coiffe des rotateurs | dos |
| `biceps` | Biceps | face |
| `triceps` | Triceps | dos |
| `avant_bras` | Avant-bras | face |
| `trapezes` | Trapèzes | dos |
| `rhomboides` | Haut du dos (rhomboïdes) | dos |
| `grand_dorsal` | Grand dorsal | dos |
| `lombaires` | Bas du dos (lombaires) | dos |
| `grand_droit` | Abdominaux (grand droit) | face |
| `transverse` | Abdominaux profonds | face |
| `obliques` | Obliques | face |
| `grand_fessier` | Grand fessier | dos |
| `moyen_fessier` | Moyen fessier | dos |
| `flechisseurs_hanche` | Fléchisseurs de hanche | face |
| `quadriceps` | Quadriceps | face |
| `adducteurs` | Adducteurs | face |
| `ischio_jambiers` | Ischio-jambiers | dos |
| `mollets` | Mollets | dos |
| `cou` | Cou | dos |
| `diaphragme` | Diaphragme | face |

Les méditations n'ont pas de muscle : la fiche peut masquer l'onglet Muscles quand les deux listes sont vides.

## 6. Sources

Chaque exercice cite au moins une source consultable, visible dans le tableur et dans la colonne `source` :

- **free-exercise-db** (base ouverte, domaine public) : une fiche par exercice, avec muscles et consignes, consultée pour vérifier le mouvement et les muscles.
- **NHS** (exercices de force et de souplesse), **Harvard Health** (« Big 3 » de McGill), **Yoga Journal** et **Yogamatters** (une page par posture), **The Yoga Institute** (salutation au soleil).
- Respiration et méditation : revue systématique sur la respiration lente (Université de Berne), University of Pittsburgh (respiration carrée), UCLA Mindful et NHS Torbay (attention au souffle), Greater Good in Action, UC Berkeley (scan corporel), University of Rochester (relaxation progressive).
- Construction des programmes : OMS 2020 (renforcement au moins 2 jours par semaine) et position 2026 de l'ACSM sur le renforcement musculaire.

Les consignes, tutoriels et descriptions sont rédigés pour l'app : aucun texte n'est copié.

## 7. Vidéos

Un lien YouTube par exercice, en français quand une vidéo claire existait (15 en anglais). Les vidéos n'ont pas été visionnées : Valentin les valide dans le tableur (colonne « Vidéo OK »). Pour une vidéo refusée, Claude en cherche une autre et met à jour `content/v5/videos.mjs`.

## 8. Ce qui reste ouvert

- **Validation** de Valentin dans le tableur, puis génération de `content-v5-validation.sql`.
- **Bloc 1.5** : migrer Alice vers `remise_en_forme`.
- **Bloc 3** : le moteur de génération choisira le programme et pourra remplacer les jours au-delà du nombre de séances par semaine par les séances de mobilité ; les programmes intermédiaire et avancé peuvent se dériver des mêmes entraînements en montant les niveaux.
- **Bloc 5** : dessins des 103 nouveaux exercices (aucun pour l'instant, la fiche s'affiche sans dessin).
