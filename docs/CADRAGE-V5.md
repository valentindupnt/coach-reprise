# Cadrage V5 : app de fitness à domicile

*Version du 26 octobre 2026. Remplace l'orientation « reprise après blessure » du cadrage V1 (`docs/CADRAGE.md`, conservé pour l'historique).*

Ce document est la référence de toutes les conversations de la refonte. La feuille de route détaillée (blocs, sous-blocs, modèle Claude à utiliser) est dans Notion : Application coach, page « Feuille de route V5 ».

## 1. Objectif

Faire de l'application une app de fitness à domicile, sur le modèle du parcours de l'app « Exercice à la maison » : un questionnaire de départ génère un programme adapté à la personne, qui démarre directement. Alice est la première utilisatrice ; l'app doit pouvoir accueillir d'autres personnes.

## 2. Décisions

| Sujet | Choix |
|---|---|
| Positionnement | Fitness à domicile. La blessure n'est plus le fil conducteur. |
| Programme de départ | Généré par le questionnaire, il **démarre directement**, sans validation. |
| Interface coach | **Supprimée.** Remplacée par un espace admin léger (section 9). |
| Sécurité en séance | Seule règle conservée : le bouton « Ça fait mal » (section 4 bis). Le gel automatique du programme sur fourmillements ou faiblesse est **supprimé**, ainsi que la baisse de niveau automatique. Pas d'écran d'alerte médicale au départ. |
| Montée de niveau | Libre, à l'initiative de l'utilisateur (déjà le cas en V3). |
| Onglets | Plan, Entraînements, Découverte, Activité, plus une fiche profil. |
| Vidéos | Un lien vers une vidéo existante, validé par Valentin. Aucun visuel repris d'une autre app. |
| Contenu | Recherché, rédigé et sourcé par Claude, validé par Valentin avant mise en ligne. |
| Calories | Méthode MET du Compendium 2024 (section 8). Jamais de valeur par défaut sans méthode. |
| Pas | Pas de lecture automatique (une web app n'accède pas à Apple Santé). Estimation depuis une habitude « marche ». |
| Séances express | Des séances courtes sans matériel (3 à 5 min), disponibles hors ligne : gardées sur le téléphone pour être lancées même sans réseau. |
| Technique | Inchangée : GitHub + Vercel + Supabase, web app ajoutée à l'écran d'accueil. |
| Accès | Lien personnel secret par utilisateur, comme aujourd'hui. Le questionnaire s'affiche à la première ouverture. |

## 3. Questionnaire de départ

Chaque réponse sert à quelque chose. Les questions sans effet sur le programme sont gardées seulement quand elles nourrissent la motivation ou la projection, et le dit.

| # | Question | Options | Sert à |
|---|---|---|---|
| 1 | Sexe | Femme, homme | Visuels, valeurs par défaut |
| 2 | Zones à travailler (plusieurs choix) | Bras, épaules, abdos, fessiers, jambes, dos, corps entier | Choix du programme, priorités du démarrage rapide |
| 3 | Objectif principal | Perdre du poids, renforcer les muscles, se tonifier, garder la forme | Choix du programme, intensité |
| 4 | Motivation profonde | Confiance, vitalité, soulager des douleurs, mieux dormir, se sentir bien dans son corps | Messages de motivation |
| 5 | Morphologie actuelle (facultative) | Mince, moyenne, enveloppée, musclée | Écran de résultat uniquement |
| 6 | Taille, poids, année de naissance | Saisie | Calories, exclusion des sauts si IMC ≥ 30, intensité |
| 7 | Poids cible (seulement si objectif = perdre du poids) | Saisie | Frise de projection |
| 8 | Dernière fois en forme | En ce moment, moins d'un an, 1 à 3 ans, plus de 3 ans, jamais | Niveau de départ |
| 9 | Niveau physique | Débutant, intermédiaire, avancé | Niveau de départ |
| 10 | Niveau d'activité | Sédentaire, peu actif, actif, très actif | Niveau de départ |
| 11 | Séances par semaine | 2 à 7 | Rythme du plan |
| 12 | Durée par séance | 10, 15, 20, 30 min | Durée cible du plan |
| 13 | Matériel | Aucun, tapis, élastique, haltères, chaise, mur | Filtre des exercices |
| 14 | Style préféré | Facile à commencer, transpiration légère, intense | Intensité, part de cardio |
| 15 | Disciplines aimées (plusieurs choix) | Renforcement, étirements, pilates, yoga, HIIT, calisthénie, danse, marche, méditation | Suggestions et Découverte |
| 16 | Questionnaire d'adhésion (d'accord / pas d'accord) | « J'ai du mal à choisir mes exercices », « Je m'ennuie et j'abandonne vite », « Je me démotive sans résultats visibles » | Variété et longueur des séances, mise en avant du suivi |
| 17 | Récompense visée | Nouveaux vêtements, un cadeau, un voyage, partager sa réussite, autre | Écran de résultat, rappels |
| 18 | Ressenti visé | Heureux, en forme, confiant, fier, plein d'énergie, rassuré sur sa santé | Écran de résultat, rappels |

Toutes les réponses restent modifiables depuis la fiche profil, et le questionnaire peut être refait.

## 4. Règles de génération du programme (première version)

1. **Programme** : fessiers ou jambes dominants, ou objectif « se tonifier » centré bas du corps, donnent Hanches et fessiers. Abdos dominants, ou objectif « renforcer » avec calisthénie aimée, donnent Gainage et calisthénie. Sinon, Remise en forme.
2. **Niveau de départ** : le niveau déclaré, abaissé d'un cran si la personne est sédentaire ou n'a pas été en forme depuis plus de 3 ans.
3. **Impact** : IMC ≥ 30, exercices à sauts exclus au départ.
4. **Durée** : le plan démarre à 10 minutes et monte vers la durée cible choisie.
5. **Rythme** : un entraînement par jour dans le plan. Les jours au-delà du nombre de séances choisi deviennent des séances courtes de mobilité ou d'étirement.
6. **Matériel** : un exercice qui demande un matériel absent n'est jamais proposé.
7. **Adhésion** : « je m'ennuie » donne des séances plus courtes et une rotation plus forte des exercices ; « je me démotive » met en avant les séries de jours et l'onglet Activité.
8. **Projection** (perte de poids seulement) : rythme prudent, à sourcer au bloc 3 avant affichage.

Ces règles sont un point de départ : elles seront ajustées au bloc 3, puis selon l'usage observé dans l'espace admin.

## 4 bis. Bouton « Ça fait mal »

1. En séance, l'exercice s'arrête et l'app propose un remplacement (règles de remplacement actuelles de `docs/BIBLIOTHEQUE.md`), ou de passer à l'exercice suivant.
2. L'exercice reçoit un **tampon de 10 jours** pour cet utilisateur : pendant 10 jours, il n'est plus proposé nulle part (plan, démarrage rapide, Découverte, remplacements, génération). Ce délai remplace les 14 jours actuels de la règle des remplacements.
3. Dans un entraînement du plan qui contient l'exercice tamponné, il est remplacé automatiquement à l'ouverture de la séance.
4. Le tampon s'affiche sur la fiche de l'exercice avec sa date de fin. Il se lève tout seul après 10 jours, ou plus tôt depuis l'espace admin.
5. Aucun gel du programme, aucune baisse de niveau automatique.

## 5. Étiquettes d'un exercice

| Champ | Valeurs |
|---|---|
| Muscles principaux et secondaires | Liste de muscles, affichés sur la silhouette |
| Zone | Bras, épaules, abdos, fessiers, jambes, dos, corps entier |
| Objectif | Renforcer, tonifier, mobilité, cardio, détente |
| Discipline | Renforcement, gainage, calisthénie, cardio, HIIT, yoga, étirement, pilates, méditation |
| Intensité | 1 à 5 |
| Impact | Avec ou sans sauts |
| Matériel | Aucun, tapis, élastique, haltères, chaise, mur |
| Mode | Temps (secondes) ou répétitions, avec valeur par défaut |
| MET | Valeur et code du Compendium 2024 |
| Contenu | Consigne, tutoriel (étapes, respiration, erreurs fréquentes), lien vidéo, dessins départ et arrivée |
| Source | Au moins une source consultable |
| Validé | Un exercice non validé n'apparaît nulle part |

Les champs actuels (famille de variantes, tours max, validé, source) sont conservés.

## 6. Structure de l'app

- **Plan** : le programme du jour par jour, un entraînement par jour, les jours suivants verrouillés jusqu'à la séance du jour, durée croissante.
- **Entraînements** : catalogue des programmes (Remise en forme, Hanches et fessiers, Gainage et calisthénie) et démarrage rapide par zone (corps entier, abdos, jambes, bras, épaules, dos), en trois niveaux. Remplace la « roue libre ».
- **Découverte** : moments pour soi (yoga matinal, étirements du soir, méditation, gainage express).
- **Activité** : calendrier, calories par séance, objectifs du jour, habitudes et séries de jours.
- **Profil** : réponses du questionnaire, données corporelles, refaire le questionnaire.

Page d'un entraînement : en-tête niveau, durée, zone ; liste des exercices en temps ou en répétitions ; trois phases (échauffement, corps de séance, retour au calme) ; réglages avant de lancer ; favori.

Fiche d'un exercice : onglets Vidéo, Muscles, Tutoriel ; durée ou répétitions réglables ; consigne ; muscles principaux et secondaires sur une silhouette de face et de dos ; remarques perso.

## 7. Habitudes

- Une liste prête à cocher : verres d'eau, marche de 20 minutes, journée sans sucre, journée sans café, étirements du soir, coucher avant une heure choisie.
- Des habitudes perso saisies librement.
- Chaque habitude est soit « à faire », soit « à éviter », avec un compteur de jours consécutifs.

## 8. Méthodes d'estimation

**Calories** : calories ≈ MET × poids (kg) × durée d'effort (h), car 1 MET vaut environ 1 kcal par kg et par heure. Pauses comptées à 1 MET. Valeur affichée comme une estimation. Chaque exercice porte sa valeur et son code Compendium.

| Activité | Code | MET |
|---|---|---|
| Gainage, crunchs, effort léger | 02024 | 2,8 |
| Pompes, fentes, effort modéré | 02022 | 3,8 |
| Effort intense (jumping jacks, burpees) | 02020 | 7,5 |
| Renforcement au poids du corps, général | 02056 | 3,0 |
| Circuit au poids du corps | 02032 | 6,0 |
| HIIT, effort modéré | 02210 | 7,0 |
| Tabata | 02214 | 11,0 |
| Pilates au sol | 02103 | 1,8 |
| Yoga hatha | 02150 | 2,3 |
| Salutation au soleil | 02180 | 3,5 |
| Étirements doux | 02101 | 2,3 |
| Méditation | 07075 | 1,0 |
| Marche plaisir | 17160 | 3,5 |

**Pas** : 100 pas par minute pour une marche modérée, soit environ 2 000 pas pour 20 minutes. La personne peut corriger le chiffre.

Sources : Herrmann et al., 2024 Adult Compendium of Physical Activities (pacompendium.com, PMC10818145) ; Tudor-Locke et al., 2018, British Journal of Sports Medicine (PMC6029645).

## 9. Espace admin (remplace l'interface coach)

Aucune validation. Trois usages seulement :

1. **Débloquer un utilisateur** : régénérer un lien perdu, déverrouiller un jour du plan, lever un tampon « Ça fait mal » avant ses 10 jours.
2. **Savoir où en est chaque utilisateur** : programme suivi, jour atteint, dernière séance, régularité sur 4 semaines.
3. **Vue d'ensemble de l'usage** : programmes, entraînements, exercices et habitudes les plus utilisés ; exercices les plus remplacés ou signalés douloureux.

Créer un utilisateur se fait aussi depuis cet espace : un prénom, un lien personnel à envoyer.

## 10. Données et confidentialité

Nouvelles données collectées : taille, poids, année de naissance, poids cible, réponses du questionnaire. Règles : le minimum utile, une phrase d'information dans le questionnaire, tout est modifiable, et l'utilisateur peut tout effacer depuis son profil.

## 11. Migration

Les données d'Alice sont conservées : son programme actuel devient le programme « Remise en forme », son historique et ses niveaux restent. La migration se fait par un script dédié, jamais en relançant `schema.sql` à blanc.

## 12. Hors périmètre de la V5

Lecture automatique des pas, notifications, personnage à 10 niveaux, app native.
