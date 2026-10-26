# Bibliothèque d'exercices : sources, règles et validation

Ce document explique d'où viennent les exercices, comment l'application choisit un remplaçant, et ce qu'il reste à valider avant de les proposer à Alice.

## Principe

Chaque exercice du catalogue porte des informations qui servent aux filtres et aux remplacements :

| Champ | Rôle |
|---|---|
| Type | force, gainage, mobilité, étirement, respiration. Un remplacement reste toujours dans le même type. |
| Zones | muscles ou régions travaillés (dos, fessiers, abdos profonds…). |
| Matériel | aucun, élastique, mini-band, chaise, mur, serviette, coussin. |
| Intensité | de 1 (très léger) à 5 (intense), jugée pour une reprise après hernie discale. |
| Famille | variantes d'un même mouvement (ex. pont fessier et pont sur pieds éloignés). |
| Tours max conseillés | de 1 à 4, voir plus bas. |
| Validé | un exercice non validé n'est visible ni d'Alice ni des propositions de remplacement. |
| Source | d'où vient l'exercice, pour pouvoir le vérifier. |

## Règle des remplacements

Quand Alice dit « Ça fait mal » ou « Ne me convient pas », ou marque « À changer » dans son bilan, l'application propose **2 exercices** :

1. d'abord une **variante** du même mouvement (même famille), sinon
2. un exercice qui travaille **une autre zone** à intensité équivalente, puis
3. à défaut, l'exercice d'intensité la plus proche.

Conditions communes : exercice validé, même type, intensité à ± 1 près, pas déjà dans la séance, et jamais un exercice sous tampon « Ça fait mal » (10 jours depuis la douleur signalée, règle V5 qui remplace les 14 jours). Sans réseau, la même règle est calculée sur la bibliothèque gardée sur son téléphone.

Le remplacement en séance ne vaut que pour la séance en cours. Il devient définitif seulement si Alice le confirme dans son bilan, ou si le coach le fait. Chaque changement est inscrit au journal du coach. Le coach peut retirer à Alice la possibilité de changer elle-même (case dans sa fiche).

Sécurité (V5, 26/10/2026) : douleur sur un exercice = tampon de 10 jours, l'exercice n'est plus proposé et il est remplacé à l'ouverture des entraînements. La baisse de niveau automatique et le gel du programme sont supprimés (voir `docs/MODELE-V5.md`).

## Nombre de tours (2 à 4)

Les séances passaient de 14 à 22 minutes de contenu réel alors que l'écran annonçait 30 minutes. Elles comportent maintenant un échauffement (3 exercices), le circuit, puis un retour au calme, et la durée affichée est calculée d'après le contenu.

Le nombre de tours suit la phase du plan (2 tours, puis 3). Le coach peut, exercice par exercice, imposer 1 à 4 tours, dans la limite « tours max conseillés » de l'exercice.

Repères de la littérature : 2 à 4 séries par exercice sont la fourchette courante pour la reprise de la force (ACSM). La limite haute de 4 n'est donc atteinte que sur décision du coach.

## Effort ressenti (RPE)

Chaque séance se termine par une note d'effort de 0 à 10 (échelle CR10 de Foster, « session RPE »), avec la durée. Le produit effort × durée donne une charge de séance, utile au coach pour repérer une montée trop rapide. Les premières séances d'Alice permettront de voir si les échelles de douleur et d'effort sont bien comprises.

## Sources consultées

| Source | Usage | Licence ou condition |
|---|---|---|
| free-exercise-db (base ouverte, en anglais) | repérer des exercices et des muscles cibles | Unlicense (domaine public) |
| exercemus (base ouverte) | idem | licence propre à chaque exercice, avec mention de la source |
| Harvard Health / Stuart McGill, « Big 3 » | curl-up de McGill, gainages latéraux, bird-dog | consultation, aucun texte repris |
| Mass General Brigham, rééducation discale conservatrice | glissement de talon, clamshell, squat au mur | consultation, aucun texte repris |
| ACE Fitness, banque d'exercices | repères sur clamshell et curl des ischio-jambiers | consultation, aucun texte repris |
| ACSM, recommandations de force | fourchette 2 à 4 séries | consultation |
| Foster et al., session RPE (PMC5673663) | échelle d'effort 0 à 10 | article scientifique |

Les consignes, niveaux et textes d'exercices de l'application sont **rédigés pour elle** : aucune base n'est copiée telle quelle. Les illustrations des 18 exercices ajoutés manquent encore (leur fiche s'affiche sans dessin).

## Ce qui reste à valider (important)

Les **18 exercices ajoutés en V2 sont tous marqués « à valider »** et n'apparaissent pas encore chez Alice. Les 25 exercices de la V1 sont validés. Pour les nouveaux : relire la fiche, vérifier l'intensité et les précautions, idéalement avec son kiné, puis cliquer sur **Valider** dans l'onglet Bibliothèque du panneau coach.

Pour quelques exercices, la colonne « source » reste générique (« exercice standard ») parce qu'il s'agit de mouvements courants sans référence unique : c'est une raison de plus de les faire relire.

Tant que ces exercices ne sont pas validés, certaines propositions de remplacement sont rares : par exemple, il n'existe qu'**un seul** gainage de remplacement possible pour le dead bug, la fenêtre n'en montrera alors qu'un.

## Mise à jour d'une installation existante

1. Supabase, SQL Editor : lancer `supabase/schema.sql` (ajoute les colonnes et fonctions, ne supprime aucune donnée).
2. Lancer `supabase/seed.sql` : ajoute le catalogue enrichi et réorganise le programme d'Alice en échauffement, circuit, retour au calme. Ses niveaux sont conservés.
3. Déployer le code (poussée sur `main`).

Les deux scripts peuvent être relancés sans risque.
