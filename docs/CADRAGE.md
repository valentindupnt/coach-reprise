# Cadrage : application de reprise d'Alice

*Version 1, 19 octobre 2026. Coach : Valentin.*

## Objectif

Accompagner la reprise sportive d'Alice (hernie dorsale haute : ni pompes ni tractions) avec 30 minutes par jour au poids du corps, élastiques et gainage, et permettre au coach d'ajuster le programme à distance, sans renvoyer de document.

## Décisions

| Sujet | Choix |
|---|---|
| Technique | Web app indépendante : GitHub + Vercel (Hobby, gratuit) + Supabase (Free, région UE) |
| Usage | Alice d'abord ; base de données prévue pour plusieurs athlètes |
| Appareil | iPhone, app ajoutée à l'écran d'accueil |
| Accès Alice | Lien personnel secret, sans connexion (seule utilisatrice) |
| Accès coach | E-mail + mot de passe, inscriptions publiques désactivées |
| Bilan de séance | Douleur 0-10, ressenti par exercice, fourmillements / faiblesse oui-non, commentaire facultatif |
| Progression | Montée validée par le coach ; descente automatique en cas de douleur |
| Visuels | Dessins schématiques + lien vidéo par exercice (à vérifier par le coach) |
| Données | Strict minimum : prénom uniquement, aucun diagnostic |
| Tests | Le coach teste 3 à 5 jours, puis remise à zéro et lancement |
| Échéance | Alice démarre d'ici une semaine |

## Structure

**Alice** : Aujourd'hui (séance du jour, message du coach, semaine) · Séances (semaine type, toutes les séances, règles de sécurité) · Progrès (phases, niveau par exercice) · Lecteur de séance (minuteur 45 s / 30 s, consignes, bouton « Ça fait mal ») · Bilan.

**Coach** : Alertes · À valider · Fiche athlète (pause / réactivation, message, régularité 4 semaines, lien personnel, niveaux par exercice, historique, journal des niveaux).

**Données** : athlètes, catalogue d'exercices (niveaux en JSON), programme (niveau par exercice et séance), séances, ressentis, journal des changements de niveau, coachs.

## Logique de mise à jour du programme

| Situation | Effet |
|---|---|
| « Trop facile » 2 séances de suite, douleur ≤ 3, sans symptôme, aucun changement depuis 7 jours | Proposition au coach |
| Le coach valide | Niveau + 1, visible chez Alice à l'ouverture suivante |
| « Douleur » sur un exercice | Niveau − 1 automatique, inscrit au journal |
| Douleur > 3 sur la séance | Alerte coach, conseil d'alléger |
| Fourmillements / faiblesse | Programme gelé jusqu'à réactivation par le coach |
| Niveau maximal atteint et toujours trop facile | Le coach change ou ajoute un exercice (panneau coach, onglet Bibliothèque) |

Semaines : 1-2 apprentissage (2 tours), 3 volume (3 tours), 4 allégée (2 tours), 5-6 endurance, 7-8 consolidation, puis entretien.

## Feuille de route

| Version | Contenu |
|---|---|
| **V1** (livrée) | Niveaux, alertes, propositions, historique, message coach, régularité, mode hors ligne, changement de lien |
| **V2** (en cours) | Fait : édition des exercices et du programme depuis le panneau, remplacement d'exercice, bibliothèque, 2 à 4 tours, effort ressenti, date et durée réelles. Reste : graphiques douleur, export pour le kiné, modèles réutilisables |
| **V3** | Résumé hebdomadaire vers Notion (Suivi des Athlètes), plusieurs athlètes dans l'interface |

## Risques et limites

| Risque | Parade |
|---|---|
| L'app ne remplace pas un avis médical | Messages explicites, montée de niveau validée par le coach, gel sur symptôme |
| Lien partagé par erreur | Prénom seulement dans l'app ; « Changer le lien » en un clic |
| Pause Supabase après 7 jours sans activité | Réactivation en un clic dans Supabase |
| Vercel Hobby non commercial | OK tant que le coaching est gratuit |
| Liens vidéo qui disparaissent ou amplitudes trop grandes | Vérifiés par le coach ; le dessin et les consignes restent la référence |
| Bug au lancement | 24 tests de règles en base, 26 vérifications de parcours dans un navigateur iPhone, période de test coach |
| Pas de notification e-mail des alertes | Le coach consulte le tableau de bord (notification e-mail possible en V2) |
