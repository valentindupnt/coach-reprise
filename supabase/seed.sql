-- =====================================================================
-- Coach Reprise : catalogue d'exercices + programme d'Alice
-- À lancer APRÈS schema.sql (SQL Editor > New query > Run).
-- Relançable : ajoute les exercices manquants, ne crée Alice qu'une seule fois,
-- ne touche jamais aux niveaux déjà atteints, et ne remplace PAS les exercices
-- déjà présents (le coach peut les modifier depuis l'interface sans que ce
-- script n'écrase ses changements).
-- =====================================================================

insert into public.exercises (id, name, kind, illustration, cues, caution, levels) values

-- ---------------- Séance A : haut du corps et gainage ----------------
('rowing', 'Rowing assis à l''élastique', 'force', 'rowing',
 array['Assise, jambes tendues, l''élastique passé sous les pieds.',
       'Tire en gardant les coudes près du corps.',
       'Rapproche les omoplates sans hausser les épaules, puis relâche lentement.'],
 'Le dos reste droit : on ne se penche pas en arrière pour tirer.',
 '[{"label":"Assise, élastique léger"},
   {"label":"Assise, élastique moyen"},
   {"label":"Debout, un pied en avant, élastique fixé à hauteur de poitrine"},
   {"label":"Un bras à la fois, pause de 2 s coude en arrière"}]'),

('pull_apart', 'Écarté à l''élastique (band pull-apart)', 'force', 'pull_apart',
 array['Debout, bras tendus devant toi, l''élastique dans les mains.',
       'Écarte l''élastique en serrant les omoplates.',
       'Reviens lentement, sans relâcher d''un coup.'],
 'Jamais au-dessus de la tête : les bras restent à hauteur de poitrine ou plus bas.',
 '[{"label":"Élastique léger, bras un peu plus bas que la poitrine"},
   {"label":"Bras à hauteur de poitrine"},
   {"label":"Élastique plus ferme"},
   {"label":"Tempo lent, pause de 2 s bras écartés"}]'),

('pallof', 'Pallof press (anti-rotation)', 'gainage', 'pallof',
 array['L''élastique est fixé sur le côté, à hauteur de poitrine.',
       'Mains contre le sternum, pousse droit devant toi.',
       'Résiste : le buste ne doit pas tourner vers l''élastique. Change de côté à mi-temps.'],
 'Respire normalement, sans bloquer ta respiration.',
 '[{"label":"Debout, pieds serrés, élastique léger"},
   {"label":"Pieds écartés largeur de bassin"},
   {"label":"Pas décalés, une jambe devant"},
   {"label":"Élastique plus fort"}]'),

('dead_bug', 'Dead bug', 'gainage', 'dead_bug',
 array['Allongée sur le dos, genoux à 90°, bras tendus vers le plafond.',
       'Expire et descends lentement un talon vers le sol, avec le bras opposé.',
       'Reviens au centre et change de côté. Le bas du dos reste collé au sol.'],
 'Si le dos se creuse ou que ça tire, réduis l''amplitude : tu gardes le bénéfice.',
 '[{"label":"Une jambe seule, le pied effleure le sol"},
   {"label":"Bras et jambe opposés"},
   {"label":"Bras et jambe opposés, élastique léger dans les mains"},
   {"label":"Mouvement très lent, pause de 2 s en extension"}]'),

('bird_dog', 'Bird-dog', 'gainage', 'bird_dog',
 array['À quatre pattes, mains sous les épaules, genoux sous les hanches.',
       'Allonge lentement en gardant le dos plat, comme une table.',
       'Reviens, puis change de côté.'],
 'Le bassin ne bascule pas sur le côté et le bas du dos ne se creuse pas.',
 '[{"label":"Un bras seul"},
   {"label":"Une jambe seule"},
   {"label":"Bras et jambe opposés"},
   {"label":"Bras et jambe opposés, pause de 3 s"}]'),

('planche', 'Planche', 'gainage', 'planche',
 array['Appui sur les avant-bras, coudes sous les épaules.',
       'Rentre légèrement le ventre et serre les fessiers.',
       'Le corps forme une ligne droite, le regard vers le sol.'],
 'Si le bas du dos s''affaisse ou que ça tire, arrête le maintien et reprends plus court.',
 '[{"label":"Sur les genoux","seconds":15},
   {"label":"Sur les genoux","seconds":30},
   {"label":"Sur les pieds (après accord du kiné)","seconds":15},
   {"label":"Sur les pieds","seconds":30}]'),

-- ---------------- Séance B : bas du corps et chaîne arrière ----------------
('squat_chaise', 'Squat sur chaise', 'force', 'squat_chaise',
 array['Debout devant une chaise, pieds largeur de bassin.',
       'Assieds-toi lentement en poussant les fesses vers l''arrière.',
       'Effleure la chaise et remonte en poussant dans les talons.'],
 'Le dos reste long, le buste peut se pencher un peu mais sans s''arrondir.',
 '[{"label":"Sans élastique"},
   {"label":"Mini-band autour des genoux"},
   {"label":"Chaise plus basse"},
   {"label":"Sans chaise, amplitude contrôlée"}]'),

('pont', 'Pont fessier', 'force', 'pont',
 array['Allongée sur le dos, genoux pliés, pieds à plat.',
       'Serre les fessiers et monte le bassin jusqu''à aligner genoux, hanches et épaules.',
       'Redescends lentement, vertèbre par vertèbre.'],
 'On ne cambre pas en haut : ce sont les fessiers qui travaillent, pas le bas du dos.',
 '[{"label":"Sans élastique"},
   {"label":"Mini-band au-dessus des genoux"},
   {"label":"Pause de 3 s en haut"},
   {"label":"Une jambe seule (si le bassin reste stable)"}]'),

('marche_laterale', 'Marche latérale à l''élastique', 'force', 'marche_laterale',
 array['Mini-band au-dessus des genoux, genoux légèrement fléchis.',
       'Fais des petits pas sur le côté sans rapprocher complètement les pieds.',
       'Le buste reste droit et stable. Change de sens à mi-temps.'],
 null,
 '[{"label":"Petits pas, élastique léger"},
   {"label":"Élastique plus ferme"},
   {"label":"Élastique aux chevilles"},
   {"label":"En position de squat léger"}]'),

('ext_hanche', 'Extension de hanche à quatre pattes', 'force', 'ext_hanche',
 array['À quatre pattes, dos plat.',
       'Pousse un talon vers le plafond, genou plié, en serrant le fessier.',
       'Reviens lentement. Change de côté à mi-temps.'],
 'Monte seulement jusqu''où le bas du dos reste neutre, sans se creuser.',
 '[{"label":"Petite amplitude"},
   {"label":"Amplitude complète contrôlée"},
   {"label":"Mini-band au-dessus des genoux"},
   {"label":"Pause de 2 s en haut"}]'),

('planche_laterale', 'Planche latérale', 'gainage', 'planche_laterale',
 array['Sur le côté, appui sur l''avant-bras, coude sous l''épaule.',
       'Monte le bassin pour aligner tête, bassin et genoux.',
       'Fais la moitié du temps de chaque côté.'],
 'L''épaule d''appui reste basse, loin de l''oreille.',
 '[{"label":"Sur le genou","seconds":20},
   {"label":"Sur le genou","seconds":40},
   {"label":"Sur les pieds","seconds":30},
   {"label":"Sur les pieds","seconds":45}]'),

('respiration', 'Respiration costale', 'respiration', 'respiration',
 array['Allongée sur le dos, genoux pliés, mains sur les côtes.',
       'Inspire par le nez en écartant les côtes sur les côtés, dans tes mains.',
       'Expire longuement par la bouche en relâchant les épaules.'],
 null,
 '[{"label":"Allongée","seconds":60},
   {"label":"Assise, dos droit","seconds":60}]'),

-- ---------------- Mobilité ----------------
('bascule_bassin', 'Bascule du bassin', 'mobilite', 'bascule_bassin',
 array['Allongée sur le dos, genoux pliés.',
       'Plaque doucement le bas du dos au sol, puis relâche.',
       'Mouvement lent, au rythme de la respiration.'],
 null,
 '[{"label":"8 répétitions, petite amplitude","seconds":45},
   {"label":"10 répétitions","seconds":60},
   {"label":"10 répétitions, amplitude un peu plus grande","seconds":60}]'),

('chat_vache', 'Chat-vache', 'mobilite', 'chat_vache',
 array['À quatre pattes, mains sous les épaules.',
       'Inspire en creusant doucement le dos, expire en l''arrondissant.',
       'Reste dans une amplitude confortable.'],
 'Petite amplitude : on ne cherche pas à aller loin dans la cambrure.',
 '[{"label":"8 répétitions, petite amplitude","seconds":45},
   {"label":"10 répétitions","seconds":60},
   {"label":"10 répétitions, amplitude un peu plus grande","seconds":60}]'),

('omoplates', 'Rapprochement des omoplates', 'mobilite', 'omoplates',
 array['Assise, dos droit, bras le long du corps.',
       'Rapproche les omoplates comme pour tenir un crayon entre elles.',
       'Tiens 3 s, puis relâche.'],
 'Le bas du dos ne se cambre pas.',
 '[{"label":"8 répétitions","seconds":45},
   {"label":"10 répétitions, maintien 3 s","seconds":60},
   {"label":"12 répétitions, maintien 5 s","seconds":75}]'),

('wall_slides', 'Glissés de bras au mur', 'mobilite', 'wall_slides',
 array['Dos, tête et bras contre le mur, coudes pliés.',
       'Fais glisser les bras vers le haut en gardant le contact avec le mur.',
       'Monte seulement jusqu''où c''est confortable.'],
 'Arrête la montée avant que le dos ne décolle ou que la douleur apparaisse.',
 '[{"label":"8 répétitions, petite montée","seconds":45},
   {"label":"10 répétitions","seconds":60},
   {"label":"10 répétitions, montée un peu plus haute","seconds":60}]'),

('ext_thoracique', 'Extension thoracique sur chaise', 'mobilite', 'ext_thoracique',
 array['Assise, le haut du dos contre le dossier de la chaise.',
       'Mains croisées sur la poitrine, ouvre doucement la poitrine vers le plafond.',
       'Petite extension, puis reviens.'],
 'Seulement si ça soulage ou reste neutre. Si ça réveille la douleur, saute cet exercice.',
 '[{"label":"6 répétitions, très petite amplitude","seconds":45},
   {"label":"8 répétitions","seconds":60},
   {"label":"10 répétitions","seconds":60}]'),

('chin_tuck', 'Menton rentré', 'mobilite', 'chin_tuck',
 array['Assise ou debout, regard droit devant.',
       'Recule le menton comme pour faire un double menton, la nuque s''allonge.',
       'Tiens 3 s, puis relâche.'],
 null,
 '[{"label":"8 répétitions","seconds":45},
   {"label":"10 répétitions, maintien 3 s","seconds":60},
   {"label":"12 répétitions, maintien 5 s","seconds":75}]'),

-- ---------------- Étirements ----------------
('pecs_porte', 'Étirement des pectoraux (porte)', 'etirement', 'pecs_porte',
 array['Avant-bras posé sur l''encadrement d''une porte, coude à hauteur d''épaule ou plus bas.',
       'Avance doucement le buste jusqu''à sentir l''étirement dans la poitrine.',
       'Fais les deux côtés.'],
 'Le bras ne monte jamais au-dessus de l''épaule.',
 '[{"label":"2 × 20 s par côté","seconds":80},
   {"label":"2 × 30 s par côté","seconds":120},
   {"label":"2 × 30 s, un peu plus d''amplitude","seconds":120}]'),

('trapezes', 'Étirement des trapèzes', 'etirement', 'trapezes',
 array['Assise, épaules relâchées.',
       'Penche doucement l''oreille vers l''épaule.',
       'Sans tirer avec la main. Fais les deux côtés.'],
 null,
 '[{"label":"2 × 20 s par côté","seconds":80},
   {"label":"2 × 30 s par côté","seconds":120}]'),

('enfant', 'Posture de l''enfant', 'etirement', 'enfant',
 array['À genoux, assieds-toi sur les talons.',
       'Allonge le buste vers l''avant, front vers le sol.',
       'Bras le long du corps si les bras tendus gênent.'],
 'Reste dans une amplitude confortable, sans forcer.',
 '[{"label":"20 s","seconds":20},
   {"label":"30 s","seconds":30},
   {"label":"45 s","seconds":45}]'),

('flechisseurs', 'Étirement des fléchisseurs de hanche', 'etirement', 'flechisseurs',
 array['En fente basse, genou arrière au sol sur un coussin.',
       'Rentre légèrement le bassin, puis avance-le doucement.',
       'Fais les deux côtés.'],
 'Le bas du dos ne se cambre pas : c''est le bassin qui bascule.',
 '[{"label":"2 × 20 s par côté","seconds":80},
   {"label":"2 × 30 s par côté","seconds":120}]'),

('ischios', 'Étirement des ischio-jambiers', 'etirement', 'ischios',
 array['Allongée sur le dos, une serviette ou un élastique sous le pied.',
       'Monte la jambe, genou peu ou pas tendu, jusqu''à sentir l''étirement.',
       'Fais les deux côtés.'],
 'Si une douleur descend dans la jambe, plie davantage le genou ou arrête.',
 '[{"label":"2 × 20 s par côté","seconds":80},
   {"label":"2 × 30 s par côté","seconds":120}]'),

('fessiers_4', 'Étirement des fessiers en « 4 »', 'etirement', 'fessiers_4',
 array['Allongée sur le dos, une cheville posée sur le genou opposé.',
       'Rapproche doucement la jambe d''appui vers toi.',
       'Fais les deux côtés.'],
 null,
 '[{"label":"2 × 20 s par côté","seconds":80},
   {"label":"2 × 30 s par côté","seconds":120}]'),

('mollets', 'Étirement des mollets', 'etirement', 'mollets',
 array['Debout face à un mur, mains en appui.',
       'Une jambe en arrière, talon au sol, genou tendu.',
       'Avance le bassin doucement. Fais les deux côtés.'],
 null,
 '[{"label":"2 × 20 s par côté","seconds":80},
   {"label":"2 × 30 s par côté","seconds":120}]')

on conflict (id) do nothing;

-- ---------------------------------------------------------------------
-- Bibliothèque V2 : description des exercices existants (zones, matériel, intensité, famille)
-- Ne s'applique qu'aux exercices pas encore décrits : une relance n'écrase rien.
-- Les 25 exercices de la V1 sont déjà validés par le coach (approved = true).
-- ---------------------------------------------------------------------
update public.exercises e set
  zones = v.zones, equipment = v.equipment, intensity = v.intensity,
  family = v.family, pattern = v.pattern, max_sets = v.max_sets, approved = true,
  source = coalesce(e.source, 'Programme de départ du coach')
from (values
  ('rowing',           array['dos','bras'],            array['elastique'],            2, 'tirage',              'tirage',          4),
  ('pull_apart',       array['dos','epaules'],         array['elastique'],            2, 'retraction-scapulaire','tirage',         4),
  ('pallof',           array['obliques','abdos'],      array['elastique'],            2, 'anti-rotation',       'anti-rotation',   4),
  ('dead_bug',         array['abdos'],                 array['aucun'],                2, 'abdos-profonds',      'anti-extension',  4),
  ('bird_dog',         array['lombaires','fessiers'],  array['aucun'],                2, 'stabilite-dos',       'stabilite-dos',   4),
  ('planche',          array['abdos','epaules'],       array['aucun'],                3, 'planche',             'anti-extension',  3),
  ('squat_chaise',     array['cuisses','fessiers'],    array['chaise','mini-band'],   3, 'squat',               'squat',           4),
  ('pont',             array['fessiers','ischios'],    array['aucun','mini-band'],    2, 'pont',                'pont',            4),
  ('marche_laterale',  array['fessiers','hanches'],    array['mini-band'],            2, 'abduction-hanche',    'abduction',       4),
  ('ext_hanche',       array['fessiers'],              array['aucun','mini-band'],    2, 'extension-hanche',    'extension-hanche',4),
  ('planche_laterale', array['obliques','hanches'],    array['aucun'],                3, 'planche-laterale',    'gainage-lateral', 3),
  ('respiration',      array['respiration','abdos'],   array['aucun'],                1, null,                  'respiration',     1),
  ('bascule_bassin',   array['lombaires','abdos'],     array['aucun'],                1, null,                  'mobilite',        1),
  ('chat_vache',       array['lombaires','thorax'],    array['aucun'],                1, null,                  'mobilite',        1),
  ('omoplates',        array['dos','thorax'],          array['aucun'],                1, 'mobilite-scapulaire', 'mobilite',        1),
  ('wall_slides',      array['epaules','thorax'],      array['mur'],                  1, 'mobilite-scapulaire', 'mobilite',        1),
  ('ext_thoracique',   array['thorax'],                array['chaise'],               1, 'mobilite-thoracique', 'mobilite',        1),
  ('chin_tuck',        array['cou'],                   array['aucun'],                1, null,                  'mobilite',        1),
  ('pecs_porte',       array['pectoraux','epaules'],   array['mur'],                  1, null,                  'etirement',       1),
  ('trapezes',         array['cou','epaules'],         array['aucun'],                1, null,                  'etirement',       1),
  ('enfant',           array['dos','lombaires'],       array['aucun'],                1, null,                  'etirement',       1),
  ('flechisseurs',     array['hanches','cuisses'],     array['coussin'],              1, null,                  'etirement',       1),
  ('ischios',          array['ischios'],               array['serviette'],            1, null,                  'etirement',       1),
  ('fessiers_4',       array['fessiers','hanches'],    array['aucun'],                1, null,                  'etirement',       1),
  ('mollets',          array['mollets'],               array['mur'],                  1, null,                  'etirement',       1)
) as v(id, zones, equipment, intensity, family, pattern, max_sets)
where e.id = v.id and e.zones = '{}';

-- ---------------------------------------------------------------------
-- Nouveaux exercices de la bibliothèque. TOUS « à valider » (approved = false) :
-- ils ne sont proposés à l'athlète qu'après ton accord, exercice par exercice, dans
-- l'onglet Bibliothèque. Adaptés de sources publiques (voir docs/BIBLIOTHEQUE.md),
-- pas d'illustration pour l'instant. À relire avec le kiné d'Alice.
-- ---------------------------------------------------------------------
insert into public.exercises
  (id, name, kind, illustration, cues, caution, levels, zones, equipment, intensity, family, pattern, max_sets, approved, source) values

('glissement_talon', 'Glissement de talon', 'gainage', null,
 array['Allongée sur le dos, genoux pliés, pieds à plat.',
       'Expire et fais glisser un talon vers l''avant jusqu''à tendre la jambe, sans creuser le dos.',
       'Reviens lentement, puis change de jambe.'],
 'Le bas du dos reste stable : réduis l''amplitude s''il se creuse.',
 '[{"label":"Petite amplitude, une jambe après l''autre"},
   {"label":"Jambe tendue complète"},
   {"label":"Avec un mini-band autour des pieds"}]',
 array['abdos'], array['aucun','mini-band'], 1, 'abdos-profonds', 'anti-extension', 4, false,
 'Protocole de rééducation discale conservatrice, Mass General Brigham (phase I)'),

('planche_inclinee', 'Planche inclinée, mains en appui', 'gainage', null,
 array['Mains sur le mur ou sur l''assise d''une chaise stable, corps en ligne droite.',
       'Rentre légèrement le ventre et serre les fessiers.',
       'Respire normalement pendant le maintien.'],
 'Si le bas du dos s''affaisse, rapproche les pieds du support.',
 '[{"label":"Mains au mur","seconds":20},
   {"label":"Mains sur une chaise","seconds":20},
   {"label":"Mains sur une chaise","seconds":30}]',
 array['abdos','epaules'], array['mur','chaise'], 2, 'planche', 'anti-extension', 4, false,
 'Régression de la planche, progression habituelle de gainage'),

('pallof_genoux', 'Pallof press à genoux', 'gainage', null,
 array['À genoux sur un coussin, l''élastique fixé sur le côté à hauteur de poitrine.',
       'Mains contre le sternum, pousse droit devant toi.',
       'Résiste : le buste ne tourne pas. Change de côté à mi-temps.'],
 'Respire normalement, sans bloquer ta respiration.',
 '[{"label":"Élastique léger, à genoux"},
   {"label":"Élastique plus ferme"},
   {"label":"Un genou levé (demi-genou)"}]',
 array['obliques','abdos'], array['elastique','coussin'], 2, 'anti-rotation', 'anti-rotation', 4, false,
 'Variante du Pallof press (anti-rotation)'),

('rowing_debout', 'Rowing debout à l''élastique', 'force', null,
 array['Élastique fixé à hauteur de poitrine (poignée de porte), un pied devant l''autre.',
       'Tire vers toi en gardant le buste immobile et les coudes près du corps.',
       'Rapproche les omoplates, puis reviens lentement.'],
 'Pas de balancement du buste pour s''aider à tirer.',
 '[{"label":"Élastique léger"},
   {"label":"Élastique moyen"},
   {"label":"Un bras à la fois"}]',
 array['dos','bras'], array['elastique'], 2, 'tirage', 'tirage', 4, false,
 'Variante debout du rowing à l''élastique'),

('face_pull_bas', 'Tirage coudes écartés à l''élastique', 'force', null,
 array['Élastique fixé à hauteur de poitrine, bras tendus devant toi.',
       'Tire vers le haut de la poitrine, coudes écartés à hauteur d''épaule.',
       'Serre les omoplates, puis reviens lentement.'],
 'Jamais au-dessus de la tête : les épaules restent loin des oreilles.',
 '[{"label":"Élastique léger"},
   {"label":"Élastique moyen"},
   {"label":"Pause de 2 s en fin de tirage"}]',
 array['epaules','dos'], array['elastique'], 2, 'retraction-scapulaire', 'tirage', 3, false,
 'Variante de l''écarté à l''élastique'),

('rotation_externe', 'Rotation externe d''épaule à l''élastique', 'force', null,
 array['Coude collé au corps, plié à 90°, une serviette roulée entre le coude et le côté.',
       'Écarte l''avant-bras vers l''extérieur sans bouger le coude.',
       'Reviens lentement. Change de côté à mi-temps.'],
 'Mouvement petit et lent : l''épaule reste basse.',
 '[{"label":"Élastique très léger"},
   {"label":"Élastique léger"},
   {"label":"Élastique moyen"}]',
 array['epaules'], array['elastique','serviette'], 1, 'stabilite-epaule', 'rotation-epaule', 3, false,
 'Renforcement classique de la coiffe des rotateurs'),

('elevation_laterale', 'Élévation latérale à l''élastique', 'force', null,
 array['Debout sur l''élastique, bras le long du corps, buste droit.',
       'Monte les bras sur les côtés jusqu''à hauteur d''épaule, pas plus haut.',
       'Redescends lentement.'],
 'Jamais au-dessus de l''épaule, sans hausser les épaules.',
 '[{"label":"Élastique léger"},
   {"label":"Élastique moyen"},
   {"label":"Tempo lent, 3 s à la descente"}]',
 array['epaules'], array['elastique'], 2, 'epaules', 'elevation', 3, false,
 'Exercice d''épaule standard, amplitude limitée'),

('curl_biceps', 'Curl des biceps à l''élastique', 'force', null,
 array['Debout sur l''élastique, coudes collés au corps.',
       'Plie les coudes pour monter les mains vers les épaules.',
       'Redescends lentement, sans cambrer le dos.'],
 'Le buste reste immobile : pas d''élan avec le dos.',
 '[{"label":"Élastique léger"},
   {"label":"Élastique moyen"},
   {"label":"Un bras à la fois"}]',
 array['bras'], array['elastique'], 1, 'bras', 'flexion-coude', 3, false,
 'Exercice d''isolation standard'),

('triceps_elastique', 'Extension des triceps à l''élastique', 'force', null,
 array['Élastique fixé en hauteur (poignée de porte), coudes pliés près du corps.',
       'Tends les bras vers le bas sans bouger les coudes.',
       'Reviens lentement.'],
 'Le buste reste droit et immobile.',
 '[{"label":"Élastique léger"},
   {"label":"Élastique moyen"},
   {"label":"Un bras à la fois"}]',
 array['bras'], array['elastique'], 1, 'bras', 'extension-coude', 3, false,
 'Exercice d''isolation standard, alternative sans pompes'),

('clamshell', 'Clamshell (coquillage)', 'force', null,
 array['Allongée sur le côté, genoux pliés, pieds joints.',
       'Ouvre le genou du dessus sans faire bouger le bassin.',
       'Reviens lentement, change de côté à mi-temps.'],
 'Le bassin ne bascule pas vers l''arrière.',
 '[{"label":"Sans élastique"},
   {"label":"Mini-band au-dessus des genoux"},
   {"label":"Mini-band, pause de 2 s genou ouvert"}]',
 array['fessiers','hanches'], array['aucun','mini-band'], 1, 'abduction-hanche', 'abduction', 4, false,
 'ACE Fitness ; protocole de rééducation discale, Mass General Brigham (phase I)'),

('abduction_couchee', 'Levée de jambe sur le côté', 'force', null,
 array['Sur le côté, jambe du bas pliée, jambe du dessus tendue dans l''axe du corps.',
       'Monte la jambe du dessus d''environ 30 cm, pointe du pied vers l''avant.',
       'Redescends lentement, change de côté à mi-temps.'],
 'Le bassin reste stable, sans rouler vers l''arrière.',
 '[{"label":"Petite amplitude"},
   {"label":"Amplitude contrôlée"},
   {"label":"Mini-band au-dessus des genoux"}]',
 array['fessiers','hanches'], array['aucun','mini-band'], 2, 'abduction-hanche', 'abduction', 3, false,
 'Exercice de fessiers standard'),

('squat_mur', 'Squat partiel contre le mur', 'force', null,
 array['Dos contre le mur, pieds à environ 40 cm du mur, largeur de bassin.',
       'Descends lentement, sans aller plus bas que les genoux à 90°.',
       'Remonte en poussant dans les talons.'],
 'Les genoux suivent la direction des pieds ; douleur à 3 sur 10 maximum.',
 '[{"label":"Petite amplitude"},
   {"label":"Cuisses presque parallèles au sol"},
   {"label":"Mini-band autour des genoux"},
   {"label":"Maintien de 20 s en position basse","seconds":20}]',
 array['cuisses','fessiers'], array['mur','mini-band'], 2, 'squat', 'squat', 4, false,
 'Protocole de rééducation discale conservatrice, Mass General Brigham (phase II)'),

('montee_marche', 'Montée sur marche basse', 'force', null,
 array['Face à une marche stable de 15 à 20 cm, une main appuyée au mur.',
       'Pose un pied dessus et monte en poussant avec cette jambe.',
       'Redescends lentement, change de jambe à mi-temps.'],
 'La marche ne glisse pas ; reste près du mur pour t''équilibrer.',
 '[{"label":"Marche de 10 cm, main au mur"},
   {"label":"Marche de 15 à 20 cm"},
   {"label":"Sans appui de la main"}]',
 array['cuisses','fessiers'], array['aucun','mur'], 3, 'marche-unilaterale', 'marche-unilaterale', 3, false,
 'Exercice de jambes unilatéral standard'),

('pont_ischios', 'Pont fessier, pieds éloignés (ischio-jambiers)', 'force', null,
 array['Allongée sur le dos, pieds à plat un peu plus loin des fesses que pour le pont classique.',
       'Monte le bassin en poussant dans les talons.',
       'Redescends lentement, vertèbre par vertèbre.'],
 'Pas de crampe aux ischio-jambiers : rapproche les pieds si besoin.',
 '[{"label":"Pieds à plat"},
   {"label":"Pieds sur une serviette, glissement léger"},
   {"label":"Une jambe seule (si le bassin reste stable)"}]',
 array['ischios','fessiers'], array['aucun','serviette'], 2, 'pont', 'pont', 4, false,
 'ACE Fitness (curl des ischio-jambiers), adapté au sol'),

('extension_hanche_debout', 'Extension de hanche debout à l''élastique', 'force', null,
 array['Debout face au mur, mains en appui, élastique autour des chevilles.',
       'Pousse une jambe vers l''arrière sans creuser le dos.',
       'Reviens lentement, change de jambe à mi-temps.'],
 'Le bassin et le dos restent immobiles : petite amplitude.',
 '[{"label":"Élastique léger, petite amplitude"},
   {"label":"Élastique moyen"},
   {"label":"Pause de 2 s jambe tendue"}]',
 array['fessiers','ischios'], array['elastique','mur'], 2, 'extension-hanche', 'extension-hanche', 3, false,
 'Variante debout de l''extension de hanche à quatre pattes'),

('releve_mollets', 'Montée sur pointes de pieds', 'force', null,
 array['Debout, mains au mur, pieds largeur de bassin.',
       'Monte lentement sur la pointe des pieds.',
       'Redescends en 3 secondes.'],
 null,
 '[{"label":"Deux pieds"},
   {"label":"Deux pieds, descente lente de 3 s"},
   {"label":"Un pied à la fois"}]',
 array['mollets'], array['mur'], 1, 'mollets', 'mollets', 4, false,
 'Exercice de mollets standard'),

('livre_ouvert', 'Livre ouvert (rotation du haut du dos)', 'mobilite', null,
 array['Allongée sur le côté, genoux pliés, bras tendus devant toi.',
       'Ouvre le bras du dessus vers l''arrière en suivant la main du regard.',
       'Reviens lentement, change de côté.'],
 'Seul le haut du dos tourne : les genoux restent collés.',
 '[{"label":"8 répétitions par côté","seconds":60},
   {"label":"10 répétitions par côté","seconds":75}]',
 array['thorax'], array['aucun'], 1, 'mobilite-thoracique', 'mobilite', 1, false,
 'Mobilisation thoracique classique'),

('curl_up_mcgill', 'Curl-up de McGill', 'gainage', null,
 array['Allongée sur le dos, une jambe tendue, l''autre genou plié, mains sous le creux du dos.',
       'Expire et soulève légèrement la tête et les épaules, sans bouger le bas du dos.',
       'Maintiens 10 s en respirant, puis redescends lentement. Change de jambe.'],
 'Mouvement de flexion légère : à valider avec le kiné avant de le proposer.',
 '[{"label":"5 maintiens de 10 s","seconds":60},
   {"label":"Pyramide 5 - 3 - 1 maintiens de 10 s","seconds":90}]',
 array['abdos'], array['aucun'], 2, 'abdos-profonds', 'anti-extension', 3, false,
 'Stuart McGill, Big Three (Harvard Health Publishing)')

on conflict (id) do nothing;

-- ---------------------------------------------------------------------
-- Alice et son programme
-- Chaque séance A et B : échauffement (warmup), circuit (main), retour au calme (cooldown).
-- La séance M est un enchaînement unique.
-- ---------------------------------------------------------------------
create or replace function public._seed_program(a_id uuid)
returns void
language plpgsql volatile
set search_path = public
as $$
begin
  insert into public.program_items (athlete_id, session_key, exercise_id, block, position)
  select a_id, v.session_key, v.exercise_id, v.block, v.position
  from (values
    ('A', 'warmup',   'respiration',     1), ('A', 'warmup',   'bascule_bassin',  2), ('A', 'warmup',   'chat_vache',   3),
    ('A', 'main',     'rowing',          1), ('A', 'main',     'pull_apart',      2), ('A', 'main',     'pallof',       3),
    ('A', 'main',     'dead_bug',        4), ('A', 'main',     'bird_dog',        5), ('A', 'main',     'planche',      6),
    ('A', 'cooldown', 'enfant',          1), ('A', 'cooldown', 'pecs_porte',      2),
    ('B', 'warmup',   'respiration',     1), ('B', 'warmup',   'bascule_bassin',  2), ('B', 'warmup',   'chat_vache',   3),
    ('B', 'main',     'squat_chaise',    1), ('B', 'main',     'pont',            2), ('B', 'main',     'marche_laterale', 3),
    ('B', 'main',     'ext_hanche',      4), ('B', 'main',     'planche_laterale',5),
    ('B', 'cooldown', 'flechisseurs',    1), ('B', 'cooldown', 'ischios',         2), ('B', 'cooldown', 'fessiers_4',   3),
    ('M', 'main',     'respiration',     1), ('M', 'main',     'bascule_bassin',  2), ('M', 'main',     'chat_vache',   3),
    ('M', 'main',     'omoplates',       4), ('M', 'main',     'wall_slides',     5), ('M', 'main',     'ext_thoracique',6),
    ('M', 'main',     'chin_tuck',       7), ('M', 'main',     'pecs_porte',      8), ('M', 'main',     'trapezes',     9),
    ('M', 'main',     'enfant',         10), ('M', 'main',     'flechisseurs',   11), ('M', 'main',     'ischios',     12),
    ('M', 'main',     'fessiers_4',     13), ('M', 'main',     'mollets',        14)
  ) as v(session_key, block, exercise_id, position)
  on conflict (athlete_id, session_key, exercise_id) do nothing;

  -- Programme V1 déjà en place : la respiration de la séance B passe de la fin du circuit à l'échauffement
  update public.program_items
     set block = 'warmup', position = 1
   where athlete_id = a_id and session_key = 'B' and exercise_id = 'respiration'
     and block = 'main' and position = 6;
end;
$$;
revoke all on function public._seed_program(uuid) from public, anon, authenticated;

do $$
declare
  a_id uuid;
begin
  select id into a_id from public.athletes where first_name = 'Alice' order by created_at limit 1;
  if a_id is null then
    insert into public.athletes (first_name) values ('Alice') returning id into a_id;
  end if;
  perform public._seed_program(a_id);
end;
$$;

-- V5 : étiquettes (zones, objectifs, discipline, MET) déduites pour les exercices pas encore étiquetés
select public._v5_backfill_exercise_tags();
