-- =====================================================================
-- Coach Reprise : catalogue d'exercices + programme d'Alice
-- À lancer APRÈS schema.sql (SQL Editor > New query > Run).
-- Relançable : met à jour le catalogue, ne crée Alice qu'une seule fois,
-- et ne touche jamais aux niveaux déjà atteints.
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

on conflict (id) do update set
  name = excluded.name,
  kind = excluded.kind,
  illustration = excluded.illustration,
  cues = excluded.cues,
  caution = excluded.caution,
  levels = excluded.levels;

-- ---------------------------------------------------------------------
-- Alice et son programme
-- ---------------------------------------------------------------------
do $$
declare
  a_id uuid;
begin
  select id into a_id from public.athletes where first_name = 'Alice' order by created_at limit 1;
  if a_id is null then
    insert into public.athletes (first_name) values ('Alice') returning id into a_id;
  end if;

  insert into public.program_items (athlete_id, session_key, exercise_id, position)
  select a_id, v.session_key, v.exercise_id, v.position
  from (values
    ('A', 'rowing', 1), ('A', 'pull_apart', 2), ('A', 'pallof', 3),
    ('A', 'dead_bug', 4), ('A', 'bird_dog', 5), ('A', 'planche', 6),
    ('B', 'squat_chaise', 1), ('B', 'pont', 2), ('B', 'marche_laterale', 3),
    ('B', 'ext_hanche', 4), ('B', 'planche_laterale', 5), ('B', 'respiration', 6),
    ('M', 'respiration', 1), ('M', 'bascule_bassin', 2), ('M', 'chat_vache', 3),
    ('M', 'omoplates', 4), ('M', 'wall_slides', 5), ('M', 'ext_thoracique', 6),
    ('M', 'chin_tuck', 7), ('M', 'pecs_porte', 8), ('M', 'trapezes', 9),
    ('M', 'enfant', 10), ('M', 'flechisseurs', 11), ('M', 'ischios', 12),
    ('M', 'fessiers_4', 13), ('M', 'mollets', 14)
  ) as v(session_key, exercise_id, position)
  on conflict (athlete_id, session_key, exercise_id) do nothing;
end;
$$;
