-- =====================================================================
-- Contenu V5 (bloc 2) : exercices sourcés, yoga, étirements, méditation,
-- entraînements et programmes. FICHIER GÉNÉRÉ par scripts/build-content.mjs
-- à partir de content/v5/*.mjs : ne pas le modifier à la main.
--
-- À lancer APRÈS schema.sql et seed.sql (SQL Editor > New query > Run).
-- Additif et relançable :
--   - les nouveaux exercices, entraînements et programmes arrivent « à valider »
--     (approved = false) : ils n'apparaissent nulle part tant qu'ils ne sont pas validés ;
--   - une relance met à jour le contenu encore à valider, jamais ce qui a déjà été validé ;
--   - les 43 exercices existants reçoivent leurs étiquettes sourcées, sans toucher à leur nom,
--     leurs consignes, leurs niveaux ni leur statut de validation.
-- =====================================================================

-- ---------------------------------------------------------------- 1. Nouveaux exercices
insert into public.exercises (id, name, kind, illustration, video_url, cues, caution, levels, zones, equipment, intensity, family, pattern, max_sets, approved, source, muscles_primary, muscles_secondary, areas, goals, discipline, impact, mode, default_value, met, met_code, tutorial) values
('squat', 'Squat au poids du corps', 'force', null, null, array['Debout, pieds un peu plus écartés que les hanches, pointes légèrement ouvertes.', 'Pousse les fesses en arrière et descends comme pour t''asseoir, poitrine ouverte.', 'Remonte en poussant dans tout le pied, genoux dans l''axe des orteils.']::text[], 'Descends seulement jusqu''où ton dos reste long et tes talons au sol.', '[{"label":"Amplitude confortable","reps":10},{"label":"Cuisses parallèles au sol","reps":12},{"label":"Descente lente en 3 s","reps":12},{"label":"Pause de 2 s en bas","reps":15}]'::jsonb, array['cuisses', 'fessiers']::text[], array['aucun']::text[], 2, 'squat', 'squat', 4, false, 'free-exercise-db (domaine public), fiche Bodyweight Squat (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Bodyweight_Squat.json) ; NHS, Strength exercises (https://www.nhs.uk/live-well/exercise/strength-and-flexibility-exercises/strength-exercises/)', array['quadriceps', 'grand_fessier']::text[], array['ischio_jambiers', 'adducteurs', 'lombaires']::text[], array['jambes', 'fessiers']::text[], array['renforcer', 'tonifier']::text[], 'renforcement', false, 'reps', 12, 3.0, '02056', '{"steps":["Debout, pieds un peu plus écartés que les hanches, pointes légèrement ouvertes.","Pousse les fesses en arrière et descends comme pour t''asseoir, poitrine ouverte.","Remonte en poussant dans tout le pied, genoux dans l''axe des orteils."],"breathing":"Inspire en descendant, expire en remontant.","mistakes":["Genoux qui rentrent vers l''intérieur.","Talons qui décollent.","Dos qui s''arrondit en bas."]}'::jsonb),
('squat_sumo', 'Squat sumo', 'force', null, null, array['Pieds bien plus écartés que les épaules, pointes tournées vers l''extérieur.', 'Descends le bassin à la verticale, buste droit, genoux ouverts vers les pieds.', 'Remonte en serrant les fessiers.']::text[], 'Les genoux suivent toujours la direction des pointes de pied.', '[{"label":"Amplitude confortable","reps":10},{"label":"Cuisses parallèles au sol","reps":12},{"label":"Pause de 2 s en bas","reps":12},{"label":"Haltère tenu des deux mains","reps":12}]'::jsonb, array['cuisses', 'fessiers']::text[], array['aucun']::text[], 2, 'squat', 'squat', 4, false, 'free-exercise-db (domaine public), fiche Plie Dumbbell Squat (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Plie_Dumbbell_Squat.json)', array['adducteurs', 'grand_fessier', 'quadriceps']::text[], array['ischio_jambiers']::text[], array['jambes', 'fessiers']::text[], array['renforcer', 'tonifier']::text[], 'renforcement', false, 'reps', 12, 3.0, '02056', '{"steps":["Pieds bien plus écartés que les épaules, pointes tournées vers l''extérieur.","Descends le bassin à la verticale, buste droit, genoux ouverts vers les pieds.","Remonte en serrant les fessiers."],"breathing":"Inspire en descendant, expire en remontant.","mistakes":["Pencher le buste en avant.","Laisser les genoux se refermer."]}'::jsonb),
('chaise_mur', 'Chaise contre le mur', 'force', null, null, array['Dos plaqué contre le mur, pieds à environ 50 cm du mur.', 'Glisse vers le bas jusqu''à la hauteur choisie, genoux au-dessus des chevilles.', 'Tiens la position, mains sur les cuisses ou bras croisés.']::text[], 'Si une douleur apparaît dans le genou, remonte un peu.', '[{"label":"Genoux peu fléchis","seconds":20},{"label":"Genoux peu fléchis","seconds":30},{"label":"Cuisses presque parallèles au sol","seconds":30},{"label":"Cuisses parallèles au sol","seconds":45}]'::jsonb, array['cuisses']::text[], array['mur']::text[], 3, 'squat-isometrique', 'squat', 3, false, 'NHS, Strength exercises (https://www.nhs.uk/live-well/exercise/strength-and-flexibility-exercises/strength-exercises/)', array['quadriceps']::text[], array['grand_fessier', 'adducteurs']::text[], array['jambes']::text[], array['renforcer', 'tonifier']::text[], 'renforcement', false, 'time', 30, 3.0, '02056', '{"steps":["Dos plaqué contre le mur, pieds à environ 50 cm du mur.","Glisse vers le bas jusqu''à la hauteur choisie, genoux au-dessus des chevilles.","Tiens la position, mains sur les cuisses ou bras croisés."],"breathing":"Respire calmement, sans bloquer.","mistakes":["Genoux qui dépassent largement les orteils.","Appuyer les mains sur les cuisses pour tricher."]}'::jsonb),
('fente_avant', 'Fente avant', 'force', null, null, array['Debout, fais un grand pas en avant.', 'Descends le genou arrière vers le sol, buste droit.', 'Pousse sur le pied avant pour revenir. Alterne les jambes.']::text[], 'Le genou avant reste au-dessus de la cheville. Tiens-toi à une chaise si l''équilibre est difficile.', '[{"label":"Fente sur place, petite amplitude","reps":8},{"label":"Fente sur place","reps":10},{"label":"Pas en avant puis retour","reps":10},{"label":"Haltères en main","reps":10}]'::jsonb, array['cuisses', 'fessiers']::text[], array['aucun']::text[], 3, 'fente', 'fente', 4, false, 'free-exercise-db (domaine public), fiche Bodyweight Walking Lunge (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Bodyweight_Walking_Lunge.json) ; NHS, Strength exercises (https://www.nhs.uk/live-well/exercise/strength-and-flexibility-exercises/strength-exercises/)', array['quadriceps', 'grand_fessier']::text[], array['ischio_jambiers', 'adducteurs']::text[], array['jambes', 'fessiers']::text[], array['renforcer', 'tonifier']::text[], 'renforcement', false, 'reps', 10, 3.8, '02022', '{"steps":["Debout, fais un grand pas en avant.","Descends le genou arrière vers le sol, buste droit.","Pousse sur le pied avant pour revenir. Alterne les jambes."],"breathing":"Inspire en descendant, expire en remontant.","mistakes":["Pas trop court : le genou avant part loin devant.","Buste penché vers l''avant."]}'::jsonb),
('fente_arriere', 'Fente arrière', 'force', null, null, array['Debout, recule un pied d''un grand pas.', 'Fléchis les deux genoux, le genou arrière descend vers le sol.', 'Reviens en poussant sur le talon avant. Alterne.']::text[], 'Plus facile pour les genoux que la fente avant : bon choix pour commencer.', '[{"label":"Main sur une chaise, petite amplitude","reps":8},{"label":"Sans appui","reps":10},{"label":"Descente lente en 3 s","reps":10},{"label":"Haltères en main","reps":10}]'::jsonb, array['fessiers', 'cuisses']::text[], array['aucun']::text[], 2, 'fente', 'fente', 4, false, 'free-exercise-db (domaine public), fiche Dumbbell Rear Lunge (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Dumbbell_Rear_Lunge.json)', array['grand_fessier', 'quadriceps']::text[], array['ischio_jambiers']::text[], array['jambes', 'fessiers']::text[], array['renforcer', 'tonifier']::text[], 'renforcement', false, 'reps', 10, 3.8, '02022', '{"steps":["Debout, recule un pied d''un grand pas.","Fléchis les deux genoux, le genou arrière descend vers le sol.","Reviens en poussant sur le talon avant. Alterne."],"breathing":"Inspire en reculant, expire en revenant.","mistakes":["Pieds sur la même ligne : on perd l''équilibre.","Genou arrière qui tape le sol."]}'::jsonb),
('fente_laterale', 'Fente latérale', 'force', null, null, array['Debout, pieds joints. Fais un grand pas sur le côté.', 'Plie le genou de ce côté et pousse les fesses en arrière, l''autre jambe reste tendue.', 'Reviens au centre en poussant sur le pied. Alterne.']::text[], 'Les deux pieds restent à plat et pointent vers l''avant.', '[{"label":"Petite amplitude","reps":8},{"label":"Amplitude complète","reps":10},{"label":"Pause de 2 s en bas","reps":10}]'::jsonb, array['cuisses', 'fessiers']::text[], array['aucun']::text[], 2, 'fente-laterale', 'fente', 3, false, 'free-exercise-db (domaine public), fiche Barbell Side Split Squat (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Barbell_Side_Split_Squat.json)', array['adducteurs', 'quadriceps', 'grand_fessier']::text[], array['moyen_fessier']::text[], array['jambes', 'fessiers']::text[], array['renforcer', 'tonifier', 'mobilite']::text[], 'renforcement', false, 'reps', 10, 3.8, '02022', '{"steps":["Debout, pieds joints. Fais un grand pas sur le côté.","Plie le genou de ce côté et pousse les fesses en arrière, l''autre jambe reste tendue.","Reviens au centre en poussant sur le pied. Alterne."],"breathing":"Inspire en descendant, expire en revenant.","mistakes":["Genou plié qui rentre vers l''intérieur.","Dos arrondi."]}'::jsonb),
('fente_bulgare', 'Fente bulgare (pied arrière sur une chaise)', 'force', null, null, array['Dos à une chaise stable, pose le dessus du pied arrière sur l''assise.', 'Descends à la verticale sur la jambe avant, buste légèrement penché.', 'Remonte en poussant dans le talon avant. Fais toutes les répétitions, puis change.']::text[], 'Chaise calée contre un mur pour qu''elle ne glisse pas.', '[{"label":"Petite amplitude, main au mur","reps":6},{"label":"Amplitude complète","reps":8},{"label":"Descente lente en 3 s","reps":8},{"label":"Haltères en main","reps":8}]'::jsonb, array['cuisses', 'fessiers']::text[], array['chaise']::text[], 4, 'fente', 'fente', 3, false, 'free-exercise-db (domaine public), fiche Split Squats (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Split_Squats.json)', array['quadriceps', 'grand_fessier']::text[], array['ischio_jambiers', 'adducteurs', 'moyen_fessier']::text[], array['jambes', 'fessiers']::text[], array['renforcer', 'tonifier']::text[], 'renforcement', false, 'reps', 8, 3.8, '02022', '{"steps":["Dos à une chaise stable, pose le dessus du pied arrière sur l''assise.","Descends à la verticale sur la jambe avant, buste légèrement penché.","Remonte en poussant dans le talon avant. Fais toutes les répétitions, puis change."],"breathing":"Inspire en descendant, expire en remontant.","mistakes":["Pied avant trop près de la chaise.","Pousser avec la jambe arrière."]}'::jsonb),
('pont_unilateral', 'Pont fessier sur une jambe', 'force', null, null, array['Allonge-toi sur le dos, un pied à plat, l''autre jambe en l''air.', 'Pousse dans le talon au sol et monte le bassin bien droit.', 'Redescends lentement. Change de jambe à mi-série.']::text[], 'Le bassin reste horizontal : s''il penche, reviens au pont sur deux jambes.', '[{"label":"Jambe libre pliée","reps":8},{"label":"Jambe libre tendue","reps":10},{"label":"Pause de 2 s en haut","reps":10}]'::jsonb, array['fessiers']::text[], array['aucun']::text[], 3, 'pont', 'pont', 3, false, 'free-exercise-db (domaine public), fiche Single Leg Glute Bridge (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Single_Leg_Glute_Bridge.json)', array['grand_fessier']::text[], array['ischio_jambiers', 'moyen_fessier', 'lombaires']::text[], array['fessiers', 'jambes']::text[], array['renforcer', 'tonifier']::text[], 'renforcement', false, 'reps', 10, 3.0, '02056', '{"steps":["Allonge-toi sur le dos, un pied à plat, l''autre jambe en l''air.","Pousse dans le talon au sol et monte le bassin bien droit.","Redescends lentement. Change de jambe à mi-série."],"breathing":"Expire en montant, inspire en redescendant.","mistakes":["Bassin qui penche du côté de la jambe levée.","Cambrer le dos en haut."]}'::jsonb),
('hip_thrust', 'Hip thrust, épaules sur le canapé', 'force', null, null, array['Assieds-toi au sol, le haut du dos appuyé contre le bord d''un canapé ou d''un lit.', 'Pieds à plat, pousse dans les talons pour monter le bassin jusqu''à l''horizontale.', 'Menton rentré, serre les fessiers en haut, puis redescends.']::text[], 'Le support doit être stable et bas (hauteur de genou environ).', '[{"label":"Poids du corps","reps":10},{"label":"Poids du corps, pause de 2 s","reps":12},{"label":"Haltère posé sur le bassin","reps":12},{"label":"Une jambe","reps":8}]'::jsonb, array['fessiers']::text[], array['aucun']::text[], 3, 'pont', 'pont', 4, false, 'free-exercise-db (domaine public), fiche Barbell Hip Thrust (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Barbell_Hip_Thrust.json)', array['grand_fessier']::text[], array['ischio_jambiers', 'quadriceps']::text[], array['fessiers']::text[], array['renforcer', 'tonifier']::text[], 'renforcement', false, 'reps', 12, 3.0, '02056', '{"steps":["Assieds-toi au sol, le haut du dos appuyé contre le bord d''un canapé ou d''un lit.","Pieds à plat, pousse dans les talons pour monter le bassin jusqu''à l''horizontale.","Menton rentré, serre les fessiers en haut, puis redescends."],"breathing":"Expire en montant, inspire en redescendant.","mistakes":["Cambrer le bas du dos en haut.","Regarder le plafond : la nuque se casse."]}'::jsonb),
('ruade', 'Ruade (donkey kick)', 'force', null, null, array['À quatre pattes, mains sous les épaules, genoux sous les hanches.', 'Genou plié à angle droit, pousse la plante du pied vers le plafond.', 'Reviens sans poser le genou. Change de côté à mi-série.']::text[], 'Monte seulement tant que le dos reste plat.', '[{"label":"Petite amplitude","reps":10},{"label":"Amplitude complète","reps":12},{"label":"Élastique autour des cuisses","reps":12},{"label":"Pause de 2 s en haut","reps":15}]'::jsonb, array['fessiers']::text[], array['aucun']::text[], 2, 'extension-hanche', 'extension-hanche', 4, false, 'free-exercise-db (domaine public), fiche Glute Kickback (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Glute_Kickback.json)', array['grand_fessier']::text[], array['ischio_jambiers', 'transverse']::text[], array['fessiers']::text[], array['tonifier', 'renforcer']::text[], 'renforcement', false, 'reps', 12, 3.0, '02056', '{"steps":["À quatre pattes, mains sous les épaules, genoux sous les hanches.","Genou plié à angle droit, pousse la plante du pied vers le plafond.","Reviens sans poser le genou. Change de côté à mi-série."],"breathing":"Expire en poussant, inspire en revenant.","mistakes":["Creuser le dos pour monter plus haut.","Ouvrir la hanche sur le côté."]}'::jsonb),
('bouche_incendie', 'Bouche d''incendie (fire hydrant)', 'force', null, null, array['À quatre pattes, dos plat.', 'Garde le genou plié et ouvre la cuisse sur le côté, comme une porte.', 'Redescends lentement. Change de côté à mi-série.']::text[], 'Le buste ne bascule pas : seule la jambe bouge.', '[{"label":"Petite amplitude","reps":10},{"label":"Amplitude complète","reps":12},{"label":"Élastique autour des cuisses","reps":12}]'::jsonb, array['hanches']::text[], array['aucun']::text[], 2, 'abduction-hanche', 'abduction', 3, false, 'free-exercise-db (domaine public), fiche Thigh Abductor (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Thigh_Abductor.json)', array['moyen_fessier']::text[], array['grand_fessier', 'transverse']::text[], array['fessiers']::text[], array['tonifier', 'renforcer']::text[], 'renforcement', false, 'reps', 12, 3.0, '02056', '{"steps":["À quatre pattes, dos plat.","Garde le genou plié et ouvre la cuisse sur le côté, comme une porte.","Redescends lentement. Change de côté à mi-série."],"breathing":"Expire en ouvrant, inspire en refermant.","mistakes":["Pencher tout le corps du côté opposé.","Aller trop vite."]}'::jsonb),
('charniere_hanche', 'Charnière de hanche (good morning) au poids du corps', 'force', null, null, array['Debout, pieds largeur de hanches, genoux légèrement fléchis.', 'Pousse les fesses loin en arrière, le buste descend dos plat.', 'Arrête quand tu sens l''arrière des cuisses tirer, puis remonte en serrant les fessiers.']::text[], 'Le dos reste plat du début à la fin : c''est la hanche qui plie.', '[{"label":"Mains sur les hanches","reps":10},{"label":"Mains derrière la tête","reps":12},{"label":"Élastique sous les pieds, sur la nuque","reps":12}]'::jsonb, array['ischios', 'fessiers']::text[], array['aucun']::text[], 2, 'charniere', 'charniere', 3, false, 'free-exercise-db (domaine public), fiche Band Good Morning (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Band_Good_Morning.json)', array['ischio_jambiers', 'grand_fessier']::text[], array['lombaires']::text[], array['jambes', 'dos', 'fessiers']::text[], array['renforcer', 'mobilite']::text[], 'renforcement', false, 'reps', 12, 3.0, '02056', '{"steps":["Debout, pieds largeur de hanches, genoux légèrement fléchis.","Pousse les fesses loin en arrière, le buste descend dos plat.","Arrête quand tu sens l''arrière des cuisses tirer, puis remonte en serrant les fessiers."],"breathing":"Inspire en descendant, expire en remontant.","mistakes":["Arrondir le dos.","Plier les genoux comme pour un squat."]}'::jsonb),
('souleve_roumain', 'Soulevé de terre roumain aux haltères', 'force', null, null, array['Debout, un haltère dans chaque main devant les cuisses.', 'Pousse les fesses en arrière et fais glisser les haltères le long des jambes.', 'Descends jusqu''au milieu des tibias, dos plat, puis remonte en serrant les fessiers.']::text[], 'Garde les haltères au contact des jambes : plus ils s''éloignent, plus le dos travaille.', '[{"label":"Haltères légers","reps":10},{"label":"Haltères moyens","reps":10},{"label":"Descente lente en 3 s","reps":10},{"label":"Sur une jambe, main à la chaise","reps":8}]'::jsonb, array['ischios', 'fessiers']::text[], array['halteres']::text[], 3, 'charniere', 'charniere', 4, false, 'free-exercise-db (domaine public), fiche Romanian Deadlift (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Romanian_Deadlift.json) ; free-exercise-db (domaine public), fiche Stiff-Legged Dumbbell Deadlift (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Stiff-Legged_Dumbbell_Deadlift.json)', array['ischio_jambiers', 'grand_fessier']::text[], array['lombaires', 'trapezes', 'avant_bras']::text[], array['jambes', 'fessiers', 'dos']::text[], array['renforcer']::text[], 'renforcement', false, 'reps', 10, 5.0, '02052', '{"steps":["Debout, un haltère dans chaque main devant les cuisses.","Pousse les fesses en arrière et fais glisser les haltères le long des jambes.","Descends jusqu''au milieu des tibias, dos plat, puis remonte en serrant les fessiers."],"breathing":"Inspire en descendant, expire en remontant.","mistakes":["Dos arrondi.","Haltères qui partent vers l''avant.","Descendre trop bas sans souplesse."]}'::jsonb),
('squat_goblet', 'Squat goblet à l''haltère', 'force', null, null, array['Tiens un haltère vertical contre la poitrine, coudes vers le bas.', 'Descends en squat, les coudes passent entre les genoux.', 'Remonte en poussant dans les talons, buste droit.']::text[], 'L''haltère reste collé à la poitrine pendant tout le mouvement.', '[{"label":"Haltère léger","reps":10},{"label":"Haltère moyen","reps":10},{"label":"Pause de 2 s en bas","reps":10},{"label":"Haltère lourd","reps":8}]'::jsonb, array['cuisses', 'fessiers']::text[], array['halteres']::text[], 3, 'squat', 'squat', 4, false, 'free-exercise-db (domaine public), fiche Goblet Squat (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Goblet_Squat.json)', array['quadriceps', 'grand_fessier']::text[], array['adducteurs', 'transverse', 'lombaires']::text[], array['jambes', 'fessiers']::text[], array['renforcer']::text[], 'renforcement', false, 'reps', 10, 5.0, '02052', '{"steps":["Tiens un haltère vertical contre la poitrine, coudes vers le bas.","Descends en squat, les coudes passent entre les genoux.","Remonte en poussant dans les talons, buste droit."],"breathing":"Inspire en descendant, expire en remontant.","mistakes":["Laisser l''haltère tirer le buste vers l''avant.","Talons qui décollent."]}'::jsonb),
('releve_mollets_unipodal', 'Montée sur pointe, une jambe', 'force', null, null, array['Debout sur une jambe, une main au mur pour l''équilibre.', 'Monte le plus haut possible sur la pointe du pied.', 'Redescends lentement. Change de jambe.']::text[], 'Le genou reste juste déverrouillé.', '[{"label":"Main au mur, amplitude confortable","reps":10},{"label":"Descente lente en 3 s","reps":12},{"label":"Talon dans le vide, sur une marche","reps":12}]'::jsonb, array['mollets']::text[], array['mur']::text[], 2, 'mollets', 'mollets', 3, false, 'free-exercise-db (domaine public), fiche Standing Dumbbell Calf Raise (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Standing_Dumbbell_Calf_Raise.json)', array['mollets']::text[], '{}'::text[], array['jambes']::text[], array['renforcer', 'tonifier']::text[], 'renforcement', false, 'reps', 12, 3.0, '02056', '{"steps":["Debout sur une jambe, une main au mur pour l''équilibre.","Monte le plus haut possible sur la pointe du pied.","Redescends lentement. Change de jambe."],"breathing":"Expire en montant, inspire en descendant.","mistakes":["Rebondir en bas.","Cheville qui part vers l''extérieur."]}'::jsonb),
('adducteurs_couche', 'Levée de jambe intérieure (adducteurs)', 'force', null, null, array['Allonge-toi sur le côté, la jambe du dessus pliée et posée devant toi.', 'Monte la jambe du dessous tendue, de quelques centimètres.', 'Redescends sans poser complètement. Change de côté.']::text[], 'Petit mouvement, sans élan.', '[{"label":"Petite amplitude","reps":12},{"label":"Pause de 2 s en haut","reps":15},{"label":"Élastique aux chevilles","reps":15}]'::jsonb, array['cuisses']::text[], array['aucun']::text[], 1, 'adduction-hanche', 'adduction', 3, false, 'free-exercise-db (domaine public), fiche Thigh Adductor (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Thigh_Adductor.json) ; free-exercise-db (domaine public), fiche Band Hip Adductions (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Band_Hip_Adductions.json)', array['adducteurs']::text[], array['transverse']::text[], array['jambes']::text[], array['tonifier', 'renforcer']::text[], 'renforcement', false, 'reps', 15, 3.0, '02056', '{"steps":["Allonge-toi sur le côté, la jambe du dessus pliée et posée devant toi.","Monte la jambe du dessous tendue, de quelques centimètres.","Redescends sans poser complètement. Change de côté."],"breathing":"Expire en montant, inspire en descendant.","mistakes":["Rouler vers l''arrière.","Pointe du pied tournée vers le plafond."]}'::jsonb),
('pont_marche', 'Pont fessier en marche', 'gainage', null, null, array['En position de pont, bassin levé.', 'Soulève un pied, puis l''autre, comme si tu marchais sur place.', 'Le bassin reste haut et immobile.']::text[], 'Si le bassin tourne ou descend, reviens au pont classique.', '[{"label":"Pied soulevé de 5 cm","reps":8},{"label":"Genou ramené vers la poitrine","reps":10},{"label":"Pause de 2 s par pas","reps":10}]'::jsonb, array['fessiers', 'abdos']::text[], array['aucun']::text[], 3, 'pont', 'pont', 3, false, 'free-exercise-db (domaine public), fiche Butt Lift Bridge (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Butt_Lift_Bridge.json)', array['grand_fessier', 'transverse']::text[], array['ischio_jambiers', 'obliques']::text[], array['fessiers', 'abdos']::text[], array['renforcer']::text[], 'gainage', false, 'reps', 10, 2.8, '02024', '{"steps":["En position de pont, bassin levé.","Soulève un pied, puis l''autre, comme si tu marchais sur place.","Le bassin reste haut et immobile."],"breathing":"Respire à chaque pas, sans bloquer.","mistakes":["Bassin qui s''affaisse.","Hanches qui basculent d''un côté à l''autre."]}'::jsonb),
('squat_unipodal_chaise', 'Squat sur une jambe vers une chaise', 'force', null, null, array['Debout devant une chaise, sur une jambe, l''autre tendue devant toi.', 'Descends lentement jusqu''à t''asseoir, bras tendus devant pour l''équilibre.', 'Relève-toi sur la même jambe. Change de jambe.']::text[], 'Étape vers le pistol squat. Pose les deux pieds si le genou rentre vers l''intérieur.', '[{"label":"Chaise haute, une main au mur","reps":5},{"label":"Chaise haute","reps":6},{"label":"Chaise basse","reps":6},{"label":"Descente lente en 4 s","reps":6}]'::jsonb, array['cuisses', 'fessiers']::text[], array['chaise']::text[], 4, 'squat-unipodal', 'squat', 3, false, 'free-exercise-db (domaine public), fiche Single-Leg High Box Squat (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Single-Leg_High_Box_Squat.json) ; free-exercise-db (domaine public), fiche Kettlebell Pistol Squat (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Kettlebell_Pistol_Squat.json)', array['quadriceps', 'grand_fessier']::text[], array['moyen_fessier', 'ischio_jambiers', 'transverse']::text[], array['jambes', 'fessiers']::text[], array['renforcer']::text[], 'calisthenie', false, 'reps', 6, 3.8, '02022', '{"steps":["Debout devant une chaise, sur une jambe, l''autre tendue devant toi.","Descends lentement jusqu''à t''asseoir, bras tendus devant pour l''équilibre.","Relève-toi sur la même jambe. Change de jambe."],"breathing":"Inspire en descendant, expire en te relevant.","mistakes":["Se laisser tomber sur la chaise.","Genou qui part vers l''intérieur."]}'::jsonb),
('pompe_mur', 'Pompe au mur', 'force', null, null, array['Face au mur, mains à plat à hauteur d''épaules, un peu plus écartées.', 'Plie les coudes pour approcher la poitrine du mur, corps gainé.', 'Repousse le mur pour revenir.']::text[], 'Plus les pieds sont loin du mur, plus c''est difficile.', '[{"label":"Pieds proches du mur","reps":10},{"label":"Pieds plus éloignés","reps":12},{"label":"Descente lente en 3 s","reps":12}]'::jsonb, array['pectoraux', 'bras']::text[], array['mur']::text[], 1, 'pompe', 'poussee-horizontale', 4, false, 'NHS, Strength exercises (https://www.nhs.uk/live-well/exercise/strength-and-flexibility-exercises/strength-exercises/) ; free-exercise-db (domaine public), fiche Incline Push-Up (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Incline_Push-Up.json)', array['pectoraux', 'triceps']::text[], array['deltoides_anterieurs', 'transverse']::text[], array['bras', 'epaules']::text[], array['renforcer', 'tonifier']::text[], 'renforcement', false, 'reps', 12, 3.0, '02056', '{"steps":["Face au mur, mains à plat à hauteur d''épaules, un peu plus écartées.","Plie les coudes pour approcher la poitrine du mur, corps gainé.","Repousse le mur pour revenir."],"breathing":"Inspire en descendant, expire en poussant.","mistakes":["Coudes ouverts à 90° du corps.","Fesses en arrière."]}'::jsonb),
('pompe_inclinee', 'Pompe inclinée (mains sur une chaise)', 'force', null, null, array['Mains sur l''assise d''une chaise calée contre le mur, corps en planche.', 'Descends la poitrine vers la chaise, coudes à 45° du corps.', 'Pousse pour revenir, corps bien aligné.']::text[], 'La chaise ne doit pas pouvoir glisser.', '[{"label":"Mains sur un plan haut (table)","reps":8},{"label":"Mains sur l''assise","reps":10},{"label":"Descente lente en 3 s","reps":10}]'::jsonb, array['pectoraux', 'bras']::text[], array['chaise']::text[], 2, 'pompe', 'poussee-horizontale', 4, false, 'free-exercise-db (domaine public), fiche Incline Push-Up (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Incline_Push-Up.json)', array['pectoraux', 'triceps']::text[], array['deltoides_anterieurs', 'transverse']::text[], array['bras', 'epaules']::text[], array['renforcer', 'tonifier']::text[], 'renforcement', false, 'reps', 10, 3.8, '02022', '{"steps":["Mains sur l''assise d''une chaise calée contre le mur, corps en planche.","Descends la poitrine vers la chaise, coudes à 45° du corps.","Pousse pour revenir, corps bien aligné."],"breathing":"Inspire en descendant, expire en poussant.","mistakes":["Bassin qui s''affaisse.","Tête qui avance vers la chaise."]}'::jsonb),
('pompe_genoux', 'Pompe sur les genoux', 'force', null, null, array['À genoux, mains au sol sous les épaules, un peu plus écartées.', 'Aligne genoux, hanches et épaules, puis descends la poitrine vers le sol.', 'Repousse le sol pour remonter.']::text[], 'Un coussin sous les genoux rend l''exercice plus confortable.', '[{"label":"Demi-amplitude","reps":8},{"label":"Amplitude complète","reps":10},{"label":"Descente lente en 3 s","reps":10}]'::jsonb, array['pectoraux', 'bras']::text[], array['aucun']::text[], 2, 'pompe', 'poussee-horizontale', 4, false, 'free-exercise-db (domaine public), fiche Pushups (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Pushups.json)', array['pectoraux', 'triceps']::text[], array['deltoides_anterieurs', 'transverse']::text[], array['bras', 'epaules']::text[], array['renforcer', 'tonifier']::text[], 'renforcement', false, 'reps', 10, 3.8, '02022', '{"steps":["À genoux, mains au sol sous les épaules, un peu plus écartées.","Aligne genoux, hanches et épaules, puis descends la poitrine vers le sol.","Repousse le sol pour remonter."],"breathing":"Inspire en descendant, expire en poussant.","mistakes":["Fesses en l''air.","Coudes ouverts sur les côtés."]}'::jsonb),
('pompe', 'Pompe', 'force', null, null, array['Mains au sol un peu plus larges que les épaules, corps droit de la tête aux talons.', 'Descends la poitrine jusqu''à quelques centimètres du sol, coudes à 45°.', 'Pousse le sol pour revenir, sans casser l''alignement.']::text[], 'Si le bassin s''affaisse, passe à la pompe sur les genoux.', '[{"label":"5 pompes propres","reps":5},{"label":"8 pompes","reps":8},{"label":"10 pompes","reps":10},{"label":"Descente lente en 3 s","reps":10}]'::jsonb, array['pectoraux', 'bras']::text[], array['aucun']::text[], 3, 'pompe', 'poussee-horizontale', 4, false, 'free-exercise-db (domaine public), fiche Pushups (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Pushups.json)', array['pectoraux', 'triceps']::text[], array['deltoides_anterieurs', 'grand_droit', 'transverse']::text[], array['bras', 'epaules', 'abdos']::text[], array['renforcer']::text[], 'calisthenie', false, 'reps', 10, 3.8, '02022', '{"steps":["Mains au sol un peu plus larges que les épaules, corps droit de la tête aux talons.","Descends la poitrine jusqu''à quelques centimètres du sol, coudes à 45°.","Pousse le sol pour revenir, sans casser l''alignement."],"breathing":"Inspire en descendant, expire en poussant.","mistakes":["Bassin qui s''affaisse.","Tête qui plonge vers le sol.","Coudes à 90° du corps."]}'::jsonb),
('pompe_serree', 'Pompe mains serrées (triceps)', 'force', null, null, array['En position de pompe, mains sous les épaules, rapprochées.', 'Descends en gardant les coudes collés au corps.', 'Pousse pour remonter.']::text[], 'Plus exigeant pour les poignets : écarte un peu les mains si besoin.', '[{"label":"Sur les genoux","reps":8},{"label":"Sur les pieds","reps":6},{"label":"Sur les pieds","reps":8}]'::jsonb, array['bras']::text[], array['aucun']::text[], 4, 'pompe', 'poussee-horizontale', 3, false, 'free-exercise-db (domaine public), fiche Push-Ups - Close Triceps Position (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Push-Ups_-_Close_Triceps_Position.json)', array['triceps']::text[], array['pectoraux', 'deltoides_anterieurs']::text[], array['bras']::text[], array['renforcer']::text[], 'calisthenie', false, 'reps', 8, 3.8, '02022', '{"steps":["En position de pompe, mains sous les épaules, rapprochées.","Descends en gardant les coudes collés au corps.","Pousse pour remonter."],"breathing":"Inspire en descendant, expire en poussant.","mistakes":["Coudes qui s''ouvrent.","Bassin qui s''affaisse."]}'::jsonb),
('pompe_pike', 'Pompe en V (pike push-up)', 'force', null, null, array['Mains au sol, fesses hautes : ton corps forme un V à l''envers.', 'Plie les coudes pour descendre le sommet du crâne vers le sol, entre les mains.', 'Repousse pour revenir.']::text[], 'Descends lentement : le poids est sur les épaules et la tête approche du sol.', '[{"label":"Petite amplitude","reps":6},{"label":"Front vers le sol","reps":8},{"label":"Pieds surélevés sur une chaise","reps":6}]'::jsonb, array['epaules', 'bras']::text[], array['aucun']::text[], 4, 'poussee-verticale', 'poussee-verticale', 3, false, 'free-exercise-db (domaine public), fiche Handstand Push-Ups (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Handstand_Push-Ups.json)', array['deltoides_anterieurs', 'triceps']::text[], array['trapezes', 'pectoraux']::text[], array['epaules', 'bras']::text[], array['renforcer']::text[], 'calisthenie', false, 'reps', 8, 3.8, '02022', '{"steps":["Mains au sol, fesses hautes : ton corps forme un V à l''envers.","Plie les coudes pour descendre le sommet du crâne vers le sol, entre les mains.","Repousse pour revenir."],"breathing":"Inspire en descendant, expire en poussant.","mistakes":["Coudes qui partent sur les côtés.","Fesses qui descendent : ça devient une pompe classique."]}'::jsonb),
('dips_chaise', 'Dips sur chaise', 'force', null, null, array['Dos à une chaise stable, mains sur le bord de l''assise, doigts vers l''avant.', 'Plie les coudes vers l''arrière pour descendre les fesses.', 'Remonte en tendant les bras.']::text[], 'Descends jusqu''à ce que les bras soient à angle droit, pas plus bas.', '[{"label":"Genoux pliés, petite amplitude","reps":8},{"label":"Genoux pliés","reps":10},{"label":"Jambes tendues","reps":10}]'::jsonb, array['bras']::text[], array['chaise']::text[], 3, 'dips', 'poussee-verticale', 3, false, 'free-exercise-db (domaine public), fiche Bench Dips (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Bench_Dips.json)', array['triceps']::text[], array['pectoraux', 'deltoides_anterieurs']::text[], array['bras']::text[], array['renforcer', 'tonifier']::text[], 'calisthenie', false, 'reps', 10, 3.8, '02022', '{"steps":["Dos à une chaise stable, mains sur le bord de l''assise, doigts vers l''avant.","Plie les coudes vers l''arrière pour descendre les fesses.","Remonte en tendant les bras."],"breathing":"Inspire en descendant, expire en poussant.","mistakes":["Épaules qui remontent vers les oreilles.","Coudes qui s''écartent.","S''éloigner de la chaise."]}'::jsonb),
('rowing_haltere', 'Rowing à un bras à l''haltère', 'force', null, null, array['Une main et un genou sur une chaise, l''autre pied au sol, dos plat.', 'Tire l''haltère vers la hanche, coude près du corps.', 'Redescends lentement. Change de côté.']::text[], 'Le dos reste plat et immobile, sans rotation.', '[{"label":"Haltère léger","reps":12},{"label":"Haltère moyen","reps":10},{"label":"Pause de 2 s coude en arrière","reps":10}]'::jsonb, array['dos']::text[], array['halteres']::text[], 2, 'tirage', 'tirage', 4, false, 'free-exercise-db (domaine public), fiche One-Arm Dumbbell Row (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/One-Arm_Dumbbell_Row.json)', array['grand_dorsal', 'rhomboides']::text[], array['biceps', 'deltoides_posterieurs']::text[], array['dos', 'bras']::text[], array['renforcer', 'tonifier']::text[], 'renforcement', false, 'reps', 12, 3.5, '02054', '{"steps":["Une main et un genou sur une chaise, l''autre pied au sol, dos plat.","Tire l''haltère vers la hanche, coude près du corps.","Redescends lentement. Change de côté."],"breathing":"Expire en tirant, inspire en descendant.","mistakes":["Tourner le buste pour monter l''haltère.","Tirer vers l''épaule au lieu de la hanche."]}'::jsonb),
('developpe_epaules', 'Développé épaules aux haltères', 'force', null, null, array['Haltères à hauteur d''épaules, paumes vers l''avant, ventre gainé.', 'Pousse vers le haut jusqu''à tendre les bras.', 'Redescends lentement à hauteur d''oreilles.']::text[], 'Ne cambre pas le bas du dos pour pousser : allège la charge.', '[{"label":"Assis, haltères légers","reps":10},{"label":"Debout","reps":10},{"label":"Haltères moyens","reps":10}]'::jsonb, array['epaules']::text[], array['halteres']::text[], 3, 'poussee-verticale', 'poussee-verticale', 4, false, 'free-exercise-db (domaine public), fiche Dumbbell Shoulder Press (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Dumbbell_Shoulder_Press.json)', array['deltoides_anterieurs', 'deltoides_lateraux']::text[], array['triceps', 'trapezes']::text[], array['epaules', 'bras']::text[], array['renforcer', 'tonifier']::text[], 'renforcement', false, 'reps', 10, 3.5, '02054', '{"steps":["Haltères à hauteur d''épaules, paumes vers l''avant, ventre gainé.","Pousse vers le haut jusqu''à tendre les bras.","Redescends lentement à hauteur d''oreilles."],"breathing":"Expire en poussant, inspire en descendant.","mistakes":["Cambrer le dos.","Descendre trop vite."]}'::jsonb),
('curl_marteau', 'Curl marteau aux haltères', 'force', null, null, array['Debout, un haltère dans chaque main, paumes face à face.', 'Plie les coudes pour monter les haltères vers les épaules.', 'Redescends lentement, coudes collés au corps.']::text[], 'Pas d''élan avec le dos.', '[{"label":"Haltères légers","reps":12},{"label":"Haltères moyens","reps":10},{"label":"Descente lente en 3 s","reps":10}]'::jsonb, array['bras']::text[], array['halteres']::text[], 2, 'curl', 'flexion-coude', 3, false, 'free-exercise-db (domaine public), fiche Hammer Curls (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Hammer_Curls.json)', array['biceps', 'avant_bras']::text[], '{}'::text[], array['bras']::text[], array['renforcer', 'tonifier']::text[], 'renforcement', false, 'reps', 12, 3.5, '02054', '{"steps":["Debout, un haltère dans chaque main, paumes face à face.","Plie les coudes pour monter les haltères vers les épaules.","Redescends lentement, coudes collés au corps."],"breathing":"Expire en montant, inspire en descendant.","mistakes":["Balancer le buste.","Coudes qui avancent."]}'::jsonb),
('extension_triceps_haltere', 'Extension des triceps au-dessus de la tête', 'force', null, null, array['Tiens un haltère à deux mains au-dessus de la tête.', 'Plie les coudes pour descendre l''haltère derrière la nuque.', 'Tends les bras pour remonter, coudes pointés vers l''avant.']::text[], 'Garde les côtes basses : pas de cambrure.', '[{"label":"Assis, haltère léger","reps":12},{"label":"Debout","reps":12},{"label":"Haltère moyen","reps":10}]'::jsonb, array['bras']::text[], array['halteres']::text[], 2, 'extension-coude', 'extension-coude', 3, false, 'free-exercise-db (domaine public), fiche Standing Dumbbell Triceps Extension (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Standing_Dumbbell_Triceps_Extension.json)', array['triceps']::text[], '{}'::text[], array['bras']::text[], array['renforcer', 'tonifier']::text[], 'renforcement', false, 'reps', 12, 3.5, '02054', '{"steps":["Tiens un haltère à deux mains au-dessus de la tête.","Plie les coudes pour descendre l''haltère derrière la nuque.","Tends les bras pour remonter, coudes pointés vers l''avant."],"breathing":"Inspire en descendant, expire en tendant.","mistakes":["Coudes qui s''écartent.","Cambrer le dos."]}'::jsonb),
('oiseau_haltere', 'Oiseau aux haltères (arrière d''épaule)', 'force', null, null, array['Penché en avant, dos plat, genoux fléchis, haltères sous les épaules.', 'Ouvre les bras sur les côtés, coudes légèrement fléchis.', 'Serre les omoplates en haut, puis redescends lentement.']::text[], 'Des charges très légères suffisent.', '[{"label":"Haltères très légers","reps":12},{"label":"Pause de 2 s bras ouverts","reps":12},{"label":"Haltères légers","reps":12}]'::jsonb, array['epaules', 'dos']::text[], array['halteres']::text[], 2, 'retraction-scapulaire', 'tirage', 3, false, 'free-exercise-db (domaine public), fiche Bent Over Low-Pulley Side Lateral (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Bent_Over_Low-Pulley_Side_Lateral.json)', array['deltoides_posterieurs', 'rhomboides']::text[], array['trapezes']::text[], array['epaules', 'dos']::text[], array['renforcer', 'tonifier']::text[], 'renforcement', false, 'reps', 12, 3.5, '02054', '{"steps":["Penché en avant, dos plat, genoux fléchis, haltères sous les épaules.","Ouvre les bras sur les côtés, coudes légèrement fléchis.","Serre les omoplates en haut, puis redescends lentement."],"breathing":"Expire en ouvrant, inspire en redescendant.","mistakes":["Se redresser pour monter les bras.","Hausser les épaules."]}'::jsonb),
('developpe_sol', 'Développé au sol aux haltères', 'force', null, null, array['Allongé sur le dos, genoux pliés, un haltère dans chaque main.', 'Pousse les haltères vers le plafond jusqu''à tendre les bras.', 'Redescends jusqu''à poser doucement les coudes au sol.']::text[], 'Coudes à environ 45° du corps.', '[{"label":"Haltères légers","reps":12},{"label":"Haltères moyens","reps":10},{"label":"Pause de 1 s coudes au sol","reps":10}]'::jsonb, array['pectoraux', 'bras']::text[], array['halteres']::text[], 2, 'poussee-horizontale', 'poussee-horizontale', 4, false, 'free-exercise-db (domaine public), fiche Dumbbell Floor Press (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Dumbbell_Floor_Press.json)', array['pectoraux', 'triceps']::text[], array['deltoides_anterieurs']::text[], array['bras', 'epaules']::text[], array['renforcer']::text[], 'renforcement', false, 'reps', 12, 3.5, '02054', '{"steps":["Allongé sur le dos, genoux pliés, un haltère dans chaque main.","Pousse les haltères vers le plafond jusqu''à tendre les bras.","Redescends jusqu''à poser doucement les coudes au sol."],"breathing":"Expire en poussant, inspire en descendant.","mistakes":["Laisser tomber les coudes au sol.","Coudes à angle droit du corps."]}'::jsonb),
('tirage_vertical_elastique', 'Tirage vertical à l''élastique', 'force', null, null, array['Élastique fixé en haut d''une porte fermée, à genoux face à la porte.', 'Bras tendus vers le haut, tire les coudes vers les côtes.', 'Remonte lentement en gardant les épaules basses.']::text[], 'Vérifie que l''élastique est bien coincé dans une porte fermée à clé ou ouvrant vers l''extérieur.', '[{"label":"Élastique léger","reps":12},{"label":"Élastique moyen","reps":12},{"label":"Pause de 2 s en bas","reps":10}]'::jsonb, array['dos']::text[], array['elastique']::text[], 2, 'tirage-vertical', 'tirage', 4, false, 'free-exercise-db (domaine public), fiche Band Assisted Pull-Up (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Band_Assisted_Pull-Up.json)', array['grand_dorsal']::text[], array['biceps', 'rhomboides']::text[], array['dos', 'bras']::text[], array['renforcer', 'tonifier']::text[], 'renforcement', false, 'reps', 12, 3.5, '02054', '{"steps":["Élastique fixé en haut d''une porte fermée, à genoux face à la porte.","Bras tendus vers le haut, tire les coudes vers les côtes.","Remonte lentement en gardant les épaules basses."],"breathing":"Expire en tirant, inspire en remontant.","mistakes":["Se pencher en arrière.","Hausser les épaules."]}'::jsonb),
('developpe_elastique', 'Développé épaules à l''élastique', 'force', null, null, array['Debout sur l''élastique, mains à hauteur d''épaules.', 'Pousse vers le haut jusqu''à tendre les bras.', 'Redescends lentement.']::text[], 'Ventre gainé, sans cambrer.', '[{"label":"Élastique léger","reps":12},{"label":"Élastique moyen","reps":12},{"label":"Un bras à la fois","reps":10}]'::jsonb, array['epaules']::text[], array['elastique']::text[], 2, 'poussee-verticale', 'poussee-verticale', 3, false, 'free-exercise-db (domaine public), fiche Shoulder Press - With Bands (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Shoulder_Press_-_With_Bands.json)', array['deltoides_anterieurs', 'deltoides_lateraux']::text[], array['triceps']::text[], array['epaules']::text[], array['renforcer', 'tonifier']::text[], 'renforcement', false, 'reps', 12, 3.5, '02054', '{"steps":["Debout sur l''élastique, mains à hauteur d''épaules.","Pousse vers le haut jusqu''à tendre les bras.","Redescends lentement."],"breathing":"Expire en poussant, inspire en descendant.","mistakes":["Cambrer le dos.","Pousser vers l''avant au lieu du haut."]}'::jsonb),
('superman', 'Superman', 'force', null, null, array['Allongé sur le ventre, bras tendus devant toi, front au sol.', 'Décolle en même temps bras et jambes de quelques centimètres.', 'Redescends lentement.']::text[], 'Petite hauteur suffit : le regard reste vers le sol.', '[{"label":"Bras seuls, puis jambes seules","reps":8},{"label":"Bras et jambes ensemble","reps":10},{"label":"Maintien de 3 s en haut","reps":10}]'::jsonb, array['lombaires', 'fessiers']::text[], array['aucun']::text[], 2, 'extension-dos', 'extension-dos', 3, false, 'free-exercise-db (domaine public), fiche Superman (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Superman.json)', array['lombaires', 'grand_fessier']::text[], array['rhomboides', 'ischio_jambiers']::text[], array['dos', 'fessiers']::text[], array['renforcer']::text[], 'renforcement', false, 'reps', 10, 3.5, '02030', '{"steps":["Allongé sur le ventre, bras tendus devant toi, front au sol.","Décolle en même temps bras et jambes de quelques centimètres.","Redescends lentement."],"breathing":"Expire en montant, inspire en descendant.","mistakes":["Lever la tête vers l''avant.","Monter trop haut en forçant sur le bas du dos."]}'::jsonb),
('ytw', 'Y, T, W au sol', 'force', null, null, array['Allongé sur le ventre, front sur une serviette roulée.', 'Décolle les bras en Y, puis en T, puis en W (coudes pliés, ramenés vers les côtes).', 'Pouces vers le plafond, serre les omoplates à chaque lettre.']::text[], 'Mouvement lent, épaules loin des oreilles.', '[{"label":"2 de chaque lettre","reps":6},{"label":"3 de chaque lettre","reps":9},{"label":"3 de chaque, pause de 2 s","reps":9}]'::jsonb, array['dos', 'epaules']::text[], array['aucun']::text[], 2, 'retraction-scapulaire', 'tirage', 3, false, 'free-exercise-db (domaine public), fiche Reverse Flyes With External Rotation (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Reverse_Flyes_With_External_Rotation.json)', array['rhomboides', 'trapezes', 'deltoides_posterieurs']::text[], array['coiffe_rotateurs', 'lombaires']::text[], array['dos', 'epaules']::text[], array['renforcer', 'mobilite']::text[], 'renforcement', false, 'reps', 9, 3.5, '02030', '{"steps":["Allongé sur le ventre, front sur une serviette roulée.","Décolle les bras en Y, puis en T, puis en W (coudes pliés, ramenés vers les côtes).","Pouces vers le plafond, serre les omoplates à chaque lettre."],"breathing":"Expire en décollant les bras, inspire en les reposant.","mistakes":["Décoller la poitrine en cambrant.","Aller trop vite."]}'::jsonb),
('rowing_inverse_table', 'Rowing inversé sous une table', 'force', null, null, array['Allongé sous une table très solide, mains sur le bord, bras tendus.', 'Corps gainé, tire la poitrine vers le bord de la table.', 'Redescends lentement.']::text[], 'Seulement avec une table lourde et stable qui ne peut pas basculer. Teste-la avant.', '[{"label":"Genoux pliés","reps":6},{"label":"Genoux pliés","reps":8},{"label":"Jambes tendues","reps":8}]'::jsonb, array['dos']::text[], array['aucun']::text[], 4, 'tirage', 'tirage', 3, false, 'free-exercise-db (domaine public), fiche Inverted Row (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Inverted_Row.json)', array['grand_dorsal', 'rhomboides']::text[], array['biceps', 'deltoides_posterieurs', 'transverse']::text[], array['dos', 'bras']::text[], array['renforcer']::text[], 'calisthenie', false, 'reps', 8, 3.8, '02022', '{"steps":["Allongé sous une table très solide, mains sur le bord, bras tendus.","Corps gainé, tire la poitrine vers le bord de la table.","Redescends lentement."],"breathing":"Expire en tirant, inspire en redescendant.","mistakes":["Bassin qui s''affaisse.","Tirer avec le cou."]}'::jsonb),
('crunch', 'Crunch', 'gainage', null, null, array['Allongé sur le dos, genoux pliés, pieds à plat.', 'Enroule le haut du dos pour décoller les omoplates.', 'Redescends lentement sans reposer complètement la tête.']::text[], 'Ne tire pas sur la nuque avec les mains.', '[{"label":"Mains sur les cuisses","reps":12},{"label":"Mains croisées sur la poitrine","reps":15},{"label":"Pause de 2 s en haut","reps":15}]'::jsonb, array['abdos']::text[], array['aucun']::text[], 2, 'flexion-tronc', 'flexion-tronc', 3, false, 'free-exercise-db (domaine public), fiche Crunches (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Crunches.json)', array['grand_droit']::text[], array['obliques']::text[], array['abdos']::text[], array['tonifier', 'renforcer']::text[], 'renforcement', false, 'reps', 15, 2.8, '02024', '{"steps":["Allongé sur le dos, genoux pliés, pieds à plat.","Enroule le haut du dos pour décoller les omoplates.","Redescends lentement sans reposer complètement la tête."],"breathing":"Expire en montant, inspire en redescendant.","mistakes":["Tirer sur la tête.","Monter trop haut avec élan."]}'::jsonb),
('crunch_inverse', 'Crunch inversé', 'gainage', null, null, array['Allongé sur le dos, genoux pliés au-dessus des hanches, bras le long du corps.', 'Ramène les genoux vers la poitrine en décollant légèrement le bassin.', 'Redescends lentement.']::text[], 'On enroule le bassin, on ne balance pas les jambes.', '[{"label":"Petite amplitude","reps":10},{"label":"Bassin décollé","reps":12},{"label":"Descente lente en 3 s","reps":12}]'::jsonb, array['abdos']::text[], array['aucun']::text[], 2, 'flexion-tronc', 'flexion-tronc', 3, false, 'free-exercise-db (domaine public), fiche Reverse Crunch (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Reverse_Crunch.json)', array['grand_droit']::text[], array['obliques', 'flechisseurs_hanche']::text[], array['abdos']::text[], array['tonifier', 'renforcer']::text[], 'renforcement', false, 'reps', 12, 2.8, '02024', '{"steps":["Allongé sur le dos, genoux pliés au-dessus des hanches, bras le long du corps.","Ramène les genoux vers la poitrine en décollant légèrement le bassin.","Redescends lentement."],"breathing":"Expire en enroulant, inspire en revenant.","mistakes":["Prendre de l''élan.","Appuyer fort sur les mains."]}'::jsonb),
('crunch_velo', 'Crunch vélo', 'gainage', null, null, array['Allongé sur le dos, mains aux tempes, omoplates décollées.', 'Amène un coude vers le genou opposé pendant que l''autre jambe s''allonge.', 'Alterne lentement, comme un pédalage.']::text[], 'Le bas du dos reste au sol.', '[{"label":"Pieds proches du sol en alternance lente","reps":12},{"label":"16 alternances","reps":16},{"label":"20 alternances","reps":20}]'::jsonb, array['obliques', 'abdos']::text[], array['aucun']::text[], 3, 'rotation-tronc', 'rotation', 3, false, 'free-exercise-db (domaine public), fiche Cross-Body Crunch (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Cross-Body_Crunch.json) ; free-exercise-db (domaine public), fiche Elbow to Knee (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Elbow_to_Knee.json)', array['obliques', 'grand_droit']::text[], array['flechisseurs_hanche']::text[], array['abdos']::text[], array['tonifier', 'renforcer']::text[], 'renforcement', false, 'reps', 16, 2.8, '02024', '{"steps":["Allongé sur le dos, mains aux tempes, omoplates décollées.","Amène un coude vers le genou opposé pendant que l''autre jambe s''allonge.","Alterne lentement, comme un pédalage."],"breathing":"Expire à chaque rotation.","mistakes":["Tirer sur la nuque.","Aller vite et perdre le contrôle."]}'::jsonb),
('releve_jambes', 'Relevé de jambes', 'gainage', null, null, array['Allongé sur le dos, mains sous les fesses.', 'Monte les jambes jusqu''à la verticale.', 'Redescends lentement sans que le bas du dos décolle.']::text[], 'Arrête la descente avant que le dos ne se creuse.', '[{"label":"Genoux pliés","reps":10},{"label":"Jambes tendues, petite amplitude","reps":8},{"label":"Jambes tendues","reps":10}]'::jsonb, array['abdos', 'hanches']::text[], array['aucun']::text[], 3, 'flexion-tronc', 'anti-extension', 3, false, 'free-exercise-db (domaine public), fiche Flat Bench Lying Leg Raise (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Flat_Bench_Lying_Leg_Raise.json)', array['grand_droit', 'flechisseurs_hanche']::text[], array['transverse']::text[], array['abdos']::text[], array['renforcer']::text[], 'renforcement', false, 'reps', 10, 2.8, '02024', '{"steps":["Allongé sur le dos, mains sous les fesses.","Monte les jambes jusqu''à la verticale.","Redescends lentement sans que le bas du dos décolle."],"breathing":"Expire en montant, inspire en descendant.","mistakes":["Dos qui se creuse en bas.","Jambes qui tombent."]}'::jsonb),
('ciseaux', 'Battements de jambes (ciseaux)', 'gainage', null, null, array['Allongé sur le dos, mains sous les fesses, jambes tendues levées.', 'Fais de petits battements de haut en bas, en alternant.', 'Le bas du dos reste collé au sol.']::text[], 'Plus les jambes sont hautes, plus c''est facile.', '[{"label":"Jambes hautes","seconds":20},{"label":"Jambes hautes","seconds":30},{"label":"Jambes plus basses","seconds":30}]'::jsonb, array['abdos']::text[], array['aucun']::text[], 3, 'anti-extension', 'anti-extension', 3, false, 'free-exercise-db (domaine public), fiche Flutter Kicks (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Flutter_Kicks.json) ; free-exercise-db (domaine public), fiche Scissor Kick (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Scissor_Kick.json)', array['grand_droit', 'transverse']::text[], array['flechisseurs_hanche']::text[], array['abdos']::text[], array['tonifier', 'renforcer']::text[], 'gainage', false, 'time', 30, 2.8, '02024', '{"steps":["Allongé sur le dos, mains sous les fesses, jambes tendues levées.","Fais de petits battements de haut en bas, en alternant.","Le bas du dos reste collé au sol."],"breathing":"Respire régulièrement, sans bloquer.","mistakes":["Dos qui se creuse.","Grands battements trop rapides."]}'::jsonb),
('toucher_talons', 'Touchers de talons', 'gainage', null, null, array['Allongé sur le dos, genoux pliés, pieds écartés, omoplates décollées.', 'Penche-toi sur le côté pour toucher le talon avec la main.', 'Alterne à droite et à gauche, sans reposer les épaules.']::text[], 'Mouvement latéral, la nuque reste longue.', '[{"label":"16 touchers","reps":16},{"label":"20 touchers","reps":20},{"label":"24 touchers","reps":24}]'::jsonb, array['obliques']::text[], array['aucun']::text[], 2, 'flexion-laterale', 'flexion-laterale', 3, false, 'free-exercise-db (domaine public), fiche Alternate Heel Touchers (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Alternate_Heel_Touchers.json)', array['obliques']::text[], array['grand_droit']::text[], array['abdos']::text[], array['tonifier']::text[], 'renforcement', false, 'reps', 20, 2.8, '02024', '{"steps":["Allongé sur le dos, genoux pliés, pieds écartés, omoplates décollées.","Penche-toi sur le côté pour toucher le talon avec la main.","Alterne à droite et à gauche, sans reposer les épaules."],"breathing":"Expire à chaque toucher.","mistakes":["Reposer la tête entre chaque toucher.","Tirer avec le cou."]}'::jsonb),
('rotation_russe', 'Rotation russe', 'gainage', null, null, array['Assis, genoux pliés, buste incliné en arrière, dos droit.', 'Mains jointes, tourne le buste pour amener les mains d''un côté puis de l''autre.', 'Le regard suit les mains.']::text[], 'C''est le buste qui tourne, pas seulement les bras.', '[{"label":"Pieds au sol","reps":12},{"label":"Pieds au sol","reps":16},{"label":"Pieds décollés","reps":16},{"label":"Haltère en main","reps":16}]'::jsonb, array['obliques']::text[], array['aucun']::text[], 3, 'rotation-tronc', 'rotation', 3, false, 'free-exercise-db (domaine public), fiche Russian Twist (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Russian_Twist.json)', array['obliques']::text[], array['grand_droit', 'transverse']::text[], array['abdos']::text[], array['tonifier', 'renforcer']::text[], 'renforcement', false, 'reps', 16, 2.8, '02024', '{"steps":["Assis, genoux pliés, buste incliné en arrière, dos droit.","Mains jointes, tourne le buste pour amener les mains d''un côté puis de l''autre.","Le regard suit les mains."],"breathing":"Expire à chaque rotation.","mistakes":["Dos arrondi.","Bouger seulement les bras."]}'::jsonb),
('hollow', 'Hollow hold (position creuse)', 'gainage', null, null, array['Allongé sur le dos, plaque le bas du dos au sol.', 'Décolle les épaules et les jambes : ton corps forme une banane.', 'Tiens la position sans que le dos ne décolle.']::text[], 'Dès que le bas du dos décolle, remonte les jambes ou plie les genoux.', '[{"label":"Genoux pliés, bras le long du corps","seconds":15},{"label":"Jambes tendues hautes","seconds":20},{"label":"Bras tendus derrière la tête","seconds":20},{"label":"Bras derrière la tête","seconds":30}]'::jsonb, array['abdos']::text[], array['aucun']::text[], 4, 'anti-extension', 'anti-extension', 3, false, 'free-exercise-db (domaine public), fiche Plank (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Plank.json)', array['grand_droit', 'transverse']::text[], array['flechisseurs_hanche', 'obliques']::text[], array['abdos']::text[], array['renforcer']::text[], 'calisthenie', false, 'time', 20, 2.8, '02024', '{"steps":["Allongé sur le dos, plaque le bas du dos au sol.","Décolle les épaules et les jambes : ton corps forme une banane.","Tiens la position sans que le dos ne décolle."],"breathing":"Respirations courtes et régulières.","mistakes":["Bas du dos décollé.","Menton collé à la poitrine."]}'::jsonb),
('planche_epaules', 'Planche, touchers d''épaule', 'gainage', null, null, array['En planche bras tendus, mains sous les épaules.', 'Touche une épaule avec la main opposée, repose, puis alterne.', 'Le bassin ne bouge pas.']::text[], 'Écarte davantage les pieds si le bassin se balance.', '[{"label":"Sur les genoux","reps":12},{"label":"Sur les pieds, pieds écartés","reps":16},{"label":"Pieds serrés","reps":16}]'::jsonb, array['abdos', 'obliques']::text[], array['aucun']::text[], 3, 'planche', 'anti-rotation', 3, false, 'free-exercise-db (domaine public), fiche Plank (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Plank.json)', array['transverse', 'obliques']::text[], array['deltoides_anterieurs', 'pectoraux', 'triceps']::text[], array['abdos', 'epaules']::text[], array['renforcer']::text[], 'gainage', false, 'reps', 16, 2.8, '02024', '{"steps":["En planche bras tendus, mains sous les épaules.","Touche une épaule avec la main opposée, repose, puis alterne.","Le bassin ne bouge pas."],"breathing":"Respire calmement à chaque toucher.","mistakes":["Bassin qui se balance de gauche à droite.","Fesses qui montent."]}'::jsonb),
('planche_dynamique', 'Planche montante (coudes, puis mains)', 'gainage', null, null, array['En planche sur les avant-bras.', 'Pose une main puis l''autre pour monter en planche bras tendus.', 'Redescends un coude après l''autre. Alterne le bras qui commence.']::text[], 'Pieds écartés pour garder le bassin stable.', '[{"label":"Sur les genoux","reps":8},{"label":"Sur les pieds","reps":8},{"label":"Sur les pieds","reps":12}]'::jsonb, array['abdos', 'bras']::text[], array['aucun']::text[], 4, 'planche', 'anti-extension', 3, false, 'free-exercise-db (domaine public), fiche Plank (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Plank.json)', array['transverse', 'triceps']::text[], array['deltoides_anterieurs', 'pectoraux', 'obliques']::text[], array['abdos', 'bras', 'epaules']::text[], array['renforcer']::text[], 'gainage', false, 'reps', 10, 3.8, '02022', '{"steps":["En planche sur les avant-bras.","Pose une main puis l''autre pour monter en planche bras tendus.","Redescends un coude après l''autre. Alterne le bras qui commence."],"breathing":"Expire en montant, inspire en descendant.","mistakes":["Bassin qui oscille.","Fesses qui montent."]}'::jsonb),
('planche_inverse', 'Planche inversée', 'gainage', null, null, array['Assis, mains au sol derrière les hanches, doigts vers les pieds.', 'Pousse dans les mains et les talons pour monter le bassin.', 'Corps aligné, tiens la position.']::text[], 'Épaules basses, poitrine ouverte.', '[{"label":"Genoux pliés (table)","seconds":20},{"label":"Jambes tendues","seconds":15},{"label":"Jambes tendues","seconds":25}]'::jsonb, array['fessiers', 'lombaires', 'bras']::text[], array['aucun']::text[], 3, 'planche-inversee', 'pont', 3, false, 'free-exercise-db (domaine public), fiche Butt-Ups (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Butt-Ups.json)', array['grand_fessier', 'lombaires', 'triceps']::text[], array['ischio_jambiers', 'deltoides_posterieurs']::text[], array['dos', 'fessiers', 'bras']::text[], array['renforcer']::text[], 'gainage', false, 'time', 20, 2.8, '02024', '{"steps":["Assis, mains au sol derrière les hanches, doigts vers les pieds.","Pousse dans les mains et les talons pour monter le bassin.","Corps aligné, tiens la position."],"breathing":"Respire calmement.","mistakes":["Bassin qui descend.","Tête qui tombe en arrière."]}'::jsonb),
('ours_statique', 'Position de l''ours (bear hold)', 'gainage', null, null, array['À quatre pattes, mains sous les épaules, genoux sous les hanches.', 'Décolle les genoux de quelques centimètres, dos plat.', 'Tiens la position.']::text[], 'Les genoux restent tout près du sol.', '[{"label":"Genoux décollés de 2 cm","seconds":15},{"label":"Genoux décollés","seconds":25},{"label":"En levant une main en alternance","seconds":30}]'::jsonb, array['abdos']::text[], array['aucun']::text[], 2, 'planche', 'anti-extension', 3, false, 'free-exercise-db (domaine public), fiche Plank (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Plank.json)', array['transverse', 'grand_droit']::text[], array['deltoides_anterieurs', 'quadriceps']::text[], array['abdos', 'epaules']::text[], array['renforcer']::text[], 'gainage', false, 'time', 20, 2.8, '02024', '{"steps":["À quatre pattes, mains sous les épaules, genoux sous les hanches.","Décolle les genoux de quelques centimètres, dos plat.","Tiens la position."],"breathing":"Respire lentement par le nez.","mistakes":["Fesses qui montent.","Dos qui s''arrondit."]}'::jsonb),
('planche_laterale_rotation', 'Planche latérale avec rotation', 'gainage', null, null, array['En planche latérale sur l''avant-bras, bras du dessus tendu vers le plafond.', 'Passe la main sous ton buste en tournant, puis reviens ouvrir.', 'Le bassin reste haut. Change de côté.']::text[], 'Reviens à la planche latérale classique si le bassin descend.', '[{"label":"Sur le genou","reps":8},{"label":"Sur les pieds","reps":8},{"label":"Sur les pieds","reps":10}]'::jsonb, array['obliques']::text[], array['aucun']::text[], 4, 'gainage-lateral', 'gainage-lateral', 3, false, 'free-exercise-db (domaine public), fiche Side Bridge (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Side_Bridge.json)', array['obliques']::text[], array['transverse', 'deltoides_lateraux', 'moyen_fessier']::text[], array['abdos']::text[], array['renforcer', 'tonifier']::text[], 'gainage', false, 'reps', 8, 2.8, '02024', '{"steps":["En planche latérale sur l''avant-bras, bras du dessus tendu vers le plafond.","Passe la main sous ton buste en tournant, puis reviens ouvrir.","Le bassin reste haut. Change de côté."],"breathing":"Expire en tournant, inspire en ouvrant.","mistakes":["Bassin qui chute.","Épaule d''appui qui remonte vers l''oreille."]}'::jsonb),
('v_up', 'V-up (relevé en V)', 'gainage', null, null, array['Allongé sur le dos, bras tendus derrière la tête.', 'Lève en même temps buste et jambes pour toucher les pieds avec les mains.', 'Redescends lentement, sans t''écraser au sol.']::text[], 'Exercice avancé : maîtrise d''abord le hollow hold.', '[{"label":"Genoux pliés (tuck-up)","reps":8},{"label":"Une jambe tendue en alternance","reps":8},{"label":"Jambes tendues","reps":8}]'::jsonb, array['abdos']::text[], array['aucun']::text[], 5, 'flexion-tronc', 'flexion-tronc', 3, false, 'free-exercise-db (domaine public), fiche Jackknife Sit-Up (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Jackknife_Sit-Up.json)', array['grand_droit']::text[], array['flechisseurs_hanche', 'obliques']::text[], array['abdos']::text[], array['renforcer']::text[], 'calisthenie', false, 'reps', 8, 7.5, '02020', '{"steps":["Allongé sur le dos, bras tendus derrière la tête.","Lève en même temps buste et jambes pour toucher les pieds avec les mains.","Redescends lentement, sans t''écraser au sol."],"breathing":"Expire en montant, inspire en descendant.","mistakes":["Retomber lourdement.","Prendre de l''élan avec les bras."]}'::jsonb),
('chenille', 'Chenille (inchworm)', 'force', null, null, array['Debout, penche-toi pour poser les mains au sol, genoux fléchis si besoin.', 'Avance les mains une à une jusqu''à la planche.', 'Ramène les mains vers les pieds en marchant, puis redresse-toi.']::text[], 'Plie les genoux autant que nécessaire pour poser les mains.', '[{"label":"Genoux fléchis","reps":5},{"label":"Jambes presque tendues","reps":6},{"label":"Avec une pompe en bas","reps":6}]'::jsonb, array['abdos', 'epaules', 'ischios']::text[], array['aucun']::text[], 3, 'chenille', 'corps-entier', 3, false, 'free-exercise-db (domaine public), fiche Inchworm (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Inchworm.json)', array['transverse', 'deltoides_anterieurs', 'ischio_jambiers']::text[], array['pectoraux', 'triceps']::text[], array['corps_entier']::text[], array['renforcer', 'mobilite']::text[], 'calisthenie', false, 'reps', 6, 3.8, '02022', '{"steps":["Debout, penche-toi pour poser les mains au sol, genoux fléchis si besoin.","Avance les mains une à une jusqu''à la planche.","Ramène les mains vers les pieds en marchant, puis redresse-toi."],"breathing":"Expire en avançant vers la planche, inspire en revenant.","mistakes":["Bassin qui s''affaisse en planche.","Se redresser trop vite."]}'::jsonb),
('marche_ours', 'Marche de l''ours', 'cardio', null, null, array['À quatre pattes, genoux décollés de quelques centimètres.', 'Avance main droite et pied gauche ensemble, puis l''inverse.', 'Fais quelques pas en avant, puis en arrière.']::text[], 'Petits pas, dos plat, genoux proches du sol.', '[{"label":"Avant, arrière, lentement","seconds":20},{"label":"30 s","seconds":30},{"label":"Plus rapide","seconds":30}]'::jsonb, array['epaules', 'abdos', 'cuisses']::text[], array['aucun']::text[], 3, 'quadrupedie', 'corps-entier', 3, false, 'free-exercise-db (domaine public), fiche Bear Crawl Sled Drags (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Bear_Crawl_Sled_Drags.json)', array['deltoides_anterieurs', 'transverse', 'quadriceps']::text[], array['triceps', 'grand_fessier']::text[], array['corps_entier']::text[], array['renforcer', 'cardio']::text[], 'calisthenie', false, 'time', 30, 7.5, '02020', '{"steps":["À quatre pattes, genoux décollés de quelques centimètres.","Avance main droite et pied gauche ensemble, puis l''inverse.","Fais quelques pas en avant, puis en arrière."],"breathing":"Respire régulièrement.","mistakes":["Fesses en l''air.","Grands pas qui déstabilisent."]}'::jsonb),
('marche_genoux_hauts', 'Marche sur place, genoux hauts', 'cardio', null, null, array['Debout, marche sur place en montant les genoux vers la hauteur des hanches.', 'Balance les bras en opposition.', 'Garde le buste droit et le ventre tenu.']::text[], 'Version sans saut des montées de genoux.', '[{"label":"Rythme tranquille","seconds":30},{"label":"Rythme soutenu","seconds":40},{"label":"Avec bras actifs","seconds":45}]'::jsonb, array['hanches', 'cuisses']::text[], array['aucun']::text[], 2, 'course-sur-place', 'cardio', 4, false, 'OMS, recommandations 2020 sur l''activité physique (Bull et al., BJSM) (https://pmc.ncbi.nlm.nih.gov/articles/PMC7719906/) ; free-exercise-db (domaine public), fiche Step-up with Knee Raise (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Step-up_with_Knee_Raise.json)', array['flechisseurs_hanche', 'quadriceps']::text[], array['mollets', 'transverse']::text[], array['corps_entier', 'jambes']::text[], array['cardio']::text[], 'cardio', false, 'time', 40, 3.5, '02030', '{"steps":["Debout, marche sur place en montant les genoux vers la hauteur des hanches.","Balance les bras en opposition.","Garde le buste droit et le ventre tenu."],"breathing":"Respire librement, au rythme des pas.","mistakes":["Se pencher en arrière.","Genoux qui montent à peine."]}'::jsonb),
('step_jacks', 'Jumping jacks sans saut', 'cardio', null, null, array['Debout, pieds joints, bras le long du corps.', 'Pose un pied sur le côté en levant les bras au-dessus de la tête.', 'Reviens au centre, puis l''autre pied. Enchaîne sans t''arrêter.']::text[], 'Aucun saut : idéal pour les voisins du dessous et les articulations.', '[{"label":"Rythme tranquille","seconds":30},{"label":"Rythme soutenu","seconds":40},{"label":"Rythme soutenu","seconds":45}]'::jsonb, array['epaules', 'hanches']::text[], array['aucun']::text[], 2, 'jumping-jacks', 'cardio', 4, false, 'free-exercise-db (domaine public), fiche Star Jump (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Star_Jump.json)', array['deltoides_lateraux', 'moyen_fessier']::text[], array['mollets', 'adducteurs']::text[], array['corps_entier']::text[], array['cardio']::text[], 'cardio', false, 'time', 40, 3.5, '02030', '{"steps":["Debout, pieds joints, bras le long du corps.","Pose un pied sur le côté en levant les bras au-dessus de la tête.","Reviens au centre, puis l''autre pied. Enchaîne sans t''arrêter."],"breathing":"Respire au rythme des pas.","mistakes":["Bras qui ne montent qu''à mi-hauteur.","Rythme trop lent pour élever le cœur."]}'::jsonb),
('boxe_ombre', 'Boxe dans le vide', 'cardio', null, null, array['En garde, pieds décalés, genoux souples, poings devant le menton.', 'Envoie des directs alternés en tournant légèrement le buste.', 'Ramène toujours le poing en garde.']::text[], 'Ne verrouille pas le coude au bout du coup.', '[{"label":"Directs alternés","seconds":30},{"label":"Directs et crochets","seconds":40},{"label":"En sautillant sur place","seconds":45}]'::jsonb, array['epaules', 'bras']::text[], array['aucun']::text[], 2, 'boxe', 'cardio', 4, false, 'OMS, recommandations 2020 sur l''activité physique (Bull et al., BJSM) (https://pmc.ncbi.nlm.nih.gov/articles/PMC7719906/)', array['deltoides_anterieurs', 'triceps']::text[], array['obliques', 'pectoraux', 'mollets']::text[], array['corps_entier', 'bras', 'epaules']::text[], array['cardio', 'tonifier']::text[], 'cardio', false, 'time', 40, 6.0, '02032', '{"steps":["En garde, pieds décalés, genoux souples, poings devant le menton.","Envoie des directs alternés en tournant légèrement le buste.","Ramène toujours le poing en garde."],"breathing":"Expire à chaque coup.","mistakes":["Bras tendus à fond en claquant le coude.","Garde qui descend."]}'::jsonb),
('burpee_sans_saut', 'Burpee sans saut', 'cardio', null, null, array['Debout, accroupis-toi et pose les mains au sol.', 'Recule un pied puis l''autre pour arriver en planche.', 'Ramène les pieds un par un, puis relève-toi en tendant les bras.']::text[], 'Version sans saut du burpee.', '[{"label":"Pieds reculés un par un","reps":6},{"label":"8 répétitions","reps":8},{"label":"Avec une pompe","reps":8}]'::jsonb, array['cuisses', 'pectoraux', 'abdos']::text[], array['aucun']::text[], 3, 'burpee', 'corps-entier', 3, false, 'free-exercise-db (domaine public), fiche Push Up to Side Plank (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Push_Up_to_Side_Plank.json)', array['quadriceps', 'pectoraux', 'transverse']::text[], array['grand_fessier', 'triceps', 'deltoides_anterieurs']::text[], array['corps_entier']::text[], array['cardio', 'renforcer']::text[], 'hiit', false, 'reps', 8, 6.0, '02032', '{"steps":["Debout, accroupis-toi et pose les mains au sol.","Recule un pied puis l''autre pour arriver en planche.","Ramène les pieds un par un, puis relève-toi en tendant les bras."],"breathing":"Expire en te relevant.","mistakes":["Bassin qui s''affaisse en planche.","Dos arrondi en se relevant."]}'::jsonb),
('mountain_climbers_lents', 'Mountain climbers lents', 'cardio', null, null, array['En planche bras tendus.', 'Ramène un genou vers la poitrine, repose le pied, puis l''autre.', 'Rythme contrôlé, bassin stable.']::text[], 'Version sans élan des mountain climbers.', '[{"label":"Mains sur une chaise","seconds":30},{"label":"Mains au sol","seconds":30},{"label":"Mains au sol","seconds":40}]'::jsonb, array['abdos', 'hanches']::text[], array['aucun']::text[], 2, 'mountain-climbers', 'anti-extension', 3, false, 'free-exercise-db (domaine public), fiche Mountain Climbers (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Mountain_Climbers.json)', array['transverse', 'flechisseurs_hanche']::text[], array['deltoides_anterieurs', 'quadriceps']::text[], array['abdos', 'corps_entier']::text[], array['cardio', 'renforcer']::text[], 'cardio', false, 'time', 30, 6.0, '02032', '{"steps":["En planche bras tendus.","Ramène un genou vers la poitrine, repose le pied, puis l''autre.","Rythme contrôlé, bassin stable."],"breathing":"Expire à chaque genou ramené.","mistakes":["Fesses qui montent.","Épaules qui reculent derrière les mains."]}'::jsonb),
('patineur_sans_saut', 'Patineur sans saut', 'cardio', null, null, array['Fais un grand pas en diagonale arrière, la jambe croise derrière l''autre.', 'Plie la jambe d''appui en balançant les bras comme un patineur.', 'Reviens et alterne les côtés.']::text[], 'Version sans saut du patineur.', '[{"label":"Petits pas","seconds":30},{"label":"Grands pas","seconds":40},{"label":"Grands pas, plus bas","seconds":45}]'::jsonb, array['hanches', 'cuisses']::text[], array['aucun']::text[], 2, 'patineur', 'cardio', 3, false, 'free-exercise-db (domaine public), fiche Crossover Reverse Lunge (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Crossover_Reverse_Lunge.json)', array['moyen_fessier', 'quadriceps']::text[], array['grand_fessier', 'adducteurs']::text[], array['jambes', 'fessiers']::text[], array['cardio', 'tonifier']::text[], 'cardio', false, 'time', 40, 6.0, '02032', '{"steps":["Fais un grand pas en diagonale arrière, la jambe croise derrière l''autre.","Plie la jambe d''appui en balançant les bras comme un patineur.","Reviens et alterne les côtés."],"breathing":"Respire au rythme des pas.","mistakes":["Genou d''appui qui rentre vers l''intérieur.","Buste trop penché."]}'::jsonb),
('squat_coup_de_pied', 'Squat, coup de pied avant', 'cardio', null, null, array['Fais un squat.', 'En te relevant, donne un coup de pied devant toi.', 'Repose et enchaîne avec l''autre jambe.']::text[], 'Coup de pied contrôlé, sans verrouiller le genou.', '[{"label":"Squat léger","seconds":30},{"label":"40 s","seconds":40},{"label":"Squat profond","seconds":45}]'::jsonb, array['cuisses', 'fessiers']::text[], array['aucun']::text[], 2, 'squat', 'squat', 3, false, 'free-exercise-db (domaine public), fiche Bodyweight Squat (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Bodyweight_Squat.json)', array['quadriceps', 'grand_fessier']::text[], array['flechisseurs_hanche', 'transverse']::text[], array['jambes', 'abdos']::text[], array['cardio', 'tonifier']::text[], 'cardio', false, 'time', 40, 6.0, '02032', '{"steps":["Fais un squat.","En te relevant, donne un coup de pied devant toi.","Repose et enchaîne avec l''autre jambe."],"breathing":"Expire au coup de pied.","mistakes":["Se pencher en arrière en tapant.","Squat bâclé."]}'::jsonb),
('fentes_alternees_rapides', 'Fentes arrière alternées, rythme rapide', 'cardio', null, null, array['Debout, recule une jambe en fente, puis reviens.', 'Enchaîne avec l''autre jambe sans pause, bras en balancier.', 'Garde un rythme régulier tout au long de l''effort.']::text[], 'Version sans saut de la fente sautée.', '[{"label":"Petite amplitude","seconds":30},{"label":"Amplitude complète","seconds":30},{"label":"Rythme soutenu","seconds":40}]'::jsonb, array['cuisses', 'fessiers']::text[], array['aucun']::text[], 3, 'fente-dynamique', 'fente', 3, false, 'free-exercise-db (domaine public), fiche Dumbbell Rear Lunge (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Dumbbell_Rear_Lunge.json)', array['quadriceps', 'grand_fessier']::text[], array['ischio_jambiers', 'mollets']::text[], array['jambes', 'fessiers']::text[], array['cardio', 'tonifier']::text[], 'cardio', false, 'time', 30, 6.0, '02032', '{"steps":["Debout, recule une jambe en fente, puis reviens.","Enchaîne avec l''autre jambe sans pause, bras en balancier.","Garde un rythme régulier tout au long de l''effort."],"breathing":"Respire au rythme des fentes.","mistakes":["Genou avant qui rentre vers l''intérieur.","Buste qui se penche."]}'::jsonb),
('jumping_jacks', 'Jumping jacks', 'cardio', null, null, array['Pieds joints, bras le long du corps.', 'Saute en écartant les pieds et en levant les bras au-dessus de la tête.', 'Saute pour revenir. Réceptions souples sur l''avant du pied.']::text[], 'Remplacé automatiquement par la version sans saut si les sauts sont exclus.', '[{"label":"Rythme tranquille","seconds":20},{"label":"30 s","seconds":30},{"label":"Rythme rapide","seconds":40}]'::jsonb, array['mollets', 'epaules']::text[], array['aucun']::text[], 3, 'jumping-jacks', 'cardio', 4, false, 'free-exercise-db (domaine public), fiche Star Jump (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Star_Jump.json)', array['mollets', 'deltoides_lateraux']::text[], array['moyen_fessier', 'adducteurs']::text[], array['corps_entier']::text[], array['cardio']::text[], 'hiit', true, 'time', 30, 7.5, '02020', '{"steps":["Pieds joints, bras le long du corps.","Saute en écartant les pieds et en levant les bras au-dessus de la tête.","Saute pour revenir. Réceptions souples sur l''avant du pied."],"breathing":"Respire librement et régulièrement.","mistakes":["Atterrir talons tendus.","Genoux raides."]}'::jsonb),
('montees_genoux', 'Montées de genoux', 'cardio', null, null, array['Cours sur place en montant les genoux à hauteur de hanches.', 'Reste sur l''avant des pieds, bras actifs.', 'Garde le buste droit.']::text[], 'Commence plus doucement si tu sors d''une longue pause.', '[{"label":"Rythme modéré","seconds":20},{"label":"30 s","seconds":30},{"label":"Rythme maximal","seconds":30}]'::jsonb, array['hanches', 'cuisses']::text[], array['aucun']::text[], 4, 'course-sur-place', 'cardio', 4, false, 'free-exercise-db (domaine public), fiche Fast Skipping (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Fast_Skipping.json)', array['flechisseurs_hanche', 'quadriceps']::text[], array['mollets', 'transverse']::text[], array['corps_entier', 'jambes']::text[], array['cardio']::text[], 'hiit', true, 'time', 30, 7.5, '02020', '{"steps":["Cours sur place en montant les genoux à hauteur de hanches.","Reste sur l''avant des pieds, bras actifs.","Garde le buste droit."],"breathing":"Respire activement, sans bloquer.","mistakes":["Buste penché en arrière.","Atterrir lourdement sur les talons."]}'::jsonb),
('talons_fesses', 'Talons-fesses', 'cardio', null, null, array['Trottine sur place en ramenant les talons vers les fesses.', 'Genoux pointés vers le sol.', 'Bras qui accompagnent le mouvement.']::text[], 'Le niveau 1 se fait en marchant : sans saut.', '[{"label":"En marchant","seconds":30},{"label":"En trottinant","seconds":30},{"label":"Rythme rapide","seconds":40}]'::jsonb, array['ischios']::text[], array['aucun']::text[], 3, 'course-sur-place', 'cardio', 4, false, 'free-exercise-db (domaine public), fiche Single Leg Butt Kick (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Single_Leg_Butt_Kick.json)', array['ischio_jambiers']::text[], array['mollets', 'quadriceps']::text[], array['jambes', 'corps_entier']::text[], array['cardio']::text[], 'cardio', true, 'time', 30, 7.5, '02020', '{"steps":["Trottine sur place en ramenant les talons vers les fesses.","Genoux pointés vers le sol.","Bras qui accompagnent le mouvement."],"breathing":"Respire au rythme de la course.","mistakes":["Genoux qui avancent.","Buste penché."]}'::jsonb),
('squat_saute', 'Squat sauté', 'cardio', null, null, array['Descends en squat.', 'Pousse fort pour sauter en tendant les jambes.', 'Réceptionne-toi en douceur en repliant directement dans le squat suivant.']::text[], 'Réception silencieuse : si ça fait du bruit, les genoux encaissent trop.', '[{"label":"Petits sauts","reps":8},{"label":"10 répétitions","reps":10},{"label":"Sauts hauts","reps":12}]'::jsonb, array['cuisses', 'fessiers']::text[], array['aucun']::text[], 4, 'squat', 'squat', 3, false, 'free-exercise-db (domaine public), fiche Freehand Jump Squat (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Freehand_Jump_Squat.json)', array['quadriceps', 'grand_fessier']::text[], array['mollets', 'ischio_jambiers']::text[], array['jambes', 'fessiers']::text[], array['cardio', 'renforcer']::text[], 'hiit', true, 'reps', 10, 11.0, '02214', '{"steps":["Descends en squat.","Pousse fort pour sauter en tendant les jambes.","Réceptionne-toi en douceur en repliant directement dans le squat suivant."],"breathing":"Expire en sautant.","mistakes":["Genoux qui rentrent à la réception.","Atterrir jambes tendues."]}'::jsonb),
('fente_sautee', 'Fente sautée', 'cardio', null, null, array['En position de fente.', 'Saute et inverse les jambes en l''air.', 'Réceptionne-toi en fente, genou arrière proche du sol.']::text[], 'Exercice exigeant pour les genoux : à réserver aux niveaux avancés.', '[{"label":"Fente arrière alternée rapide, sans saut","reps":10},{"label":"Petits sauts","reps":8},{"label":"10 sauts","reps":10}]'::jsonb, array['cuisses', 'fessiers']::text[], array['aucun']::text[], 5, 'fente-dynamique', 'fente', 3, false, 'free-exercise-db (domaine public), fiche Split Jump (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Split_Jump.json)', array['quadriceps', 'grand_fessier']::text[], array['ischio_jambiers', 'mollets']::text[], array['jambes', 'fessiers']::text[], array['cardio', 'renforcer']::text[], 'hiit', true, 'reps', 10, 11.0, '02214', '{"steps":["En position de fente.","Saute et inverse les jambes en l''air.","Réceptionne-toi en fente, genou arrière proche du sol."],"breathing":"Expire à chaque saut.","mistakes":["Pas trop étroit : perte d''équilibre.","Genou arrière qui tape le sol."]}'::jsonb),
('patineur', 'Patineur sauté', 'cardio', null, null, array['Bondis sur le côté pour atterrir sur un pied.', 'L''autre jambe passe derrière sans toucher le sol.', 'Repars de l''autre côté, bras en balancier.']::text[], 'Réception genou fléchi, dans l''axe du pied.', '[{"label":"Petits bonds","seconds":20},{"label":"30 s","seconds":30},{"label":"Grands bonds","seconds":30}]'::jsonb, array['hanches', 'cuisses']::text[], array['aucun']::text[], 4, 'patineur', 'cardio', 3, false, 'free-exercise-db (domaine public), fiche Lateral Bound (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Lateral_Bound.json)', array['moyen_fessier', 'quadriceps']::text[], array['grand_fessier', 'mollets']::text[], array['jambes', 'fessiers']::text[], array['cardio']::text[], 'hiit', true, 'time', 30, 11.0, '02214', '{"steps":["Bondis sur le côté pour atterrir sur un pied.","L''autre jambe passe derrière sans toucher le sol.","Repars de l''autre côté, bras en balancier."],"breathing":"Respire activement.","mistakes":["Genou qui rentre à la réception.","Réception jambe tendue."]}'::jsonb),
('burpee', 'Burpee', 'cardio', null, null, array['Accroupis-toi et pose les mains au sol.', 'Saute en arrière pour arriver en planche, puis ramène les pieds en sautant.', 'Relève-toi et saute, bras au-dessus de la tête.']::text[], 'Garde la planche propre même quand la fatigue arrive.', '[{"label":"Sans pompe","reps":6},{"label":"8 répétitions","reps":8},{"label":"Avec une pompe","reps":8},{"label":"10 répétitions","reps":10}]'::jsonb, array['cuisses', 'pectoraux', 'abdos']::text[], array['aucun']::text[], 5, 'burpee', 'corps-entier', 3, false, 'free-exercise-db (domaine public), fiche Push Up to Side Plank (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Push_Up_to_Side_Plank.json) ; free-exercise-db (domaine public), fiche Freehand Jump Squat (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Freehand_Jump_Squat.json)', array['quadriceps', 'pectoraux', 'transverse']::text[], array['grand_fessier', 'triceps', 'mollets']::text[], array['corps_entier']::text[], array['cardio', 'renforcer']::text[], 'hiit', true, 'reps', 8, 11.0, '02214', '{"steps":["Accroupis-toi et pose les mains au sol.","Saute en arrière pour arriver en planche, puis ramène les pieds en sautant.","Relève-toi et saute, bras au-dessus de la tête."],"breathing":"Expire au saut.","mistakes":["Bassin qui s''écrase au sol en planche.","Dos rond en se relevant."]}'::jsonb),
('mountain_climbers', 'Mountain climbers', 'cardio', null, null, array['En planche bras tendus.', 'Ramène rapidement les genoux vers la poitrine en alternance, comme si tu courais.', 'Épaules au-dessus des mains.']::text[], 'Le bassin reste bas et stable.', '[{"label":"Rythme modéré","seconds":20},{"label":"30 s","seconds":30},{"label":"Rythme maximal","seconds":30}]'::jsonb, array['abdos', 'hanches']::text[], array['aucun']::text[], 4, 'mountain-climbers', 'anti-extension', 3, false, 'free-exercise-db (domaine public), fiche Mountain Climbers (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Mountain_Climbers.json)', array['transverse', 'flechisseurs_hanche']::text[], array['deltoides_anterieurs', 'quadriceps', 'obliques']::text[], array['abdos', 'corps_entier']::text[], array['cardio', 'renforcer']::text[], 'hiit', true, 'time', 30, 11.0, '02214', '{"steps":["En planche bras tendus.","Ramène rapidement les genoux vers la poitrine en alternance, comme si tu courais.","Épaules au-dessus des mains."],"breathing":"Respire activement, sans bloquer.","mistakes":["Fesses en l''air.","Pieds qui ne touchent pas le sol à chaque pas."]}'::jsonb),
('corde_imaginaire', 'Corde à sauter imaginaire', 'cardio', null, null, array['Fais tourner des poignets comme si tu tenais une corde.', 'Saute à petite hauteur sur l''avant des pieds.', 'Genoux souples à chaque réception.']::text[], 'Petits sauts : quelques centimètres suffisent.', '[{"label":"Sauts pieds joints","seconds":20},{"label":"30 s","seconds":30},{"label":"Alternance des pieds, rapide","seconds":40}]'::jsonb, array['mollets']::text[], array['aucun']::text[], 3, 'course-sur-place', 'cardio', 4, false, 'free-exercise-db (domaine public), fiche Rope Jumping (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Rope_Jumping.json)', array['mollets']::text[], array['quadriceps', 'deltoides_lateraux']::text[], array['jambes', 'corps_entier']::text[], array['cardio']::text[], 'cardio', true, 'time', 30, 7.5, '02020', '{"steps":["Fais tourner des poignets comme si tu tenais une corde.","Saute à petite hauteur sur l''avant des pieds.","Genoux souples à chaque réception."],"breathing":"Respire régulièrement.","mistakes":["Sauter trop haut.","Atterrir sur les talons."]}'::jsonb),
('saut_etoile', 'Saut en étoile', 'cardio', null, null, array['Accroupis-toi légèrement.', 'Saute en écartant bras et jambes en étoile.', 'Reviens pieds joints en réception souple.']::text[], 'Exercice très intense : quelques répétitions suffisent.', '[{"label":"6 sauts","reps":6},{"label":"8 sauts","reps":8},{"label":"10 sauts","reps":10}]'::jsonb, array['cuisses', 'mollets']::text[], array['aucun']::text[], 5, 'jumping-jacks', 'cardio', 3, false, 'free-exercise-db (domaine public), fiche Star Jump (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Star_Jump.json)', array['quadriceps', 'mollets']::text[], array['grand_fessier', 'deltoides_lateraux']::text[], array['corps_entier']::text[], array['cardio']::text[], 'hiit', true, 'reps', 8, 11.0, '02214', '{"steps":["Accroupis-toi légèrement.","Saute en écartant bras et jambes en étoile.","Reviens pieds joints en réception souple."],"breathing":"Expire au saut.","mistakes":["Réception jambes tendues.","Enchaîner sans contrôle."]}'::jsonb),
('cercles_bras', 'Cercles de bras', 'mobilite', null, null, array['Debout, bras tendus sur les côtés.', 'Fais des cercles vers l''avant, de petits à grands.', 'Change de sens à mi-temps.']::text[], 'Amplitude progressive, sans forcer.', '[{"label":"Petits cercles","seconds":30},{"label":"Petits puis grands cercles","seconds":30}]'::jsonb, array['epaules']::text[], array['aucun']::text[], 1, 'echauffement-epaules', 'mobilite', 2, false, 'free-exercise-db (domaine public), fiche Arm Circles (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Arm_Circles.json)', array['deltoides_lateraux', 'deltoides_anterieurs']::text[], array['trapezes', 'coiffe_rotateurs']::text[], array['epaules']::text[], array['mobilite']::text[], 'etirement', false, 'time', 30, 2.3, '02101', '{"steps":["Debout, bras tendus sur les côtés.","Fais des cercles vers l''avant, de petits à grands.","Change de sens à mi-temps."],"breathing":"Respiration libre.","mistakes":["Hausser les épaules.","Cambrer le dos."]}'::jsonb),
('cercles_hanches', 'Cercles de hanches', 'mobilite', null, null, array['Debout, mains sur les hanches, pieds largeur de bassin.', 'Dessine de grands cercles avec le bassin.', 'Change de sens à mi-temps.']::text[], 'Les épaules restent à peu près immobiles.', '[{"label":"Petits cercles","seconds":30},{"label":"Grands cercles","seconds":30}]'::jsonb, array['hanches', 'obliques']::text[], array['aucun']::text[], 1, 'echauffement-hanches', 'mobilite', 2, false, 'free-exercise-db (domaine public), fiche Standing Hip Circles (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Standing_Hip_Circles.json)', array['flechisseurs_hanche', 'obliques']::text[], array['lombaires', 'moyen_fessier']::text[], array['fessiers', 'dos']::text[], array['mobilite']::text[], 'etirement', false, 'time', 30, 2.3, '02101', '{"steps":["Debout, mains sur les hanches, pieds largeur de bassin.","Dessine de grands cercles avec le bassin.","Change de sens à mi-temps."],"breathing":"Respiration libre.","mistakes":["Bouger les épaules plus que le bassin.","Genoux verrouillés."]}'::jsonb),
('balancier_jambes', 'Balanciers de jambe', 'mobilite', null, null, array['Une main au mur, balance une jambe d''avant en arrière.', 'Augmente l''amplitude progressivement, buste droit.', 'Change de jambe à mi-temps.']::text[], 'Mouvement de balancier relâché, sans lancer la jambe.', '[{"label":"Petite amplitude","seconds":30},{"label":"Amplitude croissante","seconds":40}]'::jsonb, array['ischios', 'hanches']::text[], array['mur']::text[], 1, 'echauffement-hanches', 'mobilite', 2, false, 'free-exercise-db (domaine public), fiche Front Leg Raises (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Front_Leg_Raises.json)', array['ischio_jambiers', 'flechisseurs_hanche']::text[], array['grand_fessier', 'adducteurs']::text[], array['jambes', 'fessiers']::text[], array['mobilite']::text[], 'etirement', false, 'time', 40, 2.3, '02101', '{"steps":["Une main au mur, balance une jambe d''avant en arrière.","Augmente l''amplitude progressivement, buste droit.","Change de jambe à mi-temps."],"breathing":"Respiration libre.","mistakes":["Se pencher pour lever la jambe plus haut.","Lancer la jambe brutalement."]}'::jsonb),
('rotations_buste', 'Rotations du buste', 'mobilite', null, null, array['Debout, pieds largeur de bassin, bras pliés devant la poitrine.', 'Tourne le buste d''un côté puis de l''autre.', 'Le bassin reste face à l''avant.']::text[], 'Rotation douce, sans à-coup.', '[{"label":"Lentement","seconds":30},{"label":"Plus d''amplitude","seconds":30}]'::jsonb, array['obliques']::text[], array['aucun']::text[], 1, 'echauffement-dos', 'mobilite', 2, false, 'free-exercise-db (domaine public), fiche Torso Rotation (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Torso_Rotation.json)', array['obliques']::text[], array['lombaires', 'rhomboides']::text[], array['dos', 'abdos']::text[], array['mobilite']::text[], 'etirement', false, 'time', 30, 2.3, '02101', '{"steps":["Debout, pieds largeur de bassin, bras pliés devant la poitrine.","Tourne le buste d''un côté puis de l''autre.","Le bassin reste face à l''avant."],"breathing":"Expire à chaque rotation.","mistakes":["Tourner le bassin avec le buste.","Aller trop vite."]}'::jsonb),
('plus_grand_etirement', 'Le plus grand étirement du monde', 'mobilite', null, null, array['Fente avant profonde, mains au sol à l''intérieur du pied avant.', 'Ouvre le bras côté jambe avant vers le plafond en tournant le buste.', 'Reviens, puis change de côté à mi-temps.']::text[], 'Pose le genou arrière au sol si besoin.', '[{"label":"Main au sol, sans rotation","seconds":45},{"label":"Avec rotation du buste","seconds":60}]'::jsonb, array['hanches', 'ischios']::text[], array['aucun']::text[], 2, 'echauffement-hanches', 'mobilite', 2, false, 'free-exercise-db (domaine public), fiche Worlds Greatest Stretch (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Worlds_Greatest_Stretch.json)', array['flechisseurs_hanche', 'ischio_jambiers']::text[], array['obliques', 'adducteurs', 'rhomboides']::text[], array['corps_entier', 'jambes', 'dos']::text[], array['mobilite']::text[], 'etirement', false, 'time', 60, 2.3, '02101', '{"steps":["Fente avant profonde, mains au sol à l''intérieur du pied avant.","Ouvre le bras côté jambe avant vers le plafond en tournant le buste.","Reviens, puis change de côté à mi-temps."],"breathing":"Inspire en ouvrant, expire en revenant.","mistakes":["Genou avant qui rentre vers l''intérieur.","Hanche arrière qui s''affaisse."]}'::jsonb),
('montagne', 'Posture de la montagne', 'mobilite', null, null, array['Debout, pieds parallèles, poids réparti sur tout le pied.', 'Grandis-toi par le sommet du crâne, épaules relâchées, bras le long du corps.', 'Reste immobile et observe ta respiration.']::text[], null, '[{"label":"30 s","seconds":30},{"label":"45 s, yeux fermés","seconds":45}]'::jsonb, array['abdos']::text[], array['aucun']::text[], 1, 'yoga-debout', 'yoga', 1, false, 'Yogamatters, bibliothèque de postures : Mountain Pose (Tadasana) (https://www.yogamatters.com/blogs/pose-library/mountain-pose-tadasana)', array['transverse']::text[], array['quadriceps', 'grand_fessier', 'mollets']::text[], array['corps_entier']::text[], array['detente', 'mobilite']::text[], 'yoga', false, 'time', 30, 2.3, '02150', '{"steps":["Debout, pieds parallèles, poids réparti sur tout le pied.","Grandis-toi par le sommet du crâne, épaules relâchées, bras le long du corps.","Reste immobile et observe ta respiration."],"breathing":"Respire lentement par le nez.","mistakes":["Verrouiller les genoux.","Pousser le ventre en avant."]}'::jsonb),
('salutation_soleil', 'Salutation au soleil (version douce)', 'mobilite', null, null, array['Enchaîne les postures au rythme de ta respiration : une posture, un souffle.', 'Plie les genoux autant que nécessaire en flexion avant.', 'Pose les genoux au sol pour la descente vers le cobra si les bras fatiguent.']::text[], 'Va à ton rythme : la fluidité compte plus que l''amplitude.', '[{"label":"2 cycles lents, genoux au sol","seconds":90},{"label":"3 cycles","seconds":120},{"label":"4 cycles, rythme fluide","seconds":150}]'::jsonb, array['ischios', 'epaules', 'lombaires']::text[], array['aucun']::text[], 2, 'salutation', 'yoga', 2, false, 'The Yoga Institute, Surya Namaskar step by step (https://theyogainstitute.org/surya-namaskar-the-sun-salutation/)', array['ischio_jambiers', 'deltoides_anterieurs', 'lombaires']::text[], array['pectoraux', 'triceps', 'flechisseurs_hanche']::text[], array['corps_entier']::text[], array['mobilite', 'cardio']::text[], 'yoga', false, 'time', 90, 3.5, '02180', '{"steps":["Debout, mains jointes devant la poitrine. Inspire en levant les bras.","Expire en te penchant en avant, mains vers le sol, genoux fléchis.","Inspire en allongeant le dos à mi-hauteur, puis recule les pieds en planche.","Pose les genoux, descends la poitrine, puis glisse en cobra en inspirant.","Expire en chien tête en bas, respire 3 fois, puis ramène les pieds vers les mains et déroule-toi."],"breathing":"Inspire quand le corps s''ouvre, expire quand il se plie.","mistakes":["Bloquer sa respiration.","Laisser le bas du dos s''effondrer en cobra."]}'::jsonb),
('chien_tete_bas', 'Chien tête en bas', 'etirement', null, null, array['À quatre pattes, orteils retournés.', 'Pousse le sol avec les mains et monte les fesses vers le plafond.', 'Dos long en priorité, genoux fléchis si besoin, talons vers le sol sans forcer.']::text[], 'Un dos long compte plus que des jambes tendues.', '[{"label":"Genoux bien fléchis","seconds":20},{"label":"30 s","seconds":30},{"label":"45 s, talons vers le sol","seconds":45}]'::jsonb, array['ischios', 'mollets', 'epaules']::text[], array['aucun']::text[], 2, 'yoga-inversion', 'yoga', 2, false, 'Yoga Journal, Downward-Facing Dog (https://www.yogajournal.com/poses/downward-facing-dog/)', array['ischio_jambiers', 'mollets', 'deltoides_anterieurs']::text[], array['grand_dorsal', 'triceps']::text[], array['corps_entier', 'jambes', 'epaules']::text[], array['mobilite', 'renforcer']::text[], 'yoga', false, 'time', 30, 2.3, '02150', '{"steps":["À quatre pattes, orteils retournés.","Pousse le sol avec les mains et monte les fesses vers le plafond.","Dos long en priorité, genoux fléchis si besoin, talons vers le sol sans forcer."],"breathing":"Respire lentement par le nez.","mistakes":["Dos arrondi pour tendre les jambes.","Épaules collées aux oreilles."]}'::jsonb),
('cobra', 'Cobra', 'etirement', null, null, array['À plat ventre, mains sous les épaules, coudes près du corps.', 'Pousse doucement dans les mains pour décoller la poitrine.', 'Épaules basses, regard vers l''avant, bassin au sol.']::text[], 'Monte seulement jusqu''où le bas du dos reste confortable.', '[{"label":"Petite hauteur","seconds":15},{"label":"20 s","seconds":20},{"label":"30 s","seconds":30}]'::jsonb, array['lombaires', 'abdos']::text[], array['aucun']::text[], 1, 'yoga-extension', 'yoga', 2, false, 'Yoga Journal, Cobra Pose (https://www.yogajournal.com/poses/types/cobra-pose-2/)', array['lombaires', 'grand_droit']::text[], array['pectoraux', 'flechisseurs_hanche']::text[], array['dos', 'abdos']::text[], array['mobilite']::text[], 'yoga', false, 'time', 20, 2.3, '02150', '{"steps":["À plat ventre, mains sous les épaules, coudes près du corps.","Pousse doucement dans les mains pour décoller la poitrine.","Épaules basses, regard vers l''avant, bassin au sol."],"breathing":"Inspire en montant, puis respire calmement.","mistakes":["Tendre les bras à fond.","Hausser les épaules."]}'::jsonb),
('sphinx', 'Sphinx', 'etirement', null, null, array['À plat ventre, avant-bras au sol, coudes sous les épaules.', 'Laisse la poitrine s''ouvrir, nuque longue.', 'Relâche les fessiers et les jambes.']::text[], 'Version plus douce du cobra.', '[{"label":"30 s","seconds":30},{"label":"45 s","seconds":45},{"label":"1 min","seconds":60}]'::jsonb, array['lombaires']::text[], array['aucun']::text[], 1, 'yoga-extension', 'yoga', 2, false, 'Yoga Journal, Sphinx Pose (https://www.yogajournal.com/poses/sphinx-pose/)', array['lombaires']::text[], array['grand_droit', 'pectoraux']::text[], array['dos']::text[], array['mobilite', 'detente']::text[], 'yoga', false, 'time', 45, 2.3, '02150', '{"steps":["À plat ventre, avant-bras au sol, coudes sous les épaules.","Laisse la poitrine s''ouvrir, nuque longue.","Relâche les fessiers et les jambes."],"breathing":"Respire lentement dans le ventre.","mistakes":["S''affaisser entre les épaules.","Serrer fort les fessiers."]}'::jsonb),
('guerrier_1', 'Guerrier I', 'mobilite', null, null, array['Grand pas en arrière, pied arrière tourné vers l''extérieur, talon au sol.', 'Plie le genou avant au-dessus de la cheville, bassin face à l''avant.', 'Lève les bras au-dessus de la tête. Change de côté à mi-temps.']::text[], 'Raccourcis le pas si le talon arrière décolle.', '[{"label":"20 s par côté","seconds":40},{"label":"30 s par côté","seconds":60}]'::jsonb, array['cuisses', 'fessiers']::text[], array['aucun']::text[], 2, 'yoga-debout', 'yoga', 2, false, 'Yoga Journal, Warrior I Pose (https://www.yogajournal.com/pose/poses/warrior-i-pose/)', array['quadriceps', 'grand_fessier']::text[], array['flechisseurs_hanche', 'deltoides_anterieurs']::text[], array['jambes', 'fessiers']::text[], array['renforcer', 'mobilite']::text[], 'yoga', false, 'time', 40, 2.3, '02150', '{"steps":["Grand pas en arrière, pied arrière tourné vers l''extérieur, talon au sol.","Plie le genou avant au-dessus de la cheville, bassin face à l''avant.","Lève les bras au-dessus de la tête. Change de côté à mi-temps."],"breathing":"Respire profondément par le nez.","mistakes":["Genou avant qui dépasse la cheville.","Cambrer le dos."]}'::jsonb),
('guerrier_2', 'Guerrier II', 'mobilite', null, null, array['Jambes très écartées, pied avant tourné vers l''avant, pied arrière parallèle au tapis.', 'Plie le genou avant au-dessus de la cheville.', 'Bras ouverts à l''horizontale, regard au-dessus de la main avant. Change de côté à mi-temps.']::text[], 'Le genou avant pointe vers le petit orteil.', '[{"label":"20 s par côté","seconds":40},{"label":"30 s par côté","seconds":60}]'::jsonb, array['cuisses']::text[], array['aucun']::text[], 2, 'yoga-debout', 'yoga', 2, false, 'Yoga Journal, Warrior II Pose (https://www.yogajournal.com/poses/warrior-ii-pose/)', array['quadriceps', 'adducteurs']::text[], array['grand_fessier', 'deltoides_lateraux']::text[], array['jambes', 'fessiers']::text[], array['renforcer', 'mobilite']::text[], 'yoga', false, 'time', 40, 2.3, '02150', '{"steps":["Jambes très écartées, pied avant tourné vers l''avant, pied arrière parallèle au tapis.","Plie le genou avant au-dessus de la cheville.","Bras ouverts à l''horizontale, regard au-dessus de la main avant. Change de côté à mi-temps."],"breathing":"Respire profondément et régulièrement.","mistakes":["Buste penché vers l''avant.","Genou qui rentre vers l''intérieur."]}'::jsonb),
('triangle', 'Triangle', 'mobilite', null, null, array['Jambes écartées, pied avant tourné vers l''avant, jambes tendues.', 'Allonge le buste au-dessus de la jambe avant, puis pose la main sur le tibia.', 'Ouvre l''autre bras vers le plafond. Change de côté à mi-temps.']::text[], 'Garde les deux côtés du buste longs plutôt que de descendre la main plus bas.', '[{"label":"Main sur le tibia, 20 s par côté","seconds":40},{"label":"30 s par côté","seconds":60}]'::jsonb, array['ischios', 'obliques', 'cuisses']::text[], array['aucun']::text[], 2, 'yoga-debout', 'yoga', 2, false, 'Yoga Journal, Extended Triangle Pose (https://www.yogajournal.com/poses/extended-triangle-pose/)', array['ischio_jambiers', 'obliques', 'adducteurs']::text[], array['quadriceps']::text[], array['jambes', 'abdos']::text[], array['mobilite']::text[], 'yoga', false, 'time', 40, 2.3, '02150', '{"steps":["Jambes écartées, pied avant tourné vers l''avant, jambes tendues.","Allonge le buste au-dessus de la jambe avant, puis pose la main sur le tibia.","Ouvre l''autre bras vers le plafond. Change de côté à mi-temps."],"breathing":"Respire dans les côtes ouvertes.","mistakes":["Arrondir le côté du buste.","Verrouiller le genou avant."]}'::jsonb),
('arbre', 'Arbre', 'mobilite', null, null, array['Debout sur une jambe, pose la plante du pied libre contre la cheville, le mollet ou la cuisse.', 'Mains jointes devant la poitrine, regard fixé sur un point.', 'Change de jambe à mi-temps.']::text[], 'Jamais le pied contre le genou. Une main au mur au début, si besoin.', '[{"label":"Pied contre la cheville, 20 s par côté","seconds":40},{"label":"Pied contre le mollet ou la cuisse","seconds":40},{"label":"30 s par côté, bras levés","seconds":60}]'::jsonb, array['hanches', 'mollets']::text[], array['aucun']::text[], 1, 'yoga-equilibre', 'yoga', 2, false, 'Yoga Journal, Tree Pose (https://www.yogajournal.com/poses/types/tree-pose-2/)', array['moyen_fessier', 'mollets']::text[], array['transverse', 'adducteurs']::text[], array['jambes', 'fessiers']::text[], array['renforcer', 'detente']::text[], 'yoga', false, 'time', 40, 2.3, '02150', '{"steps":["Debout sur une jambe, pose la plante du pied libre contre la cheville, le mollet ou la cuisse.","Mains jointes devant la poitrine, regard fixé sur un point.","Change de jambe à mi-temps."],"breathing":"Respiration calme et lente.","mistakes":["Pied appuyé sur le genou.","Hanche qui sort sur le côté."]}'::jsonb),
('chaise_yoga', 'Posture de la chaise', 'mobilite', null, null, array['Pieds joints, plie les genoux comme pour t''asseoir.', 'Lève les bras dans le prolongement du buste.', 'Poids sur les talons, genoux derrière les orteils.']::text[], 'Bras devant toi si les épaules sont raides.', '[{"label":"20 s","seconds":20},{"label":"30 s","seconds":30},{"label":"45 s","seconds":45}]'::jsonb, array['cuisses', 'fessiers']::text[], array['aucun']::text[], 2, 'yoga-debout', 'yoga', 2, false, 'Yoga Journal, Chair Pose (https://www.yogajournal.com/poses/chair-pose-2/)', array['quadriceps', 'grand_fessier']::text[], array['deltoides_anterieurs', 'lombaires']::text[], array['jambes', 'fessiers']::text[], array['renforcer']::text[], 'yoga', false, 'time', 30, 2.3, '02150', '{"steps":["Pieds joints, plie les genoux comme pour t''asseoir.","Lève les bras dans le prolongement du buste.","Poids sur les talons, genoux derrière les orteils."],"breathing":"Respire profondément pendant le maintien.","mistakes":["Cambrer le bas du dos.","Genoux qui dépassent largement les orteils."]}'::jsonb),
('fente_basse', 'Fente basse (posture du croissant)', 'etirement', null, null, array['Genou arrière posé au sol, pied avant devant toi.', 'Avance doucement le bassin vers l''avant.', 'Lève les bras si l''équilibre le permet. Change de côté à mi-temps.']::text[], 'Une serviette pliée sous le genou arrière rend la posture plus confortable.', '[{"label":"Mains sur la cuisse, 30 s par côté","seconds":60},{"label":"Bras levés, 30 s par côté","seconds":60},{"label":"45 s par côté","seconds":90}]'::jsonb, array['hanches', 'cuisses']::text[], array['aucun']::text[], 1, 'yoga-fente', 'yoga', 1, false, 'Yoga Journal, Low Lunge (https://www.yogajournal.com/poses/low-lunge/)', array['flechisseurs_hanche', 'quadriceps']::text[], array['grand_fessier', 'deltoides_anterieurs']::text[], array['jambes', 'fessiers']::text[], array['mobilite']::text[], 'yoga', false, 'time', 60, 2.3, '02150', '{"steps":["Genou arrière posé au sol, pied avant devant toi.","Avance doucement le bassin vers l''avant.","Lève les bras si l''équilibre le permet. Change de côté à mi-temps."],"breathing":"Respire lentement, relâche à chaque expiration.","mistakes":["Cambrer le bas du dos.","Genou avant qui dépasse la cheville."]}'::jsonb),
('pigeon', 'Pigeon (version au sol)', 'etirement', null, null, array['À quatre pattes, avance un genou derrière le poignet du même côté.', 'Allonge l''autre jambe vers l''arrière, bassin le plus droit possible.', 'Reste buste droit ou allonge-le vers l''avant. Change de côté à mi-temps.']::text[], 'Si le genou plié se plaint, fais plutôt l''étirement des fessiers en « 4 » sur le dos.', '[{"label":"Buste redressé, 30 s par côté","seconds":60},{"label":"Buste allongé vers l''avant","seconds":60},{"label":"45 s par côté","seconds":90}]'::jsonb, array['fessiers', 'hanches']::text[], array['aucun']::text[], 2, 'yoga-hanches', 'yoga', 1, false, 'Yoga Journal, Sleeping Pigeon Pose (https://www.yogajournal.com/article/yogapedia/master-sleeping-pigeon-pose-4-steps/)', array['grand_fessier', 'moyen_fessier']::text[], array['flechisseurs_hanche']::text[], array['fessiers']::text[], array['mobilite', 'detente']::text[], 'yoga', false, 'time', 60, 2.3, '02150', '{"steps":["À quatre pattes, avance un genou derrière le poignet du même côté.","Allonge l''autre jambe vers l''arrière, bassin le plus droit possible.","Reste buste droit ou allonge-le vers l''avant. Change de côté à mi-temps."],"breathing":"Respire lentement dans la hanche étirée.","mistakes":["Bassin qui bascule sur le côté.","Forcer sur le genou."]}'::jsonb),
('papillon', 'Papillon', 'etirement', null, null, array['Assis, plantes des pieds l''une contre l''autre, genoux ouverts.', 'Tiens tes pieds et grandis-toi.', 'Laisse les genoux descendre d''eux-mêmes, sans appuyer dessus.']::text[], 'Assieds-toi sur un coussin si le dos s''arrondit.', '[{"label":"30 s","seconds":30},{"label":"45 s","seconds":45},{"label":"1 min, buste incliné","seconds":60}]'::jsonb, array['cuisses']::text[], array['aucun']::text[], 1, 'yoga-hanches', 'yoga', 1, false, 'Yoga Journal, Bound Angle Pose (https://www.yogajournal.com/poses/bound-angle-pose-2/)', array['adducteurs']::text[], array['lombaires']::text[], array['jambes', 'fessiers']::text[], array['mobilite', 'detente']::text[], 'yoga', false, 'time', 45, 2.3, '02150', '{"steps":["Assis, plantes des pieds l''une contre l''autre, genoux ouverts.","Tiens tes pieds et grandis-toi.","Laisse les genoux descendre d''eux-mêmes, sans appuyer dessus."],"breathing":"Respire lentement, relâche à chaque expiration.","mistakes":["Appuyer sur les genoux.","Dos arrondi."]}'::jsonb),
('pince_assise', 'Pince assise', 'etirement', null, null, array['Assis, jambes tendues devant toi, genoux légèrement fléchis.', 'Grandis-toi, puis penche le buste vers l''avant depuis les hanches.', 'Pose les mains où elles arrivent, sans tirer.']::text[], 'L''objectif est l''étirement, pas de toucher les pieds.', '[{"label":"Genoux fléchis","seconds":30},{"label":"45 s","seconds":45},{"label":"1 min","seconds":60}]'::jsonb, array['ischios']::text[], array['aucun']::text[], 1, 'yoga-flexion', 'yoga', 1, false, 'Yoga Journal, Seated Forward Bend (https://www.yogajournal.com/poses/seated-forward-bend/)', array['ischio_jambiers']::text[], array['lombaires', 'mollets']::text[], array['jambes', 'dos']::text[], array['mobilite', 'detente']::text[], 'yoga', false, 'time', 45, 2.3, '02150', '{"steps":["Assis, jambes tendues devant toi, genoux légèrement fléchis.","Grandis-toi, puis penche le buste vers l''avant depuis les hanches.","Pose les mains où elles arrivent, sans tirer."],"breathing":"Inspire en te grandissant, expire en t''inclinant un peu plus.","mistakes":["Arrondir le dos pour aller plus loin.","Tirer sur les pieds."]}'::jsonb),
('torsion_couchee', 'Torsion allongée', 'etirement', null, null, array['Allongé sur le dos, bras ouverts en croix.', 'Ramène les genoux pliés vers la poitrine, puis laisse-les tomber d''un côté.', 'Tourne la tête de l''autre côté. Change de côté à mi-temps.']::text[], 'Glisse un coussin sous les genoux s''ils ne touchent pas le sol.', '[{"label":"30 s par côté","seconds":60},{"label":"45 s par côté","seconds":90}]'::jsonb, array['obliques', 'lombaires']::text[], array['aucun']::text[], 1, 'yoga-torsion', 'yoga', 1, false, 'Yogamatters, bibliothèque de postures : Supine Twist (https://www.yogamatters.com/blogs/pose-library/supine-twist-supta-matsyendrasana)', array['obliques', 'lombaires']::text[], array['grand_fessier', 'pectoraux']::text[], array['dos', 'fessiers']::text[], array['mobilite', 'detente']::text[], 'yoga', false, 'time', 60, 2.3, '02150', '{"steps":["Allongé sur le dos, bras ouverts en croix.","Ramène les genoux pliés vers la poitrine, puis laisse-les tomber d''un côté.","Tourne la tête de l''autre côté. Change de côté à mi-temps."],"breathing":"Respire lentement dans le ventre.","mistakes":["Décoller l''épaule opposée.","Forcer la rotation."]}'::jsonb),
('bebe_heureux', 'Bébé heureux', 'etirement', null, null, array['Allongé sur le dos, ramène les genoux vers les aisselles.', 'Attrape les pieds par l''extérieur, plantes vers le plafond.', 'Laisse le bas du dos se poser au sol.']::text[], 'Tiens tes genoux ou l''arrière des cuisses si tu n''atteins pas les pieds.', '[{"label":"Mains sur les genoux","seconds":30},{"label":"Mains sur les pieds","seconds":45},{"label":"1 min, léger balancement","seconds":60}]'::jsonb, array['cuisses', 'fessiers']::text[], array['aucun']::text[], 1, 'yoga-hanches', 'yoga', 1, false, 'Yogamatters, bibliothèque de postures : Happy Baby Pose (https://www.yogamatters.com/blogs/pose-library/happy-baby-pose-ananda-balasana)', array['adducteurs', 'grand_fessier']::text[], array['ischio_jambiers', 'lombaires']::text[], array['fessiers', 'dos']::text[], array['mobilite', 'detente']::text[], 'yoga', false, 'time', 45, 2.3, '02150', '{"steps":["Allongé sur le dos, ramène les genoux vers les aisselles.","Attrape les pieds par l''extérieur, plantes vers le plafond.","Laisse le bas du dos se poser au sol."],"breathing":"Respire lentement.","mistakes":["Décoller la tête du sol.","Tirer fort sur les pieds."]}'::jsonb),
('jambes_au_mur', 'Jambes contre le mur', 'etirement', null, null, array['Assieds-toi de côté contre un mur, puis bascule pour allonger les jambes contre le mur.', 'Fesses proches du mur, bras relâchés.', 'Ferme les yeux et laisse les jambes se détendre.']::text[], 'Éloigne un peu les fesses du mur si l''arrière des cuisses tire trop.', '[{"label":"2 min","seconds":120},{"label":"3 min","seconds":180},{"label":"5 min","seconds":300}]'::jsonb, array['ischios']::text[], array['mur']::text[], 1, 'yoga-repos', 'yoga', 1, false, 'Yoga Journal, Legs Up the Wall Pose (https://www.yogajournal.com/poses/legs-up-the-wall-pose-2/)', array['ischio_jambiers']::text[], array['mollets', 'lombaires']::text[], array['jambes']::text[], array['detente']::text[], 'yoga', false, 'time', 120, 2.3, '02150', '{"steps":["Assieds-toi de côté contre un mur, puis bascule pour allonger les jambes contre le mur.","Fesses proches du mur, bras relâchés.","Ferme les yeux et laisse les jambes se détendre."],"breathing":"Respiration lente et longue.","mistakes":["Garder les jambes contractées.","Se placer trop loin du mur."]}'::jsonb),
('quadriceps_debout', 'Étirement des quadriceps debout', 'etirement', null, null, array['Debout, une main au mur.', 'Attrape ta cheville et ramène le talon vers la fesse.', 'Genoux côte à côte, bassin légèrement rentré. Change de côté.']::text[], 'Utilise une serviette autour de la cheville si tu ne l''attrapes pas.', '[{"label":"20 s par côté","seconds":40},{"label":"30 s par côté","seconds":60}]'::jsonb, array['cuisses']::text[], array['mur']::text[], 1, 'etirement-quadriceps', 'etirement', 1, false, 'free-exercise-db (domaine public), fiche Quad Stretch (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Quad_Stretch.json) ; NHS, Flexibility exercises (https://www.nhs.uk/live-well/exercise/strength-and-flexibility-exercises/flexibility-exercises/)', array['quadriceps']::text[], array['flechisseurs_hanche']::text[], array['jambes']::text[], array['mobilite']::text[], 'etirement', false, 'time', 60, 2.3, '02101', '{"steps":["Debout, une main au mur.","Attrape ta cheville et ramène le talon vers la fesse.","Genoux côte à côte, bassin légèrement rentré. Change de côté."],"breathing":"Respire lentement pendant le maintien.","mistakes":["Genou qui part vers l''avant ou sur le côté.","Cambrer le dos."]}'::jsonb),
('etirement_lateral', 'Étirement latéral debout', 'etirement', null, null, array['Debout, pieds largeur de hanches.', 'Lève un bras au-dessus de la tête et penche-toi doucement de l''autre côté.', 'Reviens au centre et change de côté.']::text[], 'Penche-toi sur le côté, pas vers l''avant.', '[{"label":"15 s par côté","seconds":30},{"label":"20 s par côté","seconds":40}]'::jsonb, array['obliques', 'dos']::text[], array['aucun']::text[], 1, 'etirement-lateral', 'etirement', 1, false, 'free-exercise-db (domaine public), fiche Standing Lateral Stretch (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Standing_Lateral_Stretch.json)', array['obliques', 'grand_dorsal']::text[], '{}'::text[], array['dos', 'abdos']::text[], array['mobilite']::text[], 'etirement', false, 'time', 40, 2.3, '02101', '{"steps":["Debout, pieds largeur de hanches.","Lève un bras au-dessus de la tête et penche-toi doucement de l''autre côté.","Reviens au centre et change de côté."],"breathing":"Inspire en levant le bras, expire en t''inclinant.","mistakes":["Tourner le buste.","Hausser l''épaule."]}'::jsonb),
('epaule_bras_croise', 'Étirement de l''épaule, bras croisé', 'etirement', null, null, array['Amène un bras tendu devant la poitrine.', 'Avec l''autre main, rapproche-le doucement du corps, au-dessus du coude.', 'Épaules basses. Change de côté.']::text[], 'Appuie au-dessus du coude, jamais dessus.', '[{"label":"20 s par côté","seconds":40},{"label":"30 s par côté","seconds":60}]'::jsonb, array['epaules']::text[], array['aucun']::text[], 1, 'etirement-epaule', 'etirement', 1, false, 'free-exercise-db (domaine public), fiche Shoulder Stretch (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Shoulder_Stretch.json)', array['deltoides_posterieurs']::text[], array['rhomboides']::text[], array['epaules']::text[], array['mobilite']::text[], 'etirement', false, 'time', 40, 2.3, '02101', '{"steps":["Amène un bras tendu devant la poitrine.","Avec l''autre main, rapproche-le doucement du corps, au-dessus du coude.","Épaules basses. Change de côté."],"breathing":"Respire calmement.","mistakes":["Hausser l''épaule étirée.","Tourner le buste."]}'::jsonb),
('triceps_etirement', 'Étirement des triceps', 'etirement', null, null, array['Lève un bras et plie le coude pour poser la main entre les omoplates.', 'Avec l''autre main, pousse doucement le coude vers l''arrière.', 'Change de côté.']::text[], 'Reste dans une amplitude confortable pour l''épaule.', '[{"label":"20 s par côté","seconds":40},{"label":"30 s par côté","seconds":60}]'::jsonb, array['bras']::text[], array['aucun']::text[], 1, 'etirement-bras', 'etirement', 1, false, 'free-exercise-db (domaine public), fiche Triceps Stretch (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Triceps_Stretch.json)', array['triceps']::text[], array['grand_dorsal']::text[], array['bras']::text[], array['mobilite']::text[], 'etirement', false, 'time', 40, 2.3, '02101', '{"steps":["Lève un bras et plie le coude pour poser la main entre les omoplates.","Avec l''autre main, pousse doucement le coude vers l''arrière.","Change de côté."],"breathing":"Respire calmement.","mistakes":["Cambrer le dos.","Pencher la tête vers l''avant."]}'::jsonb),
('torsion_assise', 'Torsion assise', 'etirement', null, null, array['Assis, une jambe tendue, l''autre pied posé à l''extérieur du genou.', 'Grandis-toi, puis tourne le buste vers le genou plié.', 'Coude contre le genou, regard derrière toi. Change de côté.']::text[], 'Grandis-toi à chaque inspiration, tourne un peu à chaque expiration.', '[{"label":"20 s par côté","seconds":40},{"label":"30 s par côté","seconds":60}]'::jsonb, array['obliques', 'lombaires']::text[], array['aucun']::text[], 1, 'yoga-torsion', 'etirement', 1, false, 'free-exercise-db (domaine public), fiche Spinal Stretch (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Spinal_Stretch.json)', array['obliques', 'lombaires']::text[], array['grand_fessier']::text[], array['dos']::text[], array['mobilite']::text[], 'etirement', false, 'time', 40, 2.3, '02101', '{"steps":["Assis, une jambe tendue, l''autre pied posé à l''extérieur du genou.","Grandis-toi, puis tourne le buste vers le genou plié.","Coude contre le genou, regard derrière toi. Change de côté."],"breathing":"Inspire en te grandissant, expire en tournant.","mistakes":["Dos arrondi.","Forcer avec le bras."]}'::jsonb),
('genoux_poitrine', 'Genoux à la poitrine', 'etirement', null, null, array['Allongé sur le dos.', 'Ramène les genoux vers la poitrine, mains sous les genoux.', 'Balance-toi doucement de gauche à droite si c''est agréable.']::text[], null, '[{"label":"Une jambe à la fois","seconds":40},{"label":"Deux jambes, léger balancement","seconds":40}]'::jsonb, array['lombaires']::text[], array['aucun']::text[], 1, 'etirement-dos', 'etirement', 1, false, 'free-exercise-db (domaine public), fiche Hug Knees To Chest (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Hug_Knees_To_Chest.json) ; NHS, Flexibility exercises (https://www.nhs.uk/live-well/exercise/strength-and-flexibility-exercises/flexibility-exercises/)', array['lombaires']::text[], array['grand_fessier']::text[], array['dos']::text[], array['mobilite', 'detente']::text[], 'etirement', false, 'time', 40, 2.3, '02101', '{"steps":["Allongé sur le dos.","Ramène les genoux vers la poitrine, mains sous les genoux.","Balance-toi doucement de gauche à droite si c''est agréable."],"breathing":"Respire lentement dans le ventre.","mistakes":["Décoller la tête.","Tirer fort sur les genoux."]}'::jsonb),
('coherence_cardiaque', 'Respiration lente (6 cycles par minute)', 'respiration', null, null, array['Assis, dos droit, pieds au sol.', 'Inspire par le nez pendant 5 secondes, puis expire pendant 5 secondes.', 'Garde ce rythme régulier jusqu''à la fin, sans forcer.']::text[], 'Si tu te sens étourdi, reprends une respiration normale.', '[{"label":"3 min","seconds":180},{"label":"5 min","seconds":300}]'::jsonb, array['respiration']::text[], array['aucun']::text[], 1, 'respiration', 'respiration', 1, false, 'Respiration lente autour de 6 cycles par minute, revue systématique (Université de Berne) (https://boris.unibe.ch/193198)', array['diaphragme']::text[], '{}'::text[], '{}'::text[], array['detente']::text[], 'meditation', false, 'time', 180, 1.0, '07075', '{"steps":["Assis, dos droit, pieds au sol.","Inspire par le nez pendant 5 secondes, puis expire pendant 5 secondes.","Garde ce rythme régulier jusqu''à la fin, sans forcer."],"breathing":"5 s d''inspiration, 5 s d''expiration : 6 cycles par minute.","mistakes":["Gonfler la poitrine plutôt que le ventre.","Forcer l''inspiration."]}'::jsonb),
('respiration_carree', 'Respiration carrée', 'respiration', null, null, array['Assis confortablement, expire complètement.', 'Inspire 4 s, retiens 4 s, expire 4 s, retiens 4 s.', 'Recommence en imaginant les quatre côtés d''un carré.']::text[], 'Raccourcis les temps (3 s) si les pauses sont inconfortables.', '[{"label":"2 min, carré de 3 s","seconds":120},{"label":"3 min, carré de 4 s","seconds":180}]'::jsonb, array['respiration']::text[], array['aucun']::text[], 1, 'respiration', 'respiration', 1, false, 'University of Pittsburgh, Box Breathing (https://sova.pitt.edu/box-breathing)', array['diaphragme']::text[], '{}'::text[], '{}'::text[], array['detente']::text[], 'meditation', false, 'time', 120, 1.0, '07075', '{"steps":["Assis confortablement, expire complètement.","Inspire 4 s, retiens 4 s, expire 4 s, retiens 4 s.","Recommence en imaginant les quatre côtés d''un carré."],"breathing":"Quatre temps égaux : inspire, pause, expire, pause.","mistakes":["Contracter les épaules pendant les pauses.","Accélérer le compte."]}'::jsonb),
('meditation_souffle', 'Méditation : attention au souffle', 'respiration', null, null, array['Assis, dos droit sans raideur, yeux fermés ou regard posé au sol.', 'Porte ton attention sur les sensations du souffle, au niveau des narines ou du ventre.', 'Quand ton esprit s''égare, remarque-le simplement et reviens au souffle.']::text[], null, '[{"label":"3 min","seconds":180},{"label":"5 min","seconds":300},{"label":"10 min","seconds":600}]'::jsonb, '{}'::text[], array['aucun']::text[], 1, 'meditation', 'meditation', 1, false, 'UCLA Mindful, méditations guidées gratuites (https://www.uclahealth.org/uclamindful/guided-meditations) ; NHS Torbay and South Devon, Mindfulness of breath (https://www.torbayandsouthdevon.nhs.uk/uploads/mindfulness-of-breath-instructions.pdf)', '{}'::text[], '{}'::text[], '{}'::text[], array['detente']::text[], 'meditation', false, 'time', 300, 1.0, '07075', '{"steps":["Assis, dos droit sans raideur, yeux fermés ou regard posé au sol.","Porte ton attention sur les sensations du souffle, au niveau des narines ou du ventre.","Quand ton esprit s''égare, remarque-le simplement et reviens au souffle."],"breathing":"Respire naturellement, sans chercher à modifier le rythme.","mistakes":["Se reprocher d''avoir des pensées : c''est normal.","Contrôler la respiration."]}'::jsonb),
('scan_corporel', 'Méditation : scan corporel', 'respiration', null, null, array['Allongé sur le dos, bras le long du corps, yeux fermés.', 'Promène ton attention des orteils jusqu''au sommet du crâne, zone par zone.', 'Observe chaque sensation sans la juger, puis passe à la zone suivante.']::text[], 'Idéal le soir : si tu t''endors, c''est que ton corps en avait besoin.', '[{"label":"5 min","seconds":300},{"label":"7 min","seconds":420},{"label":"10 min","seconds":600}]'::jsonb, '{}'::text[], array['aucun']::text[], 1, 'meditation', 'meditation', 1, false, 'Greater Good in Action (UC Berkeley), Body Scan Meditation (https://ggia.berkeley.edu/practice/body_scan_meditation) ; UCLA Mindful, méditations guidées gratuites (https://www.uclahealth.org/uclamindful/guided-meditations)', '{}'::text[], '{}'::text[], '{}'::text[], array['detente']::text[], 'meditation', false, 'time', 420, 1.0, '07075', '{"steps":["Allongé sur le dos, bras le long du corps, yeux fermés.","Promène ton attention des orteils jusqu''au sommet du crâne, zone par zone.","Observe chaque sensation sans la juger, puis passe à la zone suivante."],"breathing":"Respire naturellement, en imaginant le souffle circuler jusqu''à la zone observée.","mistakes":["Vouloir détendre de force.","Aller trop vite d''une zone à l''autre."]}'::jsonb),
('relaxation_progressive', 'Relaxation musculaire progressive', 'respiration', null, null, array['Allongé ou assis, yeux fermés.', 'Contracte un groupe de muscles 5 secondes (pieds, jambes, ventre, mains, épaules, visage), puis relâche d''un coup.', 'Observe la détente 10 à 15 secondes avant de passer au groupe suivant.']::text[], 'Contracte modérément, jamais jusqu''à la crampe ou la douleur.', '[{"label":"5 min, grandes zones","seconds":300},{"label":"7 min","seconds":420},{"label":"10 min, zone par zone","seconds":600}]'::jsonb, '{}'::text[], array['aucun']::text[], 1, 'meditation', 'relaxation', 1, false, 'University of Rochester, Progressive Muscle Relaxation (https://www.rochester.edu/uhs/ucc/online-screening-resources/progressive-muscle-relaxation)', '{}'::text[], '{}'::text[], '{}'::text[], array['detente']::text[], 'meditation', false, 'time', 420, 1.0, '07075', '{"steps":["Allongé ou assis, yeux fermés.","Contracte un groupe de muscles 5 secondes (pieds, jambes, ventre, mains, épaules, visage), puis relâche d''un coup.","Observe la détente 10 à 15 secondes avant de passer au groupe suivant."],"breathing":"Inspire en contractant, expire en relâchant.","mistakes":["Contracter trop fort.","Enchaîner sans observer la détente."]}'::jsonb)
on conflict (id) do update set
  name = excluded.name,
  kind = excluded.kind,
  video_url = excluded.video_url,
  cues = excluded.cues,
  caution = excluded.caution,
  levels = excluded.levels,
  zones = excluded.zones,
  equipment = excluded.equipment,
  intensity = excluded.intensity,
  family = excluded.family,
  pattern = excluded.pattern,
  max_sets = excluded.max_sets,
  source = excluded.source,
  muscles_primary = excluded.muscles_primary,
  muscles_secondary = excluded.muscles_secondary,
  areas = excluded.areas,
  goals = excluded.goals,
  discipline = excluded.discipline,
  impact = excluded.impact,
  mode = excluded.mode,
  default_value = excluded.default_value,
  met = excluded.met,
  met_code = excluded.met_code,
  tutorial = excluded.tutorial
where public.exercises.approved = false;

-- ---------------------------------------------------------------- 2. Étiquettes sourcées des 43 exercices existants
update public.exercises set
  muscles_primary = array['rhomboides', 'grand_dorsal']::text[], muscles_secondary = array['biceps', 'deltoides_posterieurs', 'trapezes']::text[],
  areas = array['dos', 'bras']::text[], goals = array['renforcer', 'tonifier']::text[], discipline = 'renforcement', impact = false,
  equipment = array['elastique']::text[], mode = 'reps', default_value = 12,
  met = 3.5, met_code = '02054',
  tutorial = jsonb_build_object('steps', to_jsonb(cues), 'breathing', 'Expire en tirant, inspire en relâchant.', 'mistakes', '["Se pencher en arrière pour tirer.","Hausser les épaules vers les oreilles."]'::jsonb),
  video_url = coalesce(video_url, null),
  source = case when coalesce(source, '') like '%https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Seated_Cable_Rows.json%' then source else concat_ws(' ; ', source, 'free-exercise-db (domaine public), fiche Seated Cable Rows (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Seated_Cable_Rows.json)') end
where id = 'rowing';
update public.exercises set
  muscles_primary = array['deltoides_posterieurs', 'rhomboides']::text[], muscles_secondary = array['trapezes', 'coiffe_rotateurs']::text[],
  areas = array['dos', 'epaules']::text[], goals = array['renforcer', 'tonifier']::text[], discipline = 'renforcement', impact = false,
  equipment = array['elastique']::text[], mode = 'reps', default_value = 15,
  met = 3.5, met_code = '02054',
  tutorial = jsonb_build_object('steps', to_jsonb(cues), 'breathing', 'Expire en écartant, inspire en revenant.', 'mistakes', '["Plier les coudes pour s''aider.","Cambrer le bas du dos en fin de mouvement."]'::jsonb),
  video_url = coalesce(video_url, null),
  source = case when coalesce(source, '') like '%https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Band_Pull_Apart.json%' then source else concat_ws(' ; ', source, 'free-exercise-db (domaine public), fiche Band Pull Apart (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Band_Pull_Apart.json)') end
where id = 'pull_apart';
update public.exercises set
  muscles_primary = array['obliques', 'transverse']::text[], muscles_secondary = array['grand_droit', 'moyen_fessier']::text[],
  areas = array['abdos']::text[], goals = array['renforcer']::text[], discipline = 'gainage', impact = false,
  equipment = array['elastique']::text[], mode = 'time', default_value = 40,
  met = 2.8, met_code = '02024',
  tutorial = jsonb_build_object('steps', to_jsonb(cues), 'breathing', 'Respire calmement pendant que les bras sont tendus, sans bloquer.', 'mistakes', '["Laisser le buste tourner vers l''élastique.","Se placer trop près du point d''attache : il n''y a plus de tension."]'::jsonb),
  video_url = coalesce(video_url, null),
  source = case when coalesce(source, '') like '%https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Pallof_Press.json%' then source else concat_ws(' ; ', source, 'free-exercise-db (domaine public), fiche Pallof Press (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Pallof_Press.json)') end
where id = 'pallof';
update public.exercises set
  muscles_primary = array['transverse', 'grand_droit']::text[], muscles_secondary = array['obliques', 'flechisseurs_hanche']::text[],
  areas = array['abdos']::text[], goals = array['renforcer']::text[], discipline = 'gainage', impact = false,
  equipment = array['aucun']::text[], mode = 'reps', default_value = 10,
  met = 2.8, met_code = '02024',
  tutorial = jsonb_build_object('steps', to_jsonb(cues), 'breathing', 'Expire pendant que le bras et la jambe s''éloignent, inspire en revenant.', 'mistakes', '["Laisser le bas du dos décoller du sol.","Aller trop vite et perdre le contrôle."]'::jsonb),
  video_url = coalesce(video_url, null),
  source = case when coalesce(source, '') like '%https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Dead_Bug.json%' then source else concat_ws(' ; ', source, 'free-exercise-db (domaine public), fiche Dead Bug (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Dead_Bug.json)') end
where id = 'dead_bug';
update public.exercises set
  muscles_primary = array['lombaires', 'grand_fessier']::text[], muscles_secondary = array['transverse', 'deltoides_anterieurs']::text[],
  areas = array['dos', 'abdos']::text[], goals = array['renforcer', 'mobilite']::text[], discipline = 'gainage', impact = false,
  equipment = array['aucun']::text[], mode = 'reps', default_value = 10,
  met = 2.8, met_code = '02024',
  tutorial = jsonb_build_object('steps', to_jsonb(cues), 'breathing', 'Expire en allongeant, inspire en revenant au centre.', 'mistakes', '["Lever la jambe trop haut et creuser le dos.","Laisser le bassin basculer sur le côté."]'::jsonb),
  video_url = coalesce(video_url, null),
  source = case when coalesce(source, '') like '%https://www.health.harvard.edu/staying-healthy/core-exercises-the-big-3%' then source else concat_ws(' ; ', source, 'Harvard Health Publishing, « Big 3 » de Stuart McGill (https://www.health.harvard.edu/staying-healthy/core-exercises-the-big-3)') end
where id = 'bird_dog';
update public.exercises set
  muscles_primary = array['grand_droit', 'transverse']::text[], muscles_secondary = array['deltoides_anterieurs', 'grand_fessier', 'quadriceps']::text[],
  areas = array['abdos', 'epaules']::text[], goals = array['renforcer', 'tonifier']::text[], discipline = 'gainage', impact = false,
  equipment = array['aucun']::text[], mode = 'time', default_value = 30,
  met = 2.8, met_code = '02024',
  tutorial = jsonb_build_object('steps', to_jsonb(cues), 'breathing', 'Respire lentement et régulièrement pendant tout le maintien.', 'mistakes', '["Fesses trop hautes ou bassin qui s''affaisse.","Bloquer sa respiration."]'::jsonb),
  video_url = coalesce(video_url, null),
  source = case when coalesce(source, '') like '%https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Plank.json%' then source else concat_ws(' ; ', source, 'free-exercise-db (domaine public), fiche Plank (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Plank.json) ; NHS, Strength exercises (https://www.nhs.uk/live-well/exercise/strength-and-flexibility-exercises/strength-exercises/)') end
where id = 'planche';
update public.exercises set
  muscles_primary = array['quadriceps', 'grand_fessier']::text[], muscles_secondary = array['ischio_jambiers', 'adducteurs']::text[],
  areas = array['jambes', 'fessiers']::text[], goals = array['renforcer', 'tonifier']::text[], discipline = 'renforcement', impact = false,
  equipment = array['chaise']::text[], mode = 'reps', default_value = 10,
  met = 2.8, met_code = '02340',
  tutorial = jsonb_build_object('steps', to_jsonb(cues), 'breathing', 'Inspire en descendant, expire en te relevant.', 'mistakes', '["Se laisser tomber sur la chaise.","Laisser les genoux rentrer vers l''intérieur."]'::jsonb),
  video_url = coalesce(video_url, null),
  source = case when coalesce(source, '') like '%https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Chair_Squat.json%' then source else concat_ws(' ; ', source, 'free-exercise-db (domaine public), fiche Chair Squat (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Chair_Squat.json) ; NHS, Strength exercises (https://www.nhs.uk/live-well/exercise/strength-and-flexibility-exercises/strength-exercises/)') end
where id = 'squat_chaise';
update public.exercises set
  muscles_primary = array['grand_fessier']::text[], muscles_secondary = array['ischio_jambiers', 'lombaires']::text[],
  areas = array['fessiers', 'jambes']::text[], goals = array['renforcer', 'tonifier']::text[], discipline = 'renforcement', impact = false,
  equipment = array['aucun']::text[], mode = 'reps', default_value = 12,
  met = 3.0, met_code = '02056',
  tutorial = jsonb_build_object('steps', to_jsonb(cues), 'breathing', 'Expire en montant le bassin, inspire en redescendant.', 'mistakes', '["Cambrer le dos en haut au lieu de serrer les fessiers.","Pousser sur la pointe des pieds."]'::jsonb),
  video_url = coalesce(video_url, null),
  source = case when coalesce(source, '') like '%https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Butt_Lift_Bridge.json%' then source else concat_ws(' ; ', source, 'free-exercise-db (domaine public), fiche Butt Lift Bridge (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Butt_Lift_Bridge.json)') end
where id = 'pont';
update public.exercises set
  muscles_primary = array['moyen_fessier']::text[], muscles_secondary = array['grand_fessier', 'quadriceps']::text[],
  areas = array['fessiers']::text[], goals = array['renforcer', 'tonifier']::text[], discipline = 'renforcement', impact = false,
  equipment = array['elastique']::text[], mode = 'time', default_value = 40,
  met = 3.5, met_code = '02054',
  tutorial = jsonb_build_object('steps', to_jsonb(cues), 'breathing', 'Respiration libre et régulière.', 'mistakes', '["Laisser les pieds se toucher : l''élastique se détend.","Balancer le buste d''un côté à l''autre."]'::jsonb),
  video_url = coalesce(video_url, null),
  source = case when coalesce(source, '') like '%https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Monster_Walk.json%' then source else concat_ws(' ; ', source, 'free-exercise-db (domaine public), fiche Monster Walk (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Monster_Walk.json)') end
where id = 'marche_laterale';
update public.exercises set
  muscles_primary = array['grand_fessier']::text[], muscles_secondary = array['ischio_jambiers', 'lombaires']::text[],
  areas = array['fessiers']::text[], goals = array['renforcer', 'tonifier']::text[], discipline = 'renforcement', impact = false,
  equipment = array['aucun']::text[], mode = 'reps', default_value = 12,
  met = 3.0, met_code = '02056',
  tutorial = jsonb_build_object('steps', to_jsonb(cues), 'breathing', 'Expire en poussant le talon vers le plafond, inspire en revenant.', 'mistakes', '["Monter trop haut et creuser le dos.","Tourner le bassin vers l''extérieur."]'::jsonb),
  video_url = coalesce(video_url, null),
  source = case when coalesce(source, '') like '%https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Glute_Kickback.json%' then source else concat_ws(' ; ', source, 'free-exercise-db (domaine public), fiche Glute Kickback (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Glute_Kickback.json)') end
where id = 'ext_hanche';
update public.exercises set
  muscles_primary = array['obliques']::text[], muscles_secondary = array['transverse', 'moyen_fessier', 'deltoides_lateraux']::text[],
  areas = array['abdos']::text[], goals = array['renforcer', 'tonifier']::text[], discipline = 'gainage', impact = false,
  equipment = array['aucun']::text[], mode = 'time', default_value = 30,
  met = 2.8, met_code = '02024',
  tutorial = jsonb_build_object('steps', to_jsonb(cues), 'breathing', 'Respire calmement, sans bloquer.', 'mistakes', '["Laisser le bassin descendre.","Pencher le buste vers l''avant."]'::jsonb),
  video_url = coalesce(video_url, null),
  source = case when coalesce(source, '') like '%https://www.health.harvard.edu/staying-healthy/core-exercises-the-big-3%' then source else concat_ws(' ; ', source, 'Harvard Health Publishing, « Big 3 » de Stuart McGill (https://www.health.harvard.edu/staying-healthy/core-exercises-the-big-3) ; free-exercise-db (domaine public), fiche Side Bridge (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Side_Bridge.json)') end
where id = 'planche_laterale';
update public.exercises set
  muscles_primary = array['diaphragme']::text[], muscles_secondary = array['transverse']::text[],
  areas = array['abdos']::text[], goals = array['detente']::text[], discipline = 'meditation', impact = false,
  equipment = array['aucun']::text[], mode = 'time', default_value = 60,
  met = 1.0, met_code = '07075',
  tutorial = jsonb_build_object('steps', to_jsonb(cues), 'breathing', 'Inspire 3 à 4 s par le nez, expire 5 à 6 s par la bouche.', 'mistakes', '["Monter les épaules en inspirant.","Forcer l''inspiration."]'::jsonb),
  video_url = coalesce(video_url, null),
  source = case when coalesce(source, '') like '%https://boris.unibe.ch/193198%' then source else concat_ws(' ; ', source, 'Respiration lente autour de 6 cycles par minute, revue systématique (Université de Berne) (https://boris.unibe.ch/193198)') end
where id = 'respiration';
update public.exercises set
  muscles_primary = array['transverse', 'lombaires']::text[], muscles_secondary = array['grand_droit']::text[],
  areas = array['dos', 'abdos']::text[], goals = array['mobilite']::text[], discipline = 'pilates', impact = false,
  equipment = array['aucun']::text[], mode = 'time', default_value = 45,
  met = 1.8, met_code = '02103',
  tutorial = jsonb_build_object('steps', to_jsonb(cues), 'breathing', 'Expire en plaquant le bas du dos, inspire en relâchant.', 'mistakes', '["Pousser avec les jambes pour décoller les fesses.","Aller vite au lieu de suivre la respiration."]'::jsonb),
  video_url = coalesce(video_url, null),
  source = case when coalesce(source, '') like '%https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Pelvic_Tilt_Into_Bridge.json%' then source else concat_ws(' ; ', source, 'free-exercise-db (domaine public), fiche Pelvic Tilt Into Bridge (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Pelvic_Tilt_Into_Bridge.json)') end
where id = 'bascule_bassin';
update public.exercises set
  muscles_primary = array['lombaires']::text[], muscles_secondary = array['transverse', 'trapezes']::text[],
  areas = array['dos']::text[], goals = array['mobilite', 'detente']::text[], discipline = 'yoga', impact = false,
  equipment = array['aucun']::text[], mode = 'time', default_value = 45,
  met = 2.3, met_code = '02150',
  tutorial = jsonb_build_object('steps', to_jsonb(cues), 'breathing', 'Inspire en creusant, expire en arrondissant.', 'mistakes', '["Forcer la cambrure.","Plier les coudes."]'::jsonb),
  video_url = coalesce(video_url, null),
  source = case when coalesce(source, '') like '%https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Cat_Stretch.json%' then source else concat_ws(' ; ', source, 'free-exercise-db (domaine public), fiche Cat Stretch (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Cat_Stretch.json) ; NHS, Flexibility exercises (https://www.nhs.uk/live-well/exercise/strength-and-flexibility-exercises/flexibility-exercises/)') end
where id = 'chat_vache';
update public.exercises set
  muscles_primary = array['rhomboides', 'trapezes']::text[], muscles_secondary = '{}'::text[],
  areas = array['dos']::text[], goals = array['mobilite']::text[], discipline = 'renforcement', impact = false,
  equipment = array['aucun']::text[], mode = 'time', default_value = 45,
  met = 3.5, met_code = '02030',
  tutorial = jsonb_build_object('steps', to_jsonb(cues), 'breathing', 'Expire en serrant, inspire en relâchant.', 'mistakes', '["Hausser les épaules.","Cambrer le bas du dos."]'::jsonb),
  video_url = coalesce(video_url, null),
  source = case when coalesce(source, '') like '%https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Upper_Back_Stretch.json%' then source else concat_ws(' ; ', source, 'free-exercise-db (domaine public), fiche Upper Back Stretch (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Upper_Back_Stretch.json)') end
where id = 'omoplates';
update public.exercises set
  muscles_primary = array['trapezes', 'deltoides_lateraux']::text[], muscles_secondary = array['coiffe_rotateurs', 'rhomboides']::text[],
  areas = array['epaules', 'dos']::text[], goals = array['mobilite']::text[], discipline = 'etirement', impact = false,
  equipment = array['mur']::text[], mode = 'time', default_value = 45,
  met = 2.3, met_code = '02101',
  tutorial = jsonb_build_object('steps', to_jsonb(cues), 'breathing', 'Inspire en montant, expire en redescendant.', 'mistakes', '["Décoller le bas du dos du mur.","Monter les épaules vers les oreilles."]'::jsonb),
  video_url = coalesce(video_url, null),
  source = case when coalesce(source, '') like '%https://www.nhs.uk/live-well/exercise/strength-and-flexibility-exercises/flexibility-exercises/%' then source else concat_ws(' ; ', source, 'NHS, Flexibility exercises (https://www.nhs.uk/live-well/exercise/strength-and-flexibility-exercises/flexibility-exercises/)') end
where id = 'wall_slides';
update public.exercises set
  muscles_primary = array['rhomboides', 'lombaires']::text[], muscles_secondary = array['pectoraux']::text[],
  areas = array['dos']::text[], goals = array['mobilite']::text[], discipline = 'etirement', impact = false,
  equipment = array['chaise']::text[], mode = 'time', default_value = 45,
  met = 2.3, met_code = '02101',
  tutorial = jsonb_build_object('steps', to_jsonb(cues), 'breathing', 'Inspire en ouvrant la poitrine, expire en revenant.', 'mistakes', '["Cambrer le bas du dos au lieu du haut.","Pousser la tête en arrière."]'::jsonb),
  video_url = coalesce(video_url, null),
  source = case when coalesce(source, '') like '%https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Chair_Upper_Body_Stretch.json%' then source else concat_ws(' ; ', source, 'free-exercise-db (domaine public), fiche Chair Upper Body Stretch (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Chair_Upper_Body_Stretch.json)') end
where id = 'ext_thoracique';
update public.exercises set
  muscles_primary = array['cou']::text[], muscles_secondary = '{}'::text[],
  areas = array['dos']::text[], goals = array['mobilite']::text[], discipline = 'etirement', impact = false,
  equipment = array['aucun']::text[], mode = 'time', default_value = 45,
  met = 2.3, met_code = '02101',
  tutorial = jsonb_build_object('steps', to_jsonb(cues), 'breathing', 'Respiration libre, sans bloquer pendant le maintien.', 'mistakes', '["Baisser le menton vers la poitrine au lieu de le reculer.","Contracter les épaules."]'::jsonb),
  video_url = coalesce(video_url, null),
  source = case when coalesce(source, '') like '%https://www.nhs.uk/live-well/exercise/strength-and-flexibility-exercises/flexibility-exercises/%' then source else concat_ws(' ; ', source, 'NHS, Flexibility exercises (https://www.nhs.uk/live-well/exercise/strength-and-flexibility-exercises/flexibility-exercises/)') end
where id = 'chin_tuck';
update public.exercises set
  muscles_primary = array['pectoraux']::text[], muscles_secondary = array['deltoides_anterieurs']::text[],
  areas = array['bras', 'epaules']::text[], goals = array['mobilite', 'detente']::text[], discipline = 'etirement', impact = false,
  equipment = array['mur']::text[], mode = 'time', default_value = 60,
  met = 2.3, met_code = '02101',
  tutorial = jsonb_build_object('steps', to_jsonb(cues), 'breathing', 'Expire en avançant le buste, puis respire calmement.', 'mistakes', '["Monter le coude au-dessus de l''épaule.","Cambrer le dos pour gagner de l''amplitude."]'::jsonb),
  video_url = coalesce(video_url, null),
  source = case when coalesce(source, '') like '%https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Chest_And_Front_Of_Shoulder_Stretch.json%' then source else concat_ws(' ; ', source, 'free-exercise-db (domaine public), fiche Chest And Front Of Shoulder Stretch (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Chest_And_Front_Of_Shoulder_Stretch.json)') end
where id = 'pecs_porte';
update public.exercises set
  muscles_primary = array['trapezes', 'cou']::text[], muscles_secondary = '{}'::text[],
  areas = array['dos', 'epaules']::text[], goals = array['mobilite', 'detente']::text[], discipline = 'etirement', impact = false,
  equipment = array['aucun']::text[], mode = 'time', default_value = 60,
  met = 2.3, met_code = '02101',
  tutorial = jsonb_build_object('steps', to_jsonb(cues), 'breathing', 'Expire en relâchant l''épaule opposée vers le bas.', 'mistakes', '["Tirer sur la tête avec la main.","Hausser l''épaule du côté étiré."]'::jsonb),
  video_url = coalesce(video_url, null),
  source = case when coalesce(source, '') like '%https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Side_Neck_Stretch.json%' then source else concat_ws(' ; ', source, 'free-exercise-db (domaine public), fiche Side Neck Stretch (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Side_Neck_Stretch.json) ; NHS, Flexibility exercises (https://www.nhs.uk/live-well/exercise/strength-and-flexibility-exercises/flexibility-exercises/)') end
where id = 'trapezes';
update public.exercises set
  muscles_primary = array['lombaires']::text[], muscles_secondary = array['grand_dorsal', 'grand_fessier']::text[],
  areas = array['dos']::text[], goals = array['mobilite', 'detente']::text[], discipline = 'yoga', impact = false,
  equipment = array['aucun']::text[], mode = 'time', default_value = 30,
  met = 2.3, met_code = '02150',
  tutorial = jsonb_build_object('steps', to_jsonb(cues), 'breathing', 'Respire dans le dos : il se gonfle à l''inspiration.', 'mistakes', '["Forcer les fesses vers les talons si les genoux tirent.","Retenir sa respiration."]'::jsonb),
  video_url = coalesce(video_url, null),
  source = case when coalesce(source, '') like '%https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Childs_Pose.json%' then source else concat_ws(' ; ', source, 'free-exercise-db (domaine public), fiche Childs Pose (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Childs_Pose.json)') end
where id = 'enfant';
update public.exercises set
  muscles_primary = array['flechisseurs_hanche']::text[], muscles_secondary = array['quadriceps']::text[],
  areas = array['jambes', 'fessiers']::text[], goals = array['mobilite']::text[], discipline = 'etirement', impact = false,
  equipment = array['aucun']::text[], mode = 'time', default_value = 60,
  met = 2.3, met_code = '02101',
  tutorial = jsonb_build_object('steps', to_jsonb(cues), 'breathing', 'Expire en avançant le bassin, puis respire calmement.', 'mistakes', '["Cambrer le bas du dos.","Avancer le genou avant au-delà des orteils."]'::jsonb),
  video_url = coalesce(video_url, null),
  source = case when coalesce(source, '') like '%https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Kneeling_Hip_Flexor.json%' then source else concat_ws(' ; ', source, 'free-exercise-db (domaine public), fiche Kneeling Hip Flexor (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Kneeling_Hip_Flexor.json) ; NHS, Flexibility exercises (https://www.nhs.uk/live-well/exercise/strength-and-flexibility-exercises/flexibility-exercises/)') end
where id = 'flechisseurs';
update public.exercises set
  muscles_primary = array['ischio_jambiers']::text[], muscles_secondary = array['mollets']::text[],
  areas = array['jambes']::text[], goals = array['mobilite']::text[], discipline = 'etirement', impact = false,
  equipment = array['aucun']::text[], mode = 'time', default_value = 60,
  met = 2.3, met_code = '02101',
  tutorial = jsonb_build_object('steps', to_jsonb(cues), 'breathing', 'Expire en rapprochant doucement la jambe.', 'mistakes', '["Verrouiller le genou à tout prix.","Décoller les fesses du sol."]'::jsonb),
  video_url = coalesce(video_url, null),
  source = case when coalesce(source, '') like '%https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Hamstring_Stretch.json%' then source else concat_ws(' ; ', source, 'free-exercise-db (domaine public), fiche Hamstring Stretch (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Hamstring_Stretch.json)') end
where id = 'ischios';
update public.exercises set
  muscles_primary = array['grand_fessier', 'moyen_fessier']::text[], muscles_secondary = '{}'::text[],
  areas = array['fessiers']::text[], goals = array['mobilite', 'detente']::text[], discipline = 'etirement', impact = false,
  equipment = array['aucun']::text[], mode = 'time', default_value = 60,
  met = 2.3, met_code = '02101',
  tutorial = jsonb_build_object('steps', to_jsonb(cues), 'breathing', 'Expire en rapprochant la jambe, puis respire calmement.', 'mistakes', '["Tirer sur la tête et le cou pour attraper la jambe.","Forcer sur le genou croisé."]'::jsonb),
  video_url = coalesce(video_url, null),
  source = case when coalesce(source, '') like '%https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Ankle_On_The_Knee.json%' then source else concat_ws(' ; ', source, 'free-exercise-db (domaine public), fiche Ankle On The Knee (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Ankle_On_The_Knee.json) ; NHS, Flexibility exercises (https://www.nhs.uk/live-well/exercise/strength-and-flexibility-exercises/flexibility-exercises/)') end
where id = 'fessiers_4';
update public.exercises set
  muscles_primary = array['mollets']::text[], muscles_secondary = '{}'::text[],
  areas = array['jambes']::text[], goals = array['mobilite']::text[], discipline = 'etirement', impact = false,
  equipment = array['mur']::text[], mode = 'time', default_value = 60,
  met = 2.3, met_code = '02101',
  tutorial = jsonb_build_object('steps', to_jsonb(cues), 'breathing', 'Respiration lente pendant le maintien.', 'mistakes', '["Décoller le talon arrière.","Tourner le pied arrière vers l''extérieur."]'::jsonb),
  video_url = coalesce(video_url, null),
  source = case when coalesce(source, '') like '%https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Calf_Stretch_Hands_Against_Wall.json%' then source else concat_ws(' ; ', source, 'free-exercise-db (domaine public), fiche Calf Stretch Hands Against Wall (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Calf_Stretch_Hands_Against_Wall.json) ; NHS, Flexibility exercises (https://www.nhs.uk/live-well/exercise/strength-and-flexibility-exercises/flexibility-exercises/)') end
where id = 'mollets';
update public.exercises set
  muscles_primary = array['transverse']::text[], muscles_secondary = array['grand_droit', 'flechisseurs_hanche']::text[],
  areas = array['abdos']::text[], goals = array['renforcer']::text[], discipline = 'pilates', impact = false,
  equipment = array['aucun']::text[], mode = 'reps', default_value = 10,
  met = 1.8, met_code = '02103',
  tutorial = jsonb_build_object('steps', to_jsonb(cues), 'breathing', 'Expire en faisant glisser le talon, inspire en revenant.', 'mistakes', '["Creuser le dos quand la jambe s''allonge.","Aller trop vite."]'::jsonb),
  video_url = coalesce(video_url, null),
  source = case when coalesce(source, '') like '%https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Flat_Bench_Lying_Leg_Raise.json%' then source else concat_ws(' ; ', source, 'free-exercise-db (domaine public), fiche Flat Bench Lying Leg Raise (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Flat_Bench_Lying_Leg_Raise.json)') end
where id = 'glissement_talon';
update public.exercises set
  muscles_primary = array['grand_droit', 'transverse']::text[], muscles_secondary = array['deltoides_anterieurs', 'pectoraux']::text[],
  areas = array['abdos', 'epaules']::text[], goals = array['renforcer']::text[], discipline = 'gainage', impact = false,
  equipment = array['chaise']::text[], mode = 'time', default_value = 30,
  met = 2.8, met_code = '02024',
  tutorial = jsonb_build_object('steps', to_jsonb(cues), 'breathing', 'Respire lentement pendant tout le maintien.', 'mistakes', '["Bassin qui s''affaisse.","Support instable qui glisse."]'::jsonb),
  video_url = coalesce(video_url, null),
  source = case when coalesce(source, '') like '%https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Plank.json%' then source else concat_ws(' ; ', source, 'free-exercise-db (domaine public), fiche Plank (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Plank.json)') end
where id = 'planche_inclinee';
update public.exercises set
  muscles_primary = array['obliques', 'transverse']::text[], muscles_secondary = array['grand_fessier']::text[],
  areas = array['abdos']::text[], goals = array['renforcer']::text[], discipline = 'gainage', impact = false,
  equipment = array['elastique']::text[], mode = 'time', default_value = 40,
  met = 2.8, met_code = '02024',
  tutorial = jsonb_build_object('steps', to_jsonb(cues), 'breathing', 'Respire calmement bras tendus, sans bloquer.', 'mistakes', '["Laisser le buste tourner.","S''asseoir sur les talons."]'::jsonb),
  video_url = coalesce(video_url, null),
  source = case when coalesce(source, '') like '%https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Pallof_Press.json%' then source else concat_ws(' ; ', source, 'free-exercise-db (domaine public), fiche Pallof Press (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Pallof_Press.json)') end
where id = 'pallof_genoux';
update public.exercises set
  muscles_primary = array['rhomboides', 'grand_dorsal']::text[], muscles_secondary = array['biceps', 'deltoides_posterieurs']::text[],
  areas = array['dos', 'bras']::text[], goals = array['renforcer', 'tonifier']::text[], discipline = 'renforcement', impact = false,
  equipment = array['elastique']::text[], mode = 'reps', default_value = 12,
  met = 3.5, met_code = '02054',
  tutorial = jsonb_build_object('steps', to_jsonb(cues), 'breathing', 'Expire en tirant, inspire en relâchant.', 'mistakes', '["Balancer le buste.","Tirer avec les mains plutôt qu''avec les coudes."]'::jsonb),
  video_url = coalesce(video_url, null),
  source = case when coalesce(source, '') like '%https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Seated_Cable_Rows.json%' then source else concat_ws(' ; ', source, 'free-exercise-db (domaine public), fiche Seated Cable Rows (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Seated_Cable_Rows.json)') end
where id = 'rowing_debout';
update public.exercises set
  muscles_primary = array['deltoides_posterieurs', 'rhomboides']::text[], muscles_secondary = array['coiffe_rotateurs', 'trapezes']::text[],
  areas = array['epaules', 'dos']::text[], goals = array['renforcer']::text[], discipline = 'renforcement', impact = false,
  equipment = array['elastique']::text[], mode = 'reps', default_value = 12,
  met = 3.5, met_code = '02054',
  tutorial = jsonb_build_object('steps', to_jsonb(cues), 'breathing', 'Expire en tirant, inspire en revenant.', 'mistakes', '["Hausser les épaules.","Cambrer le dos pour finir le tirage."]'::jsonb),
  video_url = coalesce(video_url, null),
  source = case when coalesce(source, '') like '%https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Reverse_Flyes.json%' then source else concat_ws(' ; ', source, 'free-exercise-db (domaine public), fiche Reverse Flyes (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Reverse_Flyes.json)') end
where id = 'face_pull_bas';
update public.exercises set
  muscles_primary = array['coiffe_rotateurs']::text[], muscles_secondary = array['deltoides_posterieurs']::text[],
  areas = array['epaules']::text[], goals = array['renforcer']::text[], discipline = 'renforcement', impact = false,
  equipment = array['elastique']::text[], mode = 'reps', default_value = 12,
  met = 3.5, met_code = '02054',
  tutorial = jsonb_build_object('steps', to_jsonb(cues), 'breathing', 'Expire en écartant l''avant-bras, inspire en revenant.', 'mistakes', '["Décoller le coude du corps.","Élastique trop dur : le mouvement devient saccadé."]'::jsonb),
  video_url = coalesce(video_url, null),
  source = case when coalesce(source, '') like '%https://github.com/yuhonas/free-exercise-db/blob/main/exercises/External_Rotation_with_Band.json%' then source else concat_ws(' ; ', source, 'free-exercise-db (domaine public), fiche External Rotation with Band (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/External_Rotation_with_Band.json)') end
where id = 'rotation_externe';
update public.exercises set
  muscles_primary = array['deltoides_lateraux']::text[], muscles_secondary = array['trapezes']::text[],
  areas = array['epaules']::text[], goals = array['renforcer', 'tonifier']::text[], discipline = 'renforcement', impact = false,
  equipment = array['elastique']::text[], mode = 'reps', default_value = 12,
  met = 3.5, met_code = '02054',
  tutorial = jsonb_build_object('steps', to_jsonb(cues), 'breathing', 'Expire en montant, inspire en descendant.', 'mistakes', '["Monter au-dessus des épaules.","Prendre de l''élan avec le buste."]'::jsonb),
  video_url = coalesce(video_url, null),
  source = case when coalesce(source, '') like '%https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Lateral_Raise_-_With_Bands.json%' then source else concat_ws(' ; ', source, 'free-exercise-db (domaine public), fiche Lateral Raise - With Bands (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Lateral_Raise_-_With_Bands.json)') end
where id = 'elevation_laterale';
update public.exercises set
  muscles_primary = array['biceps']::text[], muscles_secondary = array['avant_bras']::text[],
  areas = array['bras']::text[], goals = array['renforcer', 'tonifier']::text[], discipline = 'renforcement', impact = false,
  equipment = array['elastique']::text[], mode = 'reps', default_value = 12,
  met = 3.5, met_code = '02054',
  tutorial = jsonb_build_object('steps', to_jsonb(cues), 'breathing', 'Expire en pliant les coudes, inspire en redescendant.', 'mistakes', '["Avancer les coudes.","Se cambrer pour finir la montée."]'::jsonb),
  video_url = coalesce(video_url, null),
  source = case when coalesce(source, '') like '%https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Close-Grip_EZ-Bar_Curl_with_Band.json%' then source else concat_ws(' ; ', source, 'free-exercise-db (domaine public), fiche Close-Grip EZ-Bar Curl with Band (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Close-Grip_EZ-Bar_Curl_with_Band.json)') end
where id = 'curl_biceps';
update public.exercises set
  muscles_primary = array['triceps']::text[], muscles_secondary = '{}'::text[],
  areas = array['bras']::text[], goals = array['renforcer', 'tonifier']::text[], discipline = 'renforcement', impact = false,
  equipment = array['elastique']::text[], mode = 'reps', default_value = 12,
  met = 3.5, met_code = '02054',
  tutorial = jsonb_build_object('steps', to_jsonb(cues), 'breathing', 'Expire en tendant les bras, inspire en revenant.', 'mistakes', '["Écarter les coudes du corps.","Se pencher en avant pour pousser."]'::jsonb),
  video_url = coalesce(video_url, null),
  source = case when coalesce(source, '') like '%https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Triceps_Pushdown.json%' then source else concat_ws(' ; ', source, 'free-exercise-db (domaine public), fiche Triceps Pushdown (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Triceps_Pushdown.json)') end
where id = 'triceps_elastique';
update public.exercises set
  muscles_primary = array['moyen_fessier']::text[], muscles_secondary = array['grand_fessier']::text[],
  areas = array['fessiers']::text[], goals = array['renforcer', 'tonifier']::text[], discipline = 'renforcement', impact = false,
  equipment = array['aucun']::text[], mode = 'reps', default_value = 15,
  met = 3.0, met_code = '02056',
  tutorial = jsonb_build_object('steps', to_jsonb(cues), 'breathing', 'Expire en ouvrant le genou, inspire en refermant.', 'mistakes', '["Rouler le bassin vers l''arrière.","Décoller les pieds l''un de l''autre."]'::jsonb),
  video_url = coalesce(video_url, null)
where id = 'clamshell';
update public.exercises set
  muscles_primary = array['moyen_fessier']::text[], muscles_secondary = array['grand_fessier']::text[],
  areas = array['fessiers', 'jambes']::text[], goals = array['renforcer', 'tonifier']::text[], discipline = 'renforcement', impact = false,
  equipment = array['aucun']::text[], mode = 'reps', default_value = 15,
  met = 3.0, met_code = '02056',
  tutorial = jsonb_build_object('steps', to_jsonb(cues), 'breathing', 'Expire en montant la jambe, inspire en descendant.', 'mistakes', '["Pointe du pied tournée vers le plafond.","Bassin qui bascule en arrière."]'::jsonb),
  video_url = coalesce(video_url, null),
  source = case when coalesce(source, '') like '%https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Side_Leg_Raises.json%' then source else concat_ws(' ; ', source, 'free-exercise-db (domaine public), fiche Side Leg Raises (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Side_Leg_Raises.json)') end
where id = 'abduction_couchee';
update public.exercises set
  muscles_primary = array['quadriceps']::text[], muscles_secondary = array['grand_fessier', 'adducteurs']::text[],
  areas = array['jambes', 'fessiers']::text[], goals = array['renforcer', 'tonifier']::text[], discipline = 'renforcement', impact = false,
  equipment = array['mur']::text[], mode = 'reps', default_value = 10,
  met = 3.0, met_code = '02056',
  tutorial = jsonb_build_object('steps', to_jsonb(cues), 'breathing', 'Inspire en descendant, expire en remontant.', 'mistakes', '["Pieds trop près du mur.","Genoux qui rentrent vers l''intérieur."]'::jsonb),
  video_url = coalesce(video_url, null),
  source = case when coalesce(source, '') like '%https://www.nhs.uk/live-well/exercise/strength-and-flexibility-exercises/strength-exercises/%' then source else concat_ws(' ; ', source, 'NHS, Strength exercises (https://www.nhs.uk/live-well/exercise/strength-and-flexibility-exercises/strength-exercises/)') end
where id = 'squat_mur';
update public.exercises set
  muscles_primary = array['quadriceps', 'grand_fessier']::text[], muscles_secondary = array['ischio_jambiers', 'mollets']::text[],
  areas = array['jambes', 'fessiers']::text[], goals = array['renforcer', 'tonifier']::text[], discipline = 'renforcement', impact = false,
  equipment = array['aucun']::text[], mode = 'reps', default_value = 10,
  met = 3.0, met_code = '02056',
  tutorial = jsonb_build_object('steps', to_jsonb(cues), 'breathing', 'Expire en montant, inspire en redescendant.', 'mistakes', '["Pousser avec la jambe d''en bas.","Laisser le genou rentrer vers l''intérieur."]'::jsonb),
  video_url = coalesce(video_url, null),
  source = case when coalesce(source, '') like '%https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Dumbbell_Step_Ups.json%' then source else concat_ws(' ; ', source, 'free-exercise-db (domaine public), fiche Dumbbell Step Ups (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Dumbbell_Step_Ups.json) ; NHS, Strength exercises (https://www.nhs.uk/live-well/exercise/strength-and-flexibility-exercises/strength-exercises/)') end
where id = 'montee_marche';
update public.exercises set
  muscles_primary = array['ischio_jambiers', 'grand_fessier']::text[], muscles_secondary = array['lombaires']::text[],
  areas = array['jambes', 'fessiers']::text[], goals = array['renforcer', 'tonifier']::text[], discipline = 'renforcement', impact = false,
  equipment = array['aucun']::text[], mode = 'reps', default_value = 12,
  met = 3.0, met_code = '02056',
  tutorial = jsonb_build_object('steps', to_jsonb(cues), 'breathing', 'Expire en montant, inspire en redescendant.', 'mistakes', '["Cambrer en haut.","Pieds trop loin : crampe assurée."]'::jsonb),
  video_url = coalesce(video_url, null),
  source = case when coalesce(source, '') like '%https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Platform_Hamstring_Slides.json%' then source else concat_ws(' ; ', source, 'free-exercise-db (domaine public), fiche Platform Hamstring Slides (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Platform_Hamstring_Slides.json)') end
where id = 'pont_ischios';
update public.exercises set
  muscles_primary = array['grand_fessier']::text[], muscles_secondary = array['ischio_jambiers']::text[],
  areas = array['fessiers']::text[], goals = array['renforcer', 'tonifier']::text[], discipline = 'renforcement', impact = false,
  equipment = array['elastique']::text[], mode = 'reps', default_value = 12,
  met = 3.5, met_code = '02054',
  tutorial = jsonb_build_object('steps', to_jsonb(cues), 'breathing', 'Expire en poussant la jambe, inspire en revenant.', 'mistakes', '["Se pencher en avant pour lever plus haut.","Cambrer le dos."]'::jsonb),
  video_url = coalesce(video_url, null),
  source = case when coalesce(source, '') like '%https://github.com/yuhonas/free-exercise-db/blob/main/exercises/One-Legged_Cable_Kickback.json%' then source else concat_ws(' ; ', source, 'free-exercise-db (domaine public), fiche One-Legged Cable Kickback (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/One-Legged_Cable_Kickback.json)') end
where id = 'extension_hanche_debout';
update public.exercises set
  muscles_primary = array['mollets']::text[], muscles_secondary = '{}'::text[],
  areas = array['jambes']::text[], goals = array['renforcer', 'tonifier']::text[], discipline = 'renforcement', impact = false,
  equipment = array['aucun']::text[], mode = 'reps', default_value = 15,
  met = 3.0, met_code = '02056',
  tutorial = jsonb_build_object('steps', to_jsonb(cues), 'breathing', 'Expire en montant, inspire en redescendant.', 'mistakes', '["Rebondir en bas.","Laisser les chevilles partir vers l''extérieur."]'::jsonb),
  video_url = coalesce(video_url, null),
  source = case when coalesce(source, '') like '%https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Standing_Calf_Raises.json%' then source else concat_ws(' ; ', source, 'free-exercise-db (domaine public), fiche Standing Calf Raises (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Standing_Calf_Raises.json)') end
where id = 'releve_mollets';
update public.exercises set
  muscles_primary = array['rhomboides', 'obliques']::text[], muscles_secondary = array['pectoraux']::text[],
  areas = array['dos']::text[], goals = array['mobilite']::text[], discipline = 'etirement', impact = false,
  equipment = array['aucun']::text[], mode = 'time', default_value = 60,
  met = 2.3, met_code = '02101',
  tutorial = jsonb_build_object('steps', to_jsonb(cues), 'breathing', 'Inspire en ouvrant le bras, expire en revenant.', 'mistakes', '["Décoller les genoux.","Forcer l''épaule au sol."]'::jsonb),
  video_url = coalesce(video_url, null),
  source = case when coalesce(source, '') like '%https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Side-Lying_Floor_Stretch.json%' then source else concat_ws(' ; ', source, 'free-exercise-db (domaine public), fiche Side-Lying Floor Stretch (https://github.com/yuhonas/free-exercise-db/blob/main/exercises/Side-Lying_Floor_Stretch.json)') end
where id = 'livre_ouvert';
update public.exercises set
  muscles_primary = array['grand_droit']::text[], muscles_secondary = array['obliques', 'transverse']::text[],
  areas = array['abdos']::text[], goals = array['renforcer']::text[], discipline = 'gainage', impact = false,
  equipment = array['aucun']::text[], mode = 'time', default_value = 60,
  met = 2.8, met_code = '02024',
  tutorial = jsonb_build_object('steps', to_jsonb(cues), 'breathing', 'Respire normalement pendant les 10 s de maintien.', 'mistakes', '["Rentrer le menton vers la poitrine.","Plaquer le bas du dos au sol."]'::jsonb),
  video_url = coalesce(video_url, null),
  source = case when coalesce(source, '') like '%https://www.health.harvard.edu/staying-healthy/core-exercises-the-big-3%' then source else concat_ws(' ; ', source, 'Harvard Health Publishing, « Big 3 » de Stuart McGill (https://www.health.harvard.edu/staying-healthy/core-exercises-the-big-3)') end
where id = 'curl_up_mcgill';

-- ---------------------------------------------------------------- 3. Entraînements
insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('prog_mobilite_s1', 'Mobilité douce', 'Une séance courte pour délier le dos, les hanches et les épaules entre deux renforcements.', 'programme', 1, array['corps_entier']::text[], 'etirement', 1, 10, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'prog_mobilite_s1'
  and exists (select 1 from public.trainings where id = 'prog_mobilite_s1' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('prog_mobilite_s1', 'main', 1, 'chat_vache', 1, null, null),
  ('prog_mobilite_s1', 'main', 2, 'cercles_hanches', 1, null, null),
  ('prog_mobilite_s1', 'main', 3, 'livre_ouvert', 1, null, null),
  ('prog_mobilite_s1', 'main', 4, 'plus_grand_etirement', 1, null, null),
  ('prog_mobilite_s1', 'main', 5, 'enfant', 2, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'prog_mobilite_s1' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('prog_mobilite_s2', 'Mobilité du dos et des hanches', 'Mobilité active pour récupérer et bouger mieux.', 'programme', 1, array['corps_entier']::text[], 'etirement', 1, 10, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'prog_mobilite_s2'
  and exists (select 1 from public.trainings where id = 'prog_mobilite_s2' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('prog_mobilite_s2', 'main', 1, 'chat_vache', 2, null, null),
  ('prog_mobilite_s2', 'main', 2, 'cercles_bras', 1, null, null),
  ('prog_mobilite_s2', 'main', 3, 'rotations_buste', 1, null, null),
  ('prog_mobilite_s2', 'main', 4, 'plus_grand_etirement', 2, null, null),
  ('prog_mobilite_s2', 'main', 5, 'fente_basse', 1, null, null),
  ('prog_mobilite_s2', 'main', 6, 'enfant', 3, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'prog_mobilite_s2' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('prog_mobilite_s3', 'Mobilité et salutation au soleil', 'Mobilité puis deux salutations au soleil en douceur.', 'programme', 1, array['corps_entier']::text[], 'yoga', 1, 10, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'prog_mobilite_s3'
  and exists (select 1 from public.trainings where id = 'prog_mobilite_s3' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('prog_mobilite_s3', 'main', 1, 'chat_vache', 2, null, null),
  ('prog_mobilite_s3', 'main', 2, 'cercles_hanches', 1, null, null),
  ('prog_mobilite_s3', 'main', 3, 'salutation_soleil', 1, null, null),
  ('prog_mobilite_s3', 'main', 4, 'plus_grand_etirement', 2, null, null),
  ('prog_mobilite_s3', 'main', 5, 'sphinx', 1, null, null),
  ('prog_mobilite_s3', 'main', 6, 'torsion_couchee', 1, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'prog_mobilite_s3' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('prog_mobilite_s4', 'Mobilité complète', 'Une séance de mobilité plus longue pour finir le mois en souplesse.', 'programme', 1, array['corps_entier']::text[], 'yoga', 1, 10, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'prog_mobilite_s4'
  and exists (select 1 from public.trainings where id = 'prog_mobilite_s4' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('prog_mobilite_s4', 'main', 1, 'chat_vache', 3, null, null),
  ('prog_mobilite_s4', 'main', 2, 'cercles_bras', 1, null, null),
  ('prog_mobilite_s4', 'main', 3, 'salutation_soleil', 2, null, null),
  ('prog_mobilite_s4', 'main', 4, 'plus_grand_etirement', 2, null, null),
  ('prog_mobilite_s4', 'main', 5, 'fente_basse', 1, null, null),
  ('prog_mobilite_s4', 'main', 6, 'pigeon', 1, null, null),
  ('prog_mobilite_s4', 'main', 7, 'torsion_couchee', 1, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'prog_mobilite_s4' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('prog_recup_s1', 'Récupération : étirements', 'Étirements doux de tout le corps pour finir la semaine.', 'programme', 1, array['corps_entier']::text[], 'etirement', 1, 10, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'prog_recup_s1'
  and exists (select 1 from public.trainings where id = 'prog_recup_s1' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('prog_recup_s1', 'main', 1, 'genoux_poitrine', 1, null, null),
  ('prog_recup_s1', 'main', 2, 'fessiers_4', 1, null, null),
  ('prog_recup_s1', 'main', 3, 'ischios', 1, null, null),
  ('prog_recup_s1', 'main', 4, 'torsion_couchee', 1, null, null),
  ('prog_recup_s1', 'main', 5, 'enfant', 2, null, null),
  ('prog_recup_s1', 'main', 6, 'respiration', 1, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'prog_recup_s1' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('prog_recup_s2', 'Récupération : yoga doux', 'Postures de yoga au sol et respiration lente.', 'programme', 1, array['corps_entier']::text[], 'yoga', 1, 10, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'prog_recup_s2'
  and exists (select 1 from public.trainings where id = 'prog_recup_s2' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('prog_recup_s2', 'main', 1, 'chat_vache', 2, null, null),
  ('prog_recup_s2', 'main', 2, 'sphinx', 2, null, null),
  ('prog_recup_s2', 'main', 3, 'enfant', 3, null, null),
  ('prog_recup_s2', 'main', 4, 'papillon', 2, null, null),
  ('prog_recup_s2', 'main', 5, 'torsion_couchee', 1, null, null),
  ('prog_recup_s2', 'main', 6, 'coherence_cardiaque', 1, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'prog_recup_s2' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('prog_recup_s3', 'Récupération : hanches et dos', 'Ouverture des hanches, détente du dos et quelques minutes de calme.', 'programme', 1, array['corps_entier']::text[], 'yoga', 1, 10, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'prog_recup_s3'
  and exists (select 1 from public.trainings where id = 'prog_recup_s3' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('prog_recup_s3', 'main', 1, 'fente_basse', 1, null, null),
  ('prog_recup_s3', 'main', 2, 'pigeon', 1, null, null),
  ('prog_recup_s3', 'main', 3, 'papillon', 2, null, null),
  ('prog_recup_s3', 'main', 4, 'bebe_heureux', 2, null, null),
  ('prog_recup_s3', 'main', 5, 'torsion_couchee', 1, null, null),
  ('prog_recup_s3', 'main', 6, 'jambes_au_mur', 1, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'prog_recup_s3' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('prog_recup_s4', 'Récupération : bilan du mois', 'Étirements et scan corporel pour savourer le chemin parcouru.', 'programme', 1, array['corps_entier']::text[], 'yoga', 1, 10, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'prog_recup_s4'
  and exists (select 1 from public.trainings where id = 'prog_recup_s4' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('prog_recup_s4', 'main', 1, 'chat_vache', 2, null, null),
  ('prog_recup_s4', 'main', 2, 'pince_assise', 2, null, null),
  ('prog_recup_s4', 'main', 3, 'papillon', 2, null, null),
  ('prog_recup_s4', 'main', 4, 'torsion_couchee', 1, null, null),
  ('prog_recup_s4', 'main', 5, 'scan_corporel', 1, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'prog_recup_s4' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('rf_s1_a', 'Bas du corps et gainage', null, 'programme', 1, array['jambes', 'fessiers', 'abdos']::text[], null, 2, 15, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'rf_s1_a'
  and exists (select 1 from public.trainings where id = 'rf_s1_a' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('rf_s1_a', 'warmup', 1, 'marche_genoux_hauts', 1, 40, null),
  ('rf_s1_a', 'warmup', 2, 'cercles_bras', 1, null, null),
  ('rf_s1_a', 'warmup', 3, 'cercles_hanches', 1, null, null),
  ('rf_s1_a', 'warmup', 4, 'rotations_buste', 1, null, null),
  ('rf_s1_a', 'main', 1, 'squat', 1, null, null),
  ('rf_s1_a', 'main', 2, 'pont', 1, null, null),
  ('rf_s1_a', 'main', 3, 'dead_bug', 1, null, null),
  ('rf_s1_a', 'main', 4, 'planche', 1, null, null),
  ('rf_s1_a', 'cooldown', 1, 'ischios', 1, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'rf_s1_a' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('rf_s1_b', 'Haut du corps et dos', null, 'programme', 1, array['bras', 'epaules', 'dos']::text[], null, 2, 15, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'rf_s1_b'
  and exists (select 1 from public.trainings where id = 'rf_s1_b' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('rf_s1_b', 'warmup', 1, 'marche_genoux_hauts', 1, 40, null),
  ('rf_s1_b', 'warmup', 2, 'cercles_bras', 1, null, null),
  ('rf_s1_b', 'warmup', 3, 'cercles_hanches', 1, null, null),
  ('rf_s1_b', 'warmup', 4, 'rotations_buste', 1, null, null),
  ('rf_s1_b', 'main', 1, 'pompe_genoux', 1, null, null),
  ('rf_s1_b', 'main', 2, 'superman', 1, null, null),
  ('rf_s1_b', 'main', 3, 'bird_dog', 3, null, null),
  ('rf_s1_b', 'main', 4, 'ours_statique', 1, null, null),
  ('rf_s1_b', 'cooldown', 1, 'enfant', 2, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'rf_s1_b' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('rf_s1_c', 'Cardio doux', null, 'programme', 1, array['corps_entier']::text[], 'cardio', 2, 15, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'rf_s1_c'
  and exists (select 1 from public.trainings where id = 'rf_s1_c' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('rf_s1_c', 'warmup', 1, 'cercles_bras', 1, null, null),
  ('rf_s1_c', 'warmup', 2, 'cercles_hanches', 1, null, null),
  ('rf_s1_c', 'main', 1, 'marche_genoux_hauts', 1, null, null),
  ('rf_s1_c', 'main', 2, 'step_jacks', 1, null, null),
  ('rf_s1_c', 'main', 3, 'squat_coup_de_pied', 1, null, null),
  ('rf_s1_c', 'main', 4, 'boxe_ombre', 1, null, null),
  ('rf_s1_c', 'cooldown', 1, 'mollets', 1, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'rf_s1_c' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('rf_s2_a', 'Bas du corps et gainage', null, 'programme', 1, array['jambes', 'fessiers', 'abdos']::text[], null, 2, 15, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'rf_s2_a'
  and exists (select 1 from public.trainings where id = 'rf_s2_a' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('rf_s2_a', 'warmup', 1, 'marche_genoux_hauts', 1, 40, null),
  ('rf_s2_a', 'warmup', 2, 'cercles_bras', 1, null, null),
  ('rf_s2_a', 'warmup', 3, 'cercles_hanches', 1, null, null),
  ('rf_s2_a', 'warmup', 4, 'rotations_buste', 1, null, null),
  ('rf_s2_a', 'main', 1, 'squat', 2, null, null),
  ('rf_s2_a', 'main', 2, 'fente_arriere', 1, null, null),
  ('rf_s2_a', 'main', 3, 'pont', 2, null, null),
  ('rf_s2_a', 'main', 4, 'dead_bug', 2, null, null),
  ('rf_s2_a', 'main', 5, 'planche', 2, null, null),
  ('rf_s2_a', 'cooldown', 1, 'ischios', 1, null, null),
  ('rf_s2_a', 'cooldown', 2, 'flechisseurs', 1, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'rf_s2_a' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('rf_s2_b', 'Haut du corps et dos', null, 'programme', 1, array['bras', 'epaules', 'dos']::text[], null, 2, 15, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'rf_s2_b'
  and exists (select 1 from public.trainings where id = 'rf_s2_b' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('rf_s2_b', 'warmup', 1, 'marche_genoux_hauts', 1, 40, null),
  ('rf_s2_b', 'warmup', 2, 'cercles_bras', 1, null, null),
  ('rf_s2_b', 'warmup', 3, 'cercles_hanches', 1, null, null),
  ('rf_s2_b', 'warmup', 4, 'rotations_buste', 1, null, null),
  ('rf_s2_b', 'main', 1, 'pompe_genoux', 2, null, null),
  ('rf_s2_b', 'main', 2, 'superman', 2, null, null),
  ('rf_s2_b', 'main', 3, 'planche_epaules', 1, null, null),
  ('rf_s2_b', 'main', 4, 'ytw', 1, null, null),
  ('rf_s2_b', 'main', 5, 'bird_dog', 3, null, null),
  ('rf_s2_b', 'main', 6, 'planche_inverse', 1, null, null),
  ('rf_s2_b', 'cooldown', 1, 'enfant', 2, null, null),
  ('rf_s2_b', 'cooldown', 2, 'epaule_bras_croise', 1, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'rf_s2_b' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('rf_s2_c', 'Cardio et renforcement', null, 'programme', 1, array['corps_entier']::text[], 'cardio', 2, 15, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'rf_s2_c'
  and exists (select 1 from public.trainings where id = 'rf_s2_c' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('rf_s2_c', 'warmup', 1, 'marche_genoux_hauts', 1, null, null),
  ('rf_s2_c', 'warmup', 2, 'cercles_bras', 1, null, null),
  ('rf_s2_c', 'warmup', 3, 'cercles_hanches', 1, null, null),
  ('rf_s2_c', 'main', 1, 'step_jacks', 2, null, null),
  ('rf_s2_c', 'main', 2, 'squat', 1, null, null),
  ('rf_s2_c', 'main', 3, 'boxe_ombre', 2, null, null),
  ('rf_s2_c', 'main', 4, 'mountain_climbers_lents', 2, null, null),
  ('rf_s2_c', 'main', 5, 'patineur_sans_saut', 1, null, null),
  ('rf_s2_c', 'cooldown', 1, 'quadriceps_debout', 1, null, null),
  ('rf_s2_c', 'cooldown', 2, 'mollets', 1, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'rf_s2_c' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('rf_s3_a', 'Bas du corps et gainage', null, 'programme', 1, array['jambes', 'fessiers', 'abdos']::text[], null, 3, 15, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'rf_s3_a'
  and exists (select 1 from public.trainings where id = 'rf_s3_a' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('rf_s3_a', 'warmup', 1, 'marche_genoux_hauts', 2, 45, null),
  ('rf_s3_a', 'warmup', 2, 'cercles_bras', 1, null, null),
  ('rf_s3_a', 'warmup', 3, 'cercles_hanches', 1, null, null),
  ('rf_s3_a', 'warmup', 4, 'rotations_buste', 1, null, null),
  ('rf_s3_a', 'warmup', 5, 'plus_grand_etirement', 1, 40, null),
  ('rf_s3_a', 'main', 1, 'squat', 2, null, null),
  ('rf_s3_a', 'main', 2, 'fente_arriere', 2, null, null),
  ('rf_s3_a', 'main', 3, 'pont', 3, null, null),
  ('rf_s3_a', 'main', 4, 'dead_bug', 2, null, null),
  ('rf_s3_a', 'main', 5, 'planche', 2, null, null),
  ('rf_s3_a', 'cooldown', 1, 'ischios', 2, null, null),
  ('rf_s3_a', 'cooldown', 2, 'flechisseurs', 1, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'rf_s3_a' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('rf_s3_b', 'Haut du corps et dos', null, 'programme', 1, array['bras', 'epaules', 'dos']::text[], null, 3, 15, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'rf_s3_b'
  and exists (select 1 from public.trainings where id = 'rf_s3_b' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('rf_s3_b', 'warmup', 1, 'marche_genoux_hauts', 2, 45, null),
  ('rf_s3_b', 'warmup', 2, 'cercles_bras', 1, null, null),
  ('rf_s3_b', 'warmup', 3, 'cercles_hanches', 1, null, null),
  ('rf_s3_b', 'warmup', 4, 'rotations_buste', 1, null, null),
  ('rf_s3_b', 'warmup', 5, 'plus_grand_etirement', 1, 40, null),
  ('rf_s3_b', 'main', 1, 'pompe_genoux', 3, null, null),
  ('rf_s3_b', 'main', 2, 'superman', 2, null, null),
  ('rf_s3_b', 'main', 3, 'planche_epaules', 2, null, null),
  ('rf_s3_b', 'main', 4, 'ytw', 2, null, null),
  ('rf_s3_b', 'main', 5, 'planche_inverse', 1, null, null),
  ('rf_s3_b', 'cooldown', 1, 'enfant', 2, null, null),
  ('rf_s3_b', 'cooldown', 2, 'epaule_bras_croise', 2, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'rf_s3_b' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('rf_s3_c', 'Cardio et renforcement', null, 'programme', 1, array['corps_entier']::text[], 'cardio', 3, 15, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'rf_s3_c'
  and exists (select 1 from public.trainings where id = 'rf_s3_c' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('rf_s3_c', 'warmup', 1, 'marche_genoux_hauts', 2, null, null),
  ('rf_s3_c', 'warmup', 2, 'cercles_bras', 1, null, null),
  ('rf_s3_c', 'warmup', 3, 'cercles_hanches', 1, null, null),
  ('rf_s3_c', 'warmup', 4, 'rotations_buste', 1, null, null),
  ('rf_s3_c', 'main', 1, 'step_jacks', 3, null, null),
  ('rf_s3_c', 'main', 2, 'squat', 2, null, null),
  ('rf_s3_c', 'main', 3, 'boxe_ombre', 2, null, null),
  ('rf_s3_c', 'main', 4, 'mountain_climbers_lents', 2, null, null),
  ('rf_s3_c', 'main', 5, 'burpee_sans_saut', 1, null, null),
  ('rf_s3_c', 'cooldown', 1, 'quadriceps_debout', 2, null, null),
  ('rf_s3_c', 'cooldown', 2, 'mollets', 1, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'rf_s3_c' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('rf_s4_a', 'Bas du corps et gainage', null, 'programme', 2, array['jambes', 'fessiers', 'abdos']::text[], null, 3, 15, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'rf_s4_a'
  and exists (select 1 from public.trainings where id = 'rf_s4_a' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('rf_s4_a', 'warmup', 1, 'marche_genoux_hauts', 2, 45, null),
  ('rf_s4_a', 'warmup', 2, 'cercles_bras', 2, null, null),
  ('rf_s4_a', 'warmup', 3, 'cercles_hanches', 2, null, null),
  ('rf_s4_a', 'warmup', 4, 'rotations_buste', 2, null, null),
  ('rf_s4_a', 'warmup', 5, 'plus_grand_etirement', 1, 40, null),
  ('rf_s4_a', 'main', 1, 'squat', 3, null, null),
  ('rf_s4_a', 'main', 2, 'fente_arriere', 2, null, null),
  ('rf_s4_a', 'main', 3, 'pont', 3, null, null),
  ('rf_s4_a', 'main', 4, 'fente_laterale', 2, null, null),
  ('rf_s4_a', 'main', 5, 'dead_bug', 3, null, null),
  ('rf_s4_a', 'main', 6, 'planche', 3, null, null),
  ('rf_s4_a', 'cooldown', 1, 'ischios', 2, null, null),
  ('rf_s4_a', 'cooldown', 2, 'flechisseurs', 2, null, null),
  ('rf_s4_a', 'cooldown', 3, 'fessiers_4', 1, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'rf_s4_a' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('rf_s4_b', 'Haut du corps et dos', null, 'programme', 2, array['bras', 'epaules', 'dos']::text[], null, 3, 15, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'rf_s4_b'
  and exists (select 1 from public.trainings where id = 'rf_s4_b' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('rf_s4_b', 'warmup', 1, 'marche_genoux_hauts', 2, 45, null),
  ('rf_s4_b', 'warmup', 2, 'cercles_bras', 2, null, null),
  ('rf_s4_b', 'warmup', 3, 'cercles_hanches', 2, null, null),
  ('rf_s4_b', 'warmup', 4, 'rotations_buste', 2, null, null),
  ('rf_s4_b', 'warmup', 5, 'plus_grand_etirement', 1, 40, null),
  ('rf_s4_b', 'main', 1, 'pompe_genoux', 3, null, null),
  ('rf_s4_b', 'main', 2, 'superman', 3, null, null),
  ('rf_s4_b', 'main', 3, 'planche_epaules', 2, null, null),
  ('rf_s4_b', 'main', 4, 'ytw', 3, null, null),
  ('rf_s4_b', 'main', 5, 'planche_inverse', 2, null, null),
  ('rf_s4_b', 'main', 6, 'chenille', 1, null, null),
  ('rf_s4_b', 'main', 7, 'boxe_ombre', 3, null, null),
  ('rf_s4_b', 'main', 8, 'ours_statique', 3, null, null),
  ('rf_s4_b', 'cooldown', 1, 'enfant', 3, null, null),
  ('rf_s4_b', 'cooldown', 2, 'epaule_bras_croise', 2, null, null),
  ('rf_s4_b', 'cooldown', 3, 'triceps_etirement', 1, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'rf_s4_b' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('rf_s4_c', 'Cardio et renforcement', null, 'programme', 2, array['corps_entier']::text[], 'cardio', 3, 15, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'rf_s4_c'
  and exists (select 1 from public.trainings where id = 'rf_s4_c' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('rf_s4_c', 'warmup', 1, 'marche_genoux_hauts', 2, null, null),
  ('rf_s4_c', 'warmup', 2, 'cercles_bras', 2, null, null),
  ('rf_s4_c', 'warmup', 3, 'cercles_hanches', 2, null, null),
  ('rf_s4_c', 'warmup', 4, 'rotations_buste', 2, null, null),
  ('rf_s4_c', 'warmup', 5, 'plus_grand_etirement', 1, 40, null),
  ('rf_s4_c', 'main', 1, 'step_jacks', 3, null, null),
  ('rf_s4_c', 'main', 2, 'squat', 3, null, null),
  ('rf_s4_c', 'main', 3, 'boxe_ombre', 3, null, null),
  ('rf_s4_c', 'main', 4, 'mountain_climbers_lents', 3, null, null),
  ('rf_s4_c', 'main', 5, 'burpee_sans_saut', 2, null, null),
  ('rf_s4_c', 'main', 6, 'patineur_sans_saut', 2, null, null),
  ('rf_s4_c', 'cooldown', 1, 'quadriceps_debout', 2, null, null),
  ('rf_s4_c', 'cooldown', 2, 'mollets', 1, null, null),
  ('rf_s4_c', 'cooldown', 3, 'etirement_lateral', 1, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'rf_s4_c' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('hf_s1_a', 'Fessiers : les bases', null, 'programme', 1, array['fessiers']::text[], null, 2, 15, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'hf_s1_a'
  and exists (select 1 from public.trainings where id = 'hf_s1_a' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('hf_s1_a', 'warmup', 1, 'marche_genoux_hauts', 1, 40, null),
  ('hf_s1_a', 'warmup', 2, 'cercles_hanches', 1, null, null),
  ('hf_s1_a', 'warmup', 3, 'balancier_jambes', 1, 30, null),
  ('hf_s1_a', 'warmup', 4, 'squat', 1, 8, null),
  ('hf_s1_a', 'main', 1, 'pont', 1, null, null),
  ('hf_s1_a', 'main', 2, 'clamshell', 1, null, null),
  ('hf_s1_a', 'main', 3, 'ruade', 1, null, null),
  ('hf_s1_a', 'main', 4, 'abduction_couchee', 1, null, null),
  ('hf_s1_a', 'cooldown', 1, 'fessiers_4', 1, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'hf_s1_a' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('hf_s1_b', 'Jambes et fessiers', null, 'programme', 1, array['jambes', 'fessiers']::text[], null, 2, 15, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'hf_s1_b'
  and exists (select 1 from public.trainings where id = 'hf_s1_b' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('hf_s1_b', 'warmup', 1, 'marche_genoux_hauts', 1, 40, null),
  ('hf_s1_b', 'warmup', 2, 'cercles_hanches', 1, null, null),
  ('hf_s1_b', 'warmup', 3, 'balancier_jambes', 1, 30, null),
  ('hf_s1_b', 'warmup', 4, 'squat', 1, 8, null),
  ('hf_s1_b', 'main', 1, 'squat_sumo', 1, null, null),
  ('hf_s1_b', 'main', 2, 'fente_arriere', 1, null, null),
  ('hf_s1_b', 'main', 3, 'bouche_incendie', 1, null, null),
  ('hf_s1_b', 'main', 4, 'releve_mollets', 1, null, null),
  ('hf_s1_b', 'cooldown', 1, 'quadriceps_debout', 1, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'hf_s1_b' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('hf_s1_c', 'Fessiers et abdos', null, 'programme', 1, array['fessiers', 'abdos']::text[], null, 2, 15, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'hf_s1_c'
  and exists (select 1 from public.trainings where id = 'hf_s1_c' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('hf_s1_c', 'warmup', 1, 'marche_genoux_hauts', 1, 40, null),
  ('hf_s1_c', 'warmup', 2, 'cercles_hanches', 1, null, null),
  ('hf_s1_c', 'warmup', 3, 'rotations_buste', 1, null, null),
  ('hf_s1_c', 'main', 1, 'pont_marche', 1, null, null),
  ('hf_s1_c', 'main', 2, 'dead_bug', 1, null, null),
  ('hf_s1_c', 'main', 3, 'adducteurs_couche', 1, null, null),
  ('hf_s1_c', 'main', 4, 'crunch_inverse', 1, null, null),
  ('hf_s1_c', 'cooldown', 1, 'papillon', 1, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'hf_s1_c' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('hf_s2_a', 'Fessiers : volume', null, 'programme', 1, array['fessiers']::text[], null, 2, 15, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'hf_s2_a'
  and exists (select 1 from public.trainings where id = 'hf_s2_a' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('hf_s2_a', 'warmup', 1, 'marche_genoux_hauts', 1, 40, null),
  ('hf_s2_a', 'warmup', 2, 'cercles_hanches', 1, null, null),
  ('hf_s2_a', 'warmup', 3, 'balancier_jambes', 1, 30, null),
  ('hf_s2_a', 'warmup', 4, 'squat', 1, 8, null),
  ('hf_s2_a', 'main', 1, 'pont', 2, null, null),
  ('hf_s2_a', 'main', 2, 'hip_thrust', 1, null, null),
  ('hf_s2_a', 'main', 3, 'clamshell', 2, null, null),
  ('hf_s2_a', 'main', 4, 'ruade', 2, null, null),
  ('hf_s2_a', 'main', 5, 'abduction_couchee', 2, null, null),
  ('hf_s2_a', 'cooldown', 1, 'fessiers_4', 1, null, null),
  ('hf_s2_a', 'cooldown', 2, 'flechisseurs', 1, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'hf_s2_a' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('hf_s2_b', 'Jambes et fessiers', null, 'programme', 1, array['jambes', 'fessiers']::text[], null, 2, 15, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'hf_s2_b'
  and exists (select 1 from public.trainings where id = 'hf_s2_b' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('hf_s2_b', 'warmup', 1, 'marche_genoux_hauts', 1, 40, null),
  ('hf_s2_b', 'warmup', 2, 'cercles_hanches', 1, null, null),
  ('hf_s2_b', 'warmup', 3, 'balancier_jambes', 1, 30, null),
  ('hf_s2_b', 'warmup', 4, 'squat', 1, 8, null),
  ('hf_s2_b', 'main', 1, 'squat_sumo', 1, null, null),
  ('hf_s2_b', 'main', 2, 'fente_arriere', 2, null, null),
  ('hf_s2_b', 'main', 3, 'charniere_hanche', 1, null, null),
  ('hf_s2_b', 'main', 4, 'bouche_incendie', 2, null, null),
  ('hf_s2_b', 'main', 5, 'releve_mollets', 2, null, null),
  ('hf_s2_b', 'cooldown', 1, 'quadriceps_debout', 1, null, null),
  ('hf_s2_b', 'cooldown', 2, 'ischios', 1, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'hf_s2_b' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('hf_s2_c', 'Fessiers, abdos et cardio', null, 'programme', 1, array['fessiers', 'abdos']::text[], null, 2, 15, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'hf_s2_c'
  and exists (select 1 from public.trainings where id = 'hf_s2_c' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('hf_s2_c', 'warmup', 1, 'marche_genoux_hauts', 1, 40, null),
  ('hf_s2_c', 'warmup', 2, 'cercles_hanches', 1, null, null),
  ('hf_s2_c', 'warmup', 3, 'rotations_buste', 1, null, null),
  ('hf_s2_c', 'main', 1, 'pont_marche', 2, null, null),
  ('hf_s2_c', 'main', 2, 'patineur_sans_saut', 1, null, null),
  ('hf_s2_c', 'main', 3, 'dead_bug', 2, null, null),
  ('hf_s2_c', 'main', 4, 'adducteurs_couche', 2, null, null),
  ('hf_s2_c', 'main', 5, 'squat_coup_de_pied', 1, null, null),
  ('hf_s2_c', 'cooldown', 1, 'papillon', 2, null, null),
  ('hf_s2_c', 'cooldown', 2, 'fessiers_4', 1, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'hf_s2_c' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('hf_s3_a', 'Fessiers : force', null, 'programme', 1, array['fessiers']::text[], null, 3, 15, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'hf_s3_a'
  and exists (select 1 from public.trainings where id = 'hf_s3_a' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('hf_s3_a', 'warmup', 1, 'marche_genoux_hauts', 1, 40, null),
  ('hf_s3_a', 'warmup', 2, 'cercles_hanches', 1, null, null),
  ('hf_s3_a', 'warmup', 3, 'balancier_jambes', 1, 30, null),
  ('hf_s3_a', 'warmup', 4, 'squat', 1, 8, null),
  ('hf_s3_a', 'main', 1, 'hip_thrust', 2, null, null),
  ('hf_s3_a', 'main', 2, 'pont_unilateral', 1, null, null),
  ('hf_s3_a', 'main', 3, 'clamshell', 3, null, null),
  ('hf_s3_a', 'main', 4, 'ruade', 3, null, null),
  ('hf_s3_a', 'main', 5, 'abduction_couchee', 3, null, null),
  ('hf_s3_a', 'cooldown', 1, 'fessiers_4', 2, null, null),
  ('hf_s3_a', 'cooldown', 2, 'flechisseurs', 2, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'hf_s3_a' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('hf_s3_b', 'Jambes et fessiers', null, 'programme', 1, array['jambes', 'fessiers']::text[], null, 3, 15, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'hf_s3_b'
  and exists (select 1 from public.trainings where id = 'hf_s3_b' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('hf_s3_b', 'warmup', 1, 'marche_genoux_hauts', 1, 40, null),
  ('hf_s3_b', 'warmup', 2, 'cercles_hanches', 1, null, null),
  ('hf_s3_b', 'warmup', 3, 'balancier_jambes', 1, 30, null),
  ('hf_s3_b', 'warmup', 4, 'squat', 1, 8, null),
  ('hf_s3_b', 'main', 1, 'squat_sumo', 2, null, null),
  ('hf_s3_b', 'main', 2, 'fente_laterale', 2, null, null),
  ('hf_s3_b', 'main', 3, 'charniere_hanche', 2, null, null),
  ('hf_s3_b', 'main', 4, 'fente_arriere', 2, null, null),
  ('hf_s3_b', 'main', 5, 'releve_mollets', 2, null, null),
  ('hf_s3_b', 'cooldown', 1, 'quadriceps_debout', 2, null, null),
  ('hf_s3_b', 'cooldown', 2, 'ischios', 2, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'hf_s3_b' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('hf_s3_c', 'Fessiers, abdos et cardio', null, 'programme', 1, array['fessiers', 'abdos']::text[], null, 3, 15, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'hf_s3_c'
  and exists (select 1 from public.trainings where id = 'hf_s3_c' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('hf_s3_c', 'warmup', 1, 'marche_genoux_hauts', 2, null, null),
  ('hf_s3_c', 'warmup', 2, 'cercles_hanches', 1, null, null),
  ('hf_s3_c', 'warmup', 3, 'rotations_buste', 1, null, null),
  ('hf_s3_c', 'warmup', 4, 'balancier_jambes', 1, 30, null),
  ('hf_s3_c', 'main', 1, 'pont_marche', 2, null, null),
  ('hf_s3_c', 'main', 2, 'patineur_sans_saut', 2, null, null),
  ('hf_s3_c', 'main', 3, 'dead_bug', 2, null, null),
  ('hf_s3_c', 'main', 4, 'bouche_incendie', 2, null, null),
  ('hf_s3_c', 'main', 5, 'squat_coup_de_pied', 2, null, null),
  ('hf_s3_c', 'cooldown', 1, 'papillon', 2, null, null),
  ('hf_s3_c', 'cooldown', 2, 'pigeon', 1, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'hf_s3_c' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('hf_s4_a', 'Fessiers : force', null, 'programme', 2, array['fessiers']::text[], null, 3, 15, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'hf_s4_a'
  and exists (select 1 from public.trainings where id = 'hf_s4_a' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('hf_s4_a', 'warmup', 1, 'marche_genoux_hauts', 1, 40, null),
  ('hf_s4_a', 'warmup', 2, 'cercles_hanches', 2, null, null),
  ('hf_s4_a', 'warmup', 3, 'balancier_jambes', 1, 30, null),
  ('hf_s4_a', 'warmup', 4, 'squat', 1, 8, null),
  ('hf_s4_a', 'main', 1, 'hip_thrust', 2, null, null),
  ('hf_s4_a', 'main', 2, 'pont_unilateral', 2, null, null),
  ('hf_s4_a', 'main', 3, 'clamshell', 3, null, null),
  ('hf_s4_a', 'main', 4, 'ruade', 3, null, null),
  ('hf_s4_a', 'main', 5, 'abduction_couchee', 3, null, null),
  ('hf_s4_a', 'main', 6, 'bouche_incendie', 2, null, null),
  ('hf_s4_a', 'cooldown', 1, 'fessiers_4', 2, null, null),
  ('hf_s4_a', 'cooldown', 2, 'flechisseurs', 2, null, null),
  ('hf_s4_a', 'cooldown', 3, 'pigeon', 1, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'hf_s4_a' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('hf_s4_b', 'Jambes et fessiers', null, 'programme', 2, array['jambes', 'fessiers']::text[], null, 3, 15, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'hf_s4_b'
  and exists (select 1 from public.trainings where id = 'hf_s4_b' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('hf_s4_b', 'warmup', 1, 'marche_genoux_hauts', 1, 40, null),
  ('hf_s4_b', 'warmup', 2, 'cercles_hanches', 2, null, null),
  ('hf_s4_b', 'warmup', 3, 'balancier_jambes', 1, 30, null),
  ('hf_s4_b', 'warmup', 4, 'squat', 1, 8, null),
  ('hf_s4_b', 'main', 1, 'squat_sumo', 3, null, null),
  ('hf_s4_b', 'main', 2, 'fente_laterale', 3, null, null),
  ('hf_s4_b', 'main', 3, 'charniere_hanche', 2, null, null),
  ('hf_s4_b', 'main', 4, 'fente_arriere', 3, null, null),
  ('hf_s4_b', 'main', 5, 'chaise_mur', 1, 30, null),
  ('hf_s4_b', 'main', 6, 'releve_mollets', 3, null, null),
  ('hf_s4_b', 'cooldown', 1, 'quadriceps_debout', 2, null, null),
  ('hf_s4_b', 'cooldown', 2, 'ischios', 2, null, null),
  ('hf_s4_b', 'cooldown', 3, 'mollets', 1, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'hf_s4_b' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('hf_s4_c', 'Fessiers, abdos et cardio', null, 'programme', 2, array['fessiers', 'abdos']::text[], null, 3, 15, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'hf_s4_c'
  and exists (select 1 from public.trainings where id = 'hf_s4_c' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('hf_s4_c', 'warmup', 1, 'marche_genoux_hauts', 2, null, null),
  ('hf_s4_c', 'warmup', 2, 'cercles_hanches', 2, null, null),
  ('hf_s4_c', 'warmup', 3, 'rotations_buste', 2, null, null),
  ('hf_s4_c', 'warmup', 4, 'balancier_jambes', 2, null, null),
  ('hf_s4_c', 'main', 1, 'pont_marche', 3, null, null),
  ('hf_s4_c', 'main', 2, 'patineur_sans_saut', 2, null, null),
  ('hf_s4_c', 'main', 3, 'dead_bug', 3, null, null),
  ('hf_s4_c', 'main', 4, 'bouche_incendie', 3, null, null),
  ('hf_s4_c', 'main', 5, 'squat_coup_de_pied', 2, null, null),
  ('hf_s4_c', 'main', 6, 'adducteurs_couche', 2, null, null),
  ('hf_s4_c', 'main', 7, 'clamshell', 3, null, null),
  ('hf_s4_c', 'cooldown', 1, 'papillon', 3, null, null),
  ('hf_s4_c', 'cooldown', 2, 'pigeon', 1, null, null),
  ('hf_s4_c', 'cooldown', 3, 'bebe_heureux', 1, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'hf_s4_c' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('gc_s1_a', 'Gainage : les bases', null, 'programme', 1, array['abdos']::text[], 'gainage', 2, 15, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'gc_s1_a'
  and exists (select 1 from public.trainings where id = 'gc_s1_a' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('gc_s1_a', 'warmup', 1, 'marche_genoux_hauts', 1, 40, null),
  ('gc_s1_a', 'warmup', 2, 'cercles_bras', 1, null, null),
  ('gc_s1_a', 'warmup', 3, 'cercles_hanches', 1, null, null),
  ('gc_s1_a', 'warmup', 4, 'rotations_buste', 1, null, null),
  ('gc_s1_a', 'main', 1, 'dead_bug', 1, null, null),
  ('gc_s1_a', 'main', 2, 'planche', 1, null, null),
  ('gc_s1_a', 'main', 3, 'bird_dog', 3, null, null),
  ('gc_s1_a', 'main', 4, 'planche_laterale', 1, null, null),
  ('gc_s1_a', 'cooldown', 1, 'cobra', 1, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'gc_s1_a' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('gc_s1_b', 'Poussée et tirage au poids du corps', null, 'programme', 1, array['bras', 'dos', 'epaules']::text[], 'calisthenie', 2, 15, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'gc_s1_b'
  and exists (select 1 from public.trainings where id = 'gc_s1_b' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('gc_s1_b', 'warmup', 1, 'marche_genoux_hauts', 1, 40, null),
  ('gc_s1_b', 'warmup', 2, 'cercles_bras', 1, null, null),
  ('gc_s1_b', 'warmup', 3, 'cercles_hanches', 1, null, null),
  ('gc_s1_b', 'warmup', 4, 'rotations_buste', 1, null, null),
  ('gc_s1_b', 'main', 1, 'pompe_genoux', 1, null, null),
  ('gc_s1_b', 'main', 2, 'superman', 1, null, null),
  ('gc_s1_b', 'main', 3, 'ours_statique', 1, null, null),
  ('gc_s1_b', 'main', 4, 'squat', 1, null, null),
  ('gc_s1_b', 'cooldown', 1, 'enfant', 2, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'gc_s1_b' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('gc_s1_c', 'Abdos et rotation', null, 'programme', 1, array['abdos']::text[], 'gainage', 2, 15, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'gc_s1_c'
  and exists (select 1 from public.trainings where id = 'gc_s1_c' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('gc_s1_c', 'warmup', 1, 'marche_genoux_hauts', 1, 40, null),
  ('gc_s1_c', 'warmup', 2, 'rotations_buste', 1, null, null),
  ('gc_s1_c', 'warmup', 3, 'cercles_hanches', 1, null, null),
  ('gc_s1_c', 'main', 1, 'crunch', 1, null, null),
  ('gc_s1_c', 'main', 2, 'toucher_talons', 1, null, null),
  ('gc_s1_c', 'main', 3, 'crunch_inverse', 1, null, null),
  ('gc_s1_c', 'main', 4, 'mountain_climbers_lents', 1, null, null),
  ('gc_s1_c', 'cooldown', 1, 'torsion_couchee', 1, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'gc_s1_c' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('gc_s2_a', 'Gainage : anti-extension', null, 'programme', 1, array['abdos']::text[], 'gainage', 2, 15, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'gc_s2_a'
  and exists (select 1 from public.trainings where id = 'gc_s2_a' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('gc_s2_a', 'warmup', 1, 'marche_genoux_hauts', 1, 40, null),
  ('gc_s2_a', 'warmup', 2, 'cercles_bras', 1, null, null),
  ('gc_s2_a', 'warmup', 3, 'cercles_hanches', 1, null, null),
  ('gc_s2_a', 'warmup', 4, 'rotations_buste', 1, null, null),
  ('gc_s2_a', 'main', 1, 'dead_bug', 2, null, null),
  ('gc_s2_a', 'main', 2, 'planche', 2, null, null),
  ('gc_s2_a', 'main', 3, 'hollow', 1, null, null),
  ('gc_s2_a', 'main', 4, 'planche_laterale', 2, null, null),
  ('gc_s2_a', 'main', 5, 'ours_statique', 2, null, null),
  ('gc_s2_a', 'main', 6, 'crunch_inverse', 2, null, null),
  ('gc_s2_a', 'cooldown', 1, 'cobra', 2, null, null),
  ('gc_s2_a', 'cooldown', 2, 'enfant', 2, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'gc_s2_a' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('gc_s2_b', 'Poussée et tirage au poids du corps', null, 'programme', 1, array['bras', 'dos', 'epaules']::text[], 'calisthenie', 2, 15, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'gc_s2_b'
  and exists (select 1 from public.trainings where id = 'gc_s2_b' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('gc_s2_b', 'warmup', 1, 'marche_genoux_hauts', 1, 40, null),
  ('gc_s2_b', 'warmup', 2, 'cercles_bras', 1, null, null),
  ('gc_s2_b', 'warmup', 3, 'cercles_hanches', 1, null, null),
  ('gc_s2_b', 'warmup', 4, 'rotations_buste', 1, null, null),
  ('gc_s2_b', 'main', 1, 'pompe_genoux', 2, null, null),
  ('gc_s2_b', 'main', 2, 'superman', 2, null, null),
  ('gc_s2_b', 'main', 3, 'planche_inverse', 1, null, null),
  ('gc_s2_b', 'main', 4, 'ytw', 1, null, null),
  ('gc_s2_b', 'main', 5, 'squat', 2, null, null),
  ('gc_s2_b', 'main', 6, 'chenille', 1, null, null),
  ('gc_s2_b', 'cooldown', 1, 'enfant', 2, null, null),
  ('gc_s2_b', 'cooldown', 2, 'epaule_bras_croise', 1, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'gc_s2_b' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('gc_s2_c', 'Abdos et rotation', null, 'programme', 1, array['abdos']::text[], 'gainage', 2, 15, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'gc_s2_c'
  and exists (select 1 from public.trainings where id = 'gc_s2_c' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('gc_s2_c', 'warmup', 1, 'marche_genoux_hauts', 1, 40, null),
  ('gc_s2_c', 'warmup', 2, 'rotations_buste', 1, null, null),
  ('gc_s2_c', 'warmup', 3, 'cercles_hanches', 1, null, null),
  ('gc_s2_c', 'main', 1, 'crunch_velo', 1, null, null),
  ('gc_s2_c', 'main', 2, 'rotation_russe', 1, null, null),
  ('gc_s2_c', 'main', 3, 'crunch_inverse', 2, null, null),
  ('gc_s2_c', 'main', 4, 'planche_epaules', 1, null, null),
  ('gc_s2_c', 'main', 5, 'mountain_climbers_lents', 2, null, null),
  ('gc_s2_c', 'cooldown', 1, 'torsion_couchee', 1, null, null),
  ('gc_s2_c', 'cooldown', 2, 'cobra', 1, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'gc_s2_c' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('gc_s3_a', 'Gainage : anti-extension', null, 'programme', 1, array['abdos']::text[], 'gainage', 3, 15, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'gc_s3_a'
  and exists (select 1 from public.trainings where id = 'gc_s3_a' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('gc_s3_a', 'warmup', 1, 'marche_genoux_hauts', 2, 45, null),
  ('gc_s3_a', 'warmup', 2, 'cercles_bras', 1, null, null),
  ('gc_s3_a', 'warmup', 3, 'cercles_hanches', 1, null, null),
  ('gc_s3_a', 'warmup', 4, 'rotations_buste', 1, null, null),
  ('gc_s3_a', 'warmup', 5, 'plus_grand_etirement', 1, 40, null),
  ('gc_s3_a', 'main', 1, 'dead_bug', 3, null, null),
  ('gc_s3_a', 'main', 2, 'planche', 3, null, null),
  ('gc_s3_a', 'main', 3, 'hollow', 2, null, null),
  ('gc_s3_a', 'main', 4, 'planche_laterale', 3, null, null),
  ('gc_s3_a', 'main', 5, 'ciseaux', 1, null, null),
  ('gc_s3_a', 'main', 6, 'crunch_inverse', 3, null, null),
  ('gc_s3_a', 'main', 7, 'planche_epaules', 2, null, null),
  ('gc_s3_a', 'cooldown', 1, 'cobra', 2, null, null),
  ('gc_s3_a', 'cooldown', 2, 'enfant', 2, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'gc_s3_a' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('gc_s3_b', 'Poussée et tirage au poids du corps', null, 'programme', 1, array['bras', 'dos', 'epaules']::text[], 'calisthenie', 3, 15, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'gc_s3_b'
  and exists (select 1 from public.trainings where id = 'gc_s3_b' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('gc_s3_b', 'warmup', 1, 'marche_genoux_hauts', 2, 45, null),
  ('gc_s3_b', 'warmup', 2, 'cercles_bras', 1, null, null),
  ('gc_s3_b', 'warmup', 3, 'cercles_hanches', 1, null, null),
  ('gc_s3_b', 'warmup', 4, 'rotations_buste', 1, null, null),
  ('gc_s3_b', 'warmup', 5, 'plus_grand_etirement', 1, 40, null),
  ('gc_s3_b', 'main', 1, 'pompe', 1, null, null),
  ('gc_s3_b', 'main', 2, 'superman', 3, null, null),
  ('gc_s3_b', 'main', 3, 'planche_inverse', 2, null, null),
  ('gc_s3_b', 'main', 4, 'ytw', 2, null, null),
  ('gc_s3_b', 'main', 5, 'chenille', 1, null, null),
  ('gc_s3_b', 'main', 6, 'squat', 3, null, null),
  ('gc_s3_b', 'main', 7, 'planche_epaules', 2, null, null),
  ('gc_s3_b', 'cooldown', 1, 'enfant', 3, null, null),
  ('gc_s3_b', 'cooldown', 2, 'triceps_etirement', 1, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'gc_s3_b' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('gc_s3_c', 'Abdos et rotation', null, 'programme', 1, array['abdos']::text[], 'gainage', 3, 15, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'gc_s3_c'
  and exists (select 1 from public.trainings where id = 'gc_s3_c' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('gc_s3_c', 'warmup', 1, 'marche_genoux_hauts', 2, null, null),
  ('gc_s3_c', 'warmup', 2, 'rotations_buste', 1, null, null),
  ('gc_s3_c', 'warmup', 3, 'cercles_hanches', 1, null, null),
  ('gc_s3_c', 'warmup', 4, 'cercles_bras', 1, null, null),
  ('gc_s3_c', 'main', 1, 'crunch_velo', 2, null, null),
  ('gc_s3_c', 'main', 2, 'rotation_russe', 2, null, null),
  ('gc_s3_c', 'main', 3, 'releve_jambes', 1, null, null),
  ('gc_s3_c', 'main', 4, 'planche_dynamique', 1, null, null),
  ('gc_s3_c', 'main', 5, 'mountain_climbers_lents', 2, null, null),
  ('gc_s3_c', 'cooldown', 1, 'torsion_couchee', 1, null, null),
  ('gc_s3_c', 'cooldown', 2, 'cobra', 2, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'gc_s3_c' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('gc_s4_a', 'Gainage : anti-extension', null, 'programme', 2, array['abdos']::text[], 'gainage', 3, 15, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'gc_s4_a'
  and exists (select 1 from public.trainings where id = 'gc_s4_a' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('gc_s4_a', 'warmup', 1, 'marche_genoux_hauts', 2, 45, null),
  ('gc_s4_a', 'warmup', 2, 'cercles_bras', 2, null, null),
  ('gc_s4_a', 'warmup', 3, 'cercles_hanches', 2, null, null),
  ('gc_s4_a', 'warmup', 4, 'rotations_buste', 2, null, null),
  ('gc_s4_a', 'warmup', 5, 'plus_grand_etirement', 1, 40, null),
  ('gc_s4_a', 'main', 1, 'dead_bug', 4, null, null),
  ('gc_s4_a', 'main', 2, 'planche', 4, null, null),
  ('gc_s4_a', 'main', 3, 'hollow', 2, null, null),
  ('gc_s4_a', 'main', 4, 'planche_laterale', 3, null, null),
  ('gc_s4_a', 'main', 5, 'ciseaux', 2, null, null),
  ('gc_s4_a', 'main', 6, 'ours_statique', 3, null, null),
  ('gc_s4_a', 'main', 7, 'releve_jambes', 2, null, null),
  ('gc_s4_a', 'main', 8, 'planche_laterale_rotation', 1, null, null),
  ('gc_s4_a', 'cooldown', 1, 'cobra', 3, null, null),
  ('gc_s4_a', 'cooldown', 2, 'enfant', 3, null, null),
  ('gc_s4_a', 'cooldown', 3, 'genoux_poitrine', 2, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'gc_s4_a' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('gc_s4_b', 'Poussée et tirage au poids du corps', null, 'programme', 2, array['bras', 'dos', 'epaules']::text[], 'calisthenie', 3, 15, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'gc_s4_b'
  and exists (select 1 from public.trainings where id = 'gc_s4_b' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('gc_s4_b', 'warmup', 1, 'marche_genoux_hauts', 2, 45, null),
  ('gc_s4_b', 'warmup', 2, 'cercles_bras', 2, null, null),
  ('gc_s4_b', 'warmup', 3, 'cercles_hanches', 2, null, null),
  ('gc_s4_b', 'warmup', 4, 'rotations_buste', 2, null, null),
  ('gc_s4_b', 'warmup', 5, 'plus_grand_etirement', 1, 40, null),
  ('gc_s4_b', 'main', 1, 'pompe', 2, null, null),
  ('gc_s4_b', 'main', 2, 'superman', 3, null, null),
  ('gc_s4_b', 'main', 3, 'planche_inverse', 2, null, null),
  ('gc_s4_b', 'main', 4, 'pompe_pike', 1, null, null),
  ('gc_s4_b', 'main', 5, 'ytw', 3, null, null),
  ('gc_s4_b', 'main', 6, 'chenille', 2, null, null),
  ('gc_s4_b', 'main', 7, 'squat', 3, null, null),
  ('gc_s4_b', 'main', 8, 'ours_statique', 3, null, null),
  ('gc_s4_b', 'cooldown', 1, 'enfant', 3, null, null),
  ('gc_s4_b', 'cooldown', 2, 'triceps_etirement', 2, null, null),
  ('gc_s4_b', 'cooldown', 3, 'epaule_bras_croise', 2, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'gc_s4_b' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('gc_s4_c', 'Abdos et rotation', null, 'programme', 2, array['abdos']::text[], 'gainage', 3, 15, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'gc_s4_c'
  and exists (select 1 from public.trainings where id = 'gc_s4_c' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('gc_s4_c', 'warmup', 1, 'marche_genoux_hauts', 2, null, null),
  ('gc_s4_c', 'warmup', 2, 'rotations_buste', 2, null, null),
  ('gc_s4_c', 'warmup', 3, 'cercles_hanches', 2, null, null),
  ('gc_s4_c', 'warmup', 4, 'cercles_bras', 2, null, null),
  ('gc_s4_c', 'warmup', 5, 'chat_vache', 1, null, null),
  ('gc_s4_c', 'main', 1, 'crunch_velo', 3, null, null),
  ('gc_s4_c', 'main', 2, 'rotation_russe', 3, null, null),
  ('gc_s4_c', 'main', 3, 'releve_jambes', 2, null, null),
  ('gc_s4_c', 'main', 4, 'planche_dynamique', 2, null, null),
  ('gc_s4_c', 'main', 5, 'planche_laterale_rotation', 1, null, null),
  ('gc_s4_c', 'main', 6, 'mountain_climbers_lents', 3, null, null),
  ('gc_s4_c', 'cooldown', 1, 'torsion_couchee', 1, null, null),
  ('gc_s4_c', 'cooldown', 2, 'cobra', 2, null, null),
  ('gc_s4_c', 'cooldown', 3, 'genoux_poitrine', 2, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'gc_s4_c' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('rapide_corps_entier_1', 'Corps entier, débutant', null, 'rapide', 1, array['corps_entier']::text[], null, 2, 15, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'rapide_corps_entier_1'
  and exists (select 1 from public.trainings where id = 'rapide_corps_entier_1' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('rapide_corps_entier_1', 'warmup', 1, 'marche_genoux_hauts', 1, 30, null),
  ('rapide_corps_entier_1', 'warmup', 2, 'cercles_bras', 1, null, null),
  ('rapide_corps_entier_1', 'main', 1, 'squat', 1, null, null),
  ('rapide_corps_entier_1', 'main', 2, 'pompe_genoux', 1, null, null),
  ('rapide_corps_entier_1', 'main', 3, 'pont', 1, null, null),
  ('rapide_corps_entier_1', 'main', 4, 'planche', 1, null, null),
  ('rapide_corps_entier_1', 'cooldown', 1, 'enfant', 1, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'rapide_corps_entier_1' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('rapide_corps_entier_2', 'Corps entier, intermédiaire', null, 'rapide', 2, array['corps_entier']::text[], null, 2, 15, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'rapide_corps_entier_2'
  and exists (select 1 from public.trainings where id = 'rapide_corps_entier_2' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('rapide_corps_entier_2', 'warmup', 1, 'marche_genoux_hauts', 1, 40, null),
  ('rapide_corps_entier_2', 'warmup', 2, 'cercles_bras', 2, null, null),
  ('rapide_corps_entier_2', 'warmup', 3, 'cercles_hanches', 2, null, null),
  ('rapide_corps_entier_2', 'warmup', 4, 'rotations_buste', 2, null, null),
  ('rapide_corps_entier_2', 'main', 1, 'squat', 2, null, null),
  ('rapide_corps_entier_2', 'main', 2, 'pompe_genoux', 3, null, null),
  ('rapide_corps_entier_2', 'main', 3, 'fente_arriere', 2, null, null),
  ('rapide_corps_entier_2', 'main', 4, 'mountain_climbers_lents', 2, null, null),
  ('rapide_corps_entier_2', 'main', 5, 'superman', 2, null, null),
  ('rapide_corps_entier_2', 'cooldown', 1, 'enfant', 2, null, null),
  ('rapide_corps_entier_2', 'cooldown', 2, 'quadriceps_debout', 1, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'rapide_corps_entier_2' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('rapide_corps_entier_3', 'Corps entier, avancé', null, 'rapide', 3, array['corps_entier']::text[], null, 3, 15, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'rapide_corps_entier_3'
  and exists (select 1 from public.trainings where id = 'rapide_corps_entier_3' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('rapide_corps_entier_3', 'warmup', 1, 'marche_genoux_hauts', 1, 40, null),
  ('rapide_corps_entier_3', 'warmup', 2, 'cercles_bras', 3, null, null),
  ('rapide_corps_entier_3', 'warmup', 3, 'cercles_hanches', 3, null, null),
  ('rapide_corps_entier_3', 'warmup', 4, 'rotations_buste', 3, null, null),
  ('rapide_corps_entier_3', 'main', 1, 'squat_saute', 2, null, null),
  ('rapide_corps_entier_3', 'main', 2, 'pompe', 2, null, null),
  ('rapide_corps_entier_3', 'main', 3, 'fente_arriere', 3, null, null),
  ('rapide_corps_entier_3', 'main', 4, 'burpee', 1, null, null),
  ('rapide_corps_entier_3', 'main', 5, 'planche_dynamique', 2, null, null),
  ('rapide_corps_entier_3', 'main', 6, 'jumping_jacks', 2, null, null),
  ('rapide_corps_entier_3', 'cooldown', 1, 'enfant', 2, null, null),
  ('rapide_corps_entier_3', 'cooldown', 2, 'quadriceps_debout', 1, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'rapide_corps_entier_3' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('rapide_abdos_1', 'Abdos, débutant', null, 'rapide', 1, array['abdos']::text[], null, 2, 15, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'rapide_abdos_1'
  and exists (select 1 from public.trainings where id = 'rapide_abdos_1' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('rapide_abdos_1', 'warmup', 1, 'rotations_buste', 1, null, null),
  ('rapide_abdos_1', 'warmup', 2, 'cercles_hanches', 1, null, null),
  ('rapide_abdos_1', 'main', 1, 'dead_bug', 1, null, null),
  ('rapide_abdos_1', 'main', 2, 'crunch', 1, null, null),
  ('rapide_abdos_1', 'main', 3, 'planche', 1, null, null),
  ('rapide_abdos_1', 'main', 4, 'crunch_inverse', 1, null, null),
  ('rapide_abdos_1', 'cooldown', 1, 'cobra', 1, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'rapide_abdos_1' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('rapide_abdos_2', 'Abdos, intermédiaire', null, 'rapide', 2, array['abdos']::text[], null, 2, 15, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'rapide_abdos_2'
  and exists (select 1 from public.trainings where id = 'rapide_abdos_2' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('rapide_abdos_2', 'warmup', 1, 'marche_genoux_hauts', 1, 40, null),
  ('rapide_abdos_2', 'warmup', 2, 'rotations_buste', 2, null, null),
  ('rapide_abdos_2', 'warmup', 3, 'cercles_hanches', 2, null, null),
  ('rapide_abdos_2', 'main', 1, 'crunch_velo', 2, null, null),
  ('rapide_abdos_2', 'main', 2, 'planche', 3, null, null),
  ('rapide_abdos_2', 'main', 3, 'rotation_russe', 2, null, null),
  ('rapide_abdos_2', 'main', 4, 'ciseaux', 1, null, null),
  ('rapide_abdos_2', 'main', 5, 'planche_laterale', 2, null, null),
  ('rapide_abdos_2', 'cooldown', 1, 'cobra', 2, null, null),
  ('rapide_abdos_2', 'cooldown', 2, 'torsion_couchee', 1, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'rapide_abdos_2' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('rapide_abdos_3', 'Abdos, avancé', null, 'rapide', 3, array['abdos']::text[], null, 3, 15, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'rapide_abdos_3'
  and exists (select 1 from public.trainings where id = 'rapide_abdos_3' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('rapide_abdos_3', 'warmup', 1, 'marche_genoux_hauts', 2, null, null),
  ('rapide_abdos_3', 'warmup', 2, 'rotations_buste', 3, null, null),
  ('rapide_abdos_3', 'warmup', 3, 'cercles_hanches', 3, null, null),
  ('rapide_abdos_3', 'main', 1, 'hollow', 3, null, null),
  ('rapide_abdos_3', 'main', 2, 'v_up', 1, null, null),
  ('rapide_abdos_3', 'main', 3, 'planche_dynamique', 2, null, null),
  ('rapide_abdos_3', 'main', 4, 'rotation_russe', 3, null, null),
  ('rapide_abdos_3', 'main', 5, 'releve_jambes', 3, null, null),
  ('rapide_abdos_3', 'main', 6, 'mountain_climbers', 2, null, null),
  ('rapide_abdos_3', 'cooldown', 1, 'cobra', 2, null, null),
  ('rapide_abdos_3', 'cooldown', 2, 'torsion_couchee', 1, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'rapide_abdos_3' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('rapide_jambes_1', 'Jambes, débutant', null, 'rapide', 1, array['jambes']::text[], null, 2, 15, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'rapide_jambes_1'
  and exists (select 1 from public.trainings where id = 'rapide_jambes_1' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('rapide_jambes_1', 'warmup', 1, 'marche_genoux_hauts', 1, 30, null),
  ('rapide_jambes_1', 'warmup', 2, 'cercles_hanches', 1, null, null),
  ('rapide_jambes_1', 'main', 1, 'squat', 1, null, null),
  ('rapide_jambes_1', 'main', 2, 'fente_arriere', 1, null, null),
  ('rapide_jambes_1', 'main', 3, 'releve_mollets', 1, null, null),
  ('rapide_jambes_1', 'main', 4, 'pont', 1, null, null),
  ('rapide_jambes_1', 'cooldown', 1, 'quadriceps_debout', 1, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'rapide_jambes_1' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('rapide_jambes_2', 'Jambes, intermédiaire', null, 'rapide', 2, array['jambes']::text[], null, 2, 15, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'rapide_jambes_2'
  and exists (select 1 from public.trainings where id = 'rapide_jambes_2' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('rapide_jambes_2', 'warmup', 1, 'marche_genoux_hauts', 1, 40, null),
  ('rapide_jambes_2', 'warmup', 2, 'cercles_hanches', 2, null, null),
  ('rapide_jambes_2', 'warmup', 3, 'balancier_jambes', 1, 30, null),
  ('rapide_jambes_2', 'warmup', 4, 'squat', 1, 8, null),
  ('rapide_jambes_2', 'main', 1, 'squat_sumo', 2, null, null),
  ('rapide_jambes_2', 'main', 2, 'fente_laterale', 2, null, null),
  ('rapide_jambes_2', 'main', 3, 'charniere_hanche', 2, null, null),
  ('rapide_jambes_2', 'main', 4, 'pont_unilateral', 1, null, null),
  ('rapide_jambes_2', 'main', 5, 'releve_mollets', 2, null, null),
  ('rapide_jambes_2', 'cooldown', 1, 'quadriceps_debout', 1, null, null),
  ('rapide_jambes_2', 'cooldown', 2, 'ischios', 1, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'rapide_jambes_2' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('rapide_jambes_3', 'Jambes, avancé', null, 'rapide', 3, array['jambes']::text[], null, 3, 15, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'rapide_jambes_3'
  and exists (select 1 from public.trainings where id = 'rapide_jambes_3' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('rapide_jambes_3', 'warmup', 1, 'marche_genoux_hauts', 1, 40, null),
  ('rapide_jambes_3', 'warmup', 2, 'cercles_hanches', 3, null, null),
  ('rapide_jambes_3', 'warmup', 3, 'balancier_jambes', 1, 30, null),
  ('rapide_jambes_3', 'warmup', 4, 'squat', 1, 8, null),
  ('rapide_jambes_3', 'main', 1, 'squat_saute', 2, null, null),
  ('rapide_jambes_3', 'main', 2, 'fente_arriere', 3, null, null),
  ('rapide_jambes_3', 'main', 3, 'fente_laterale', 3, null, null),
  ('rapide_jambes_3', 'main', 4, 'pont_unilateral', 2, null, null),
  ('rapide_jambes_3', 'main', 5, 'patineur', 2, null, null),
  ('rapide_jambes_3', 'cooldown', 1, 'quadriceps_debout', 2, null, null),
  ('rapide_jambes_3', 'cooldown', 2, 'ischios', 2, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'rapide_jambes_3' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('rapide_bras_1', 'Bras, débutant', null, 'rapide', 1, array['bras']::text[], null, 2, 15, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'rapide_bras_1'
  and exists (select 1 from public.trainings where id = 'rapide_bras_1' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('rapide_bras_1', 'warmup', 1, 'cercles_bras', 1, null, null),
  ('rapide_bras_1', 'warmup', 2, 'marche_genoux_hauts', 1, 30, null),
  ('rapide_bras_1', 'main', 1, 'pompe_genoux', 1, null, null),
  ('rapide_bras_1', 'main', 2, 'planche_inverse', 1, null, null),
  ('rapide_bras_1', 'main', 3, 'boxe_ombre', 1, null, null),
  ('rapide_bras_1', 'main', 4, 'ours_statique', 1, null, null),
  ('rapide_bras_1', 'cooldown', 1, 'triceps_etirement', 1, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'rapide_bras_1' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('rapide_bras_2', 'Bras, intermédiaire', null, 'rapide', 2, array['bras']::text[], null, 2, 15, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'rapide_bras_2'
  and exists (select 1 from public.trainings where id = 'rapide_bras_2' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('rapide_bras_2', 'warmup', 1, 'cercles_bras', 2, null, null),
  ('rapide_bras_2', 'warmup', 2, 'marche_genoux_hauts', 1, 40, null),
  ('rapide_bras_2', 'warmup', 3, 'rotations_buste', 2, null, null),
  ('rapide_bras_2', 'main', 1, 'pompe_genoux', 3, null, null),
  ('rapide_bras_2', 'main', 2, 'planche_inverse', 2, null, null),
  ('rapide_bras_2', 'main', 3, 'boxe_ombre', 2, null, null),
  ('rapide_bras_2', 'main', 4, 'pompe', 1, null, null),
  ('rapide_bras_2', 'main', 5, 'planche_dynamique', 1, null, null),
  ('rapide_bras_2', 'main', 6, 'ours_statique', 2, null, null),
  ('rapide_bras_2', 'cooldown', 1, 'triceps_etirement', 1, null, null),
  ('rapide_bras_2', 'cooldown', 2, 'epaule_bras_croise', 1, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'rapide_bras_2' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('rapide_bras_3', 'Bras, avancé', null, 'rapide', 3, array['bras']::text[], null, 3, 15, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'rapide_bras_3'
  and exists (select 1 from public.trainings where id = 'rapide_bras_3' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('rapide_bras_3', 'warmup', 1, 'cercles_bras', 3, null, null),
  ('rapide_bras_3', 'warmup', 2, 'marche_genoux_hauts', 2, null, null),
  ('rapide_bras_3', 'warmup', 3, 'rotations_buste', 3, null, null),
  ('rapide_bras_3', 'main', 1, 'pompe', 3, null, null),
  ('rapide_bras_3', 'main', 2, 'pompe_serree', 2, null, null),
  ('rapide_bras_3', 'main', 3, 'planche_inverse', 3, null, null),
  ('rapide_bras_3', 'main', 4, 'pompe_pike', 1, null, null),
  ('rapide_bras_3', 'main', 5, 'planche_dynamique', 2, null, null),
  ('rapide_bras_3', 'main', 6, 'boxe_ombre', 3, null, null),
  ('rapide_bras_3', 'cooldown', 1, 'triceps_etirement', 2, null, null),
  ('rapide_bras_3', 'cooldown', 2, 'epaule_bras_croise', 2, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'rapide_bras_3' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('rapide_epaules_1', 'Épaules, débutant', null, 'rapide', 1, array['epaules']::text[], null, 2, 15, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'rapide_epaules_1'
  and exists (select 1 from public.trainings where id = 'rapide_epaules_1' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('rapide_epaules_1', 'warmup', 1, 'cercles_bras', 1, null, null),
  ('rapide_epaules_1', 'warmup', 2, 'rotations_buste', 1, null, null),
  ('rapide_epaules_1', 'main', 1, 'ytw', 1, null, null),
  ('rapide_epaules_1', 'main', 2, 'ours_statique', 1, null, null),
  ('rapide_epaules_1', 'main', 3, 'boxe_ombre', 1, null, null),
  ('rapide_epaules_1', 'main', 4, 'planche', 1, null, null),
  ('rapide_epaules_1', 'cooldown', 1, 'epaule_bras_croise', 1, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'rapide_epaules_1' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('rapide_epaules_2', 'Épaules, intermédiaire', null, 'rapide', 2, array['epaules']::text[], null, 2, 15, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'rapide_epaules_2'
  and exists (select 1 from public.trainings where id = 'rapide_epaules_2' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('rapide_epaules_2', 'warmup', 1, 'cercles_bras', 2, null, null),
  ('rapide_epaules_2', 'warmup', 2, 'marche_genoux_hauts', 1, 40, null),
  ('rapide_epaules_2', 'warmup', 3, 'rotations_buste', 2, null, null),
  ('rapide_epaules_2', 'main', 1, 'ytw', 2, null, null),
  ('rapide_epaules_2', 'main', 2, 'planche_epaules', 2, null, null),
  ('rapide_epaules_2', 'main', 3, 'pompe_genoux', 2, null, null),
  ('rapide_epaules_2', 'main', 4, 'boxe_ombre', 2, null, null),
  ('rapide_epaules_2', 'main', 5, 'ours_statique', 2, null, null),
  ('rapide_epaules_2', 'cooldown', 1, 'epaule_bras_croise', 1, null, null),
  ('rapide_epaules_2', 'cooldown', 2, 'chien_tete_bas', 1, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'rapide_epaules_2' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('rapide_epaules_3', 'Épaules, avancé', null, 'rapide', 3, array['epaules']::text[], null, 3, 15, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'rapide_epaules_3'
  and exists (select 1 from public.trainings where id = 'rapide_epaules_3' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('rapide_epaules_3', 'warmup', 1, 'cercles_bras', 3, null, null),
  ('rapide_epaules_3', 'warmup', 2, 'marche_genoux_hauts', 2, null, null),
  ('rapide_epaules_3', 'warmup', 3, 'rotations_buste', 3, null, null),
  ('rapide_epaules_3', 'main', 1, 'pompe_pike', 2, null, null),
  ('rapide_epaules_3', 'main', 2, 'ytw', 3, null, null),
  ('rapide_epaules_3', 'main', 3, 'planche_epaules', 3, null, null),
  ('rapide_epaules_3', 'main', 4, 'marche_ours', 2, null, null),
  ('rapide_epaules_3', 'main', 5, 'pompe', 2, null, null),
  ('rapide_epaules_3', 'main', 6, 'boxe_ombre', 3, null, null),
  ('rapide_epaules_3', 'cooldown', 1, 'epaule_bras_croise', 2, null, null),
  ('rapide_epaules_3', 'cooldown', 2, 'chien_tete_bas', 2, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'rapide_epaules_3' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('rapide_dos_1', 'Dos, débutant', null, 'rapide', 1, array['dos']::text[], null, 2, 15, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'rapide_dos_1'
  and exists (select 1 from public.trainings where id = 'rapide_dos_1' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('rapide_dos_1', 'warmup', 1, 'chat_vache', 1, null, null),
  ('rapide_dos_1', 'warmup', 2, 'cercles_bras', 1, null, null),
  ('rapide_dos_1', 'main', 1, 'bird_dog', 3, null, null),
  ('rapide_dos_1', 'main', 2, 'superman', 1, null, null),
  ('rapide_dos_1', 'main', 3, 'pont', 1, null, null),
  ('rapide_dos_1', 'main', 4, 'ytw', 1, null, null),
  ('rapide_dos_1', 'cooldown', 1, 'enfant', 2, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'rapide_dos_1' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('rapide_dos_2', 'Dos, intermédiaire', null, 'rapide', 2, array['dos']::text[], null, 2, 15, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'rapide_dos_2'
  and exists (select 1 from public.trainings where id = 'rapide_dos_2' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('rapide_dos_2', 'warmup', 1, 'chat_vache', 2, null, null),
  ('rapide_dos_2', 'warmup', 2, 'cercles_bras', 2, null, null),
  ('rapide_dos_2', 'warmup', 3, 'rotations_buste', 2, null, null),
  ('rapide_dos_2', 'main', 1, 'superman', 2, null, null),
  ('rapide_dos_2', 'main', 2, 'ytw', 2, null, null),
  ('rapide_dos_2', 'main', 3, 'bird_dog', 4, null, null),
  ('rapide_dos_2', 'main', 4, 'charniere_hanche', 1, null, null),
  ('rapide_dos_2', 'main', 5, 'planche_inverse', 1, null, null),
  ('rapide_dos_2', 'cooldown', 1, 'enfant', 2, null, null),
  ('rapide_dos_2', 'cooldown', 2, 'sphinx', 1, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'rapide_dos_2' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('rapide_dos_3', 'Dos, avancé', null, 'rapide', 3, array['dos']::text[], null, 3, 15, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'rapide_dos_3'
  and exists (select 1 from public.trainings where id = 'rapide_dos_3' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('rapide_dos_3', 'warmup', 1, 'chat_vache', 2, null, null),
  ('rapide_dos_3', 'warmup', 2, 'cercles_bras', 3, null, null),
  ('rapide_dos_3', 'warmup', 3, 'rotations_buste', 3, null, null),
  ('rapide_dos_3', 'warmup', 4, 'plus_grand_etirement', 1, 40, null),
  ('rapide_dos_3', 'main', 1, 'superman', 3, null, null),
  ('rapide_dos_3', 'main', 2, 'ytw', 3, null, null),
  ('rapide_dos_3', 'main', 3, 'planche_inverse', 3, null, null),
  ('rapide_dos_3', 'main', 4, 'charniere_hanche', 3, null, null),
  ('rapide_dos_3', 'main', 5, 'chenille', 2, null, null),
  ('rapide_dos_3', 'main', 6, 'bird_dog', 4, null, null),
  ('rapide_dos_3', 'cooldown', 1, 'enfant', 3, null, null),
  ('rapide_dos_3', 'cooldown', 2, 'sphinx', 2, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'rapide_dos_3' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('decouverte_yoga_matin', 'Yoga du matin', 'Une séquence douce pour réveiller le corps : salutation au soleil et postures debout.', 'decouverte', 1, array['corps_entier']::text[], 'yoga', 1, 5, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'decouverte_yoga_matin'
  and exists (select 1 from public.trainings where id = 'decouverte_yoga_matin' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('decouverte_yoga_matin', 'main', 1, 'montagne', 1, null, null),
  ('decouverte_yoga_matin', 'main', 2, 'chat_vache', 2, null, null),
  ('decouverte_yoga_matin', 'main', 3, 'salutation_soleil', 1, null, null),
  ('decouverte_yoga_matin', 'main', 4, 'chaise_yoga', 1, null, null),
  ('decouverte_yoga_matin', 'main', 5, 'guerrier_1', 1, null, null),
  ('decouverte_yoga_matin', 'main', 6, 'guerrier_2', 1, null, null),
  ('decouverte_yoga_matin', 'main', 7, 'triangle', 1, null, null),
  ('decouverte_yoga_matin', 'main', 8, 'arbre', 1, null, null),
  ('decouverte_yoga_matin', 'main', 9, 'enfant', 2, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'decouverte_yoga_matin' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('decouverte_etirements_soir', 'Étirements du soir', 'Relâcher les tensions de la journée avant de dormir, tout en douceur.', 'decouverte', 1, array['corps_entier']::text[], 'etirement', 1, 5, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'decouverte_etirements_soir'
  and exists (select 1 from public.trainings where id = 'decouverte_etirements_soir' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('decouverte_etirements_soir', 'main', 1, 'etirement_lateral', 1, null, null),
  ('decouverte_etirements_soir', 'main', 2, 'quadriceps_debout', 1, null, null),
  ('decouverte_etirements_soir', 'main', 3, 'sphinx', 1, null, null),
  ('decouverte_etirements_soir', 'main', 4, 'genoux_poitrine', 1, null, null),
  ('decouverte_etirements_soir', 'main', 5, 'fessiers_4', 1, null, null),
  ('decouverte_etirements_soir', 'main', 6, 'ischios', 1, null, null),
  ('decouverte_etirements_soir', 'main', 7, 'torsion_couchee', 1, null, null),
  ('decouverte_etirements_soir', 'main', 8, 'papillon', 1, null, null),
  ('decouverte_etirements_soir', 'main', 9, 'respiration', 1, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'decouverte_etirements_soir' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('decouverte_meditation', 'Méditation guidée', 'Quelques minutes de respiration lente, puis d''attention au souffle.', 'decouverte', 1, '{}'::text[], 'meditation', 1, 5, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'decouverte_meditation'
  and exists (select 1 from public.trainings where id = 'decouverte_meditation' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('decouverte_meditation', 'main', 1, 'coherence_cardiaque', 1, 120, null),
  ('decouverte_meditation', 'main', 2, 'meditation_souffle', 2, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'decouverte_meditation' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('decouverte_gainage_express', 'Gainage express', 'Un gainage court et efficace, quand il ne reste que quelques minutes.', 'decouverte', 1, array['abdos']::text[], 'gainage', 2, 10, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'decouverte_gainage_express'
  and exists (select 1 from public.trainings where id = 'decouverte_gainage_express' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('decouverte_gainage_express', 'main', 1, 'planche', 2, null, null),
  ('decouverte_gainage_express', 'main', 2, 'dead_bug', 2, null, null),
  ('decouverte_gainage_express', 'main', 3, 'planche_laterale', 1, null, null),
  ('decouverte_gainage_express', 'main', 4, 'bird_dog', 3, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'decouverte_gainage_express' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('decouverte_detente_sommeil', 'Détente avant le sommeil', 'Jambes au mur, puis relaxation progressive pour préparer le sommeil.', 'decouverte', 1, '{}'::text[], 'meditation', 1, 5, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'decouverte_detente_sommeil'
  and exists (select 1 from public.trainings where id = 'decouverte_detente_sommeil' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('decouverte_detente_sommeil', 'main', 1, 'jambes_au_mur', 1, null, null),
  ('decouverte_detente_sommeil', 'main', 2, 'relaxation_progressive', 2, null, null),
  ('decouverte_detente_sommeil', 'main', 3, 'coherence_cardiaque', 1, 120, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'decouverte_detente_sommeil' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('decouverte_yoga_hanches', 'Yoga des hanches', 'Ouvrir les hanches après une journée assise.', 'decouverte', 1, array['fessiers', 'jambes']::text[], 'yoga', 1, 5, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'decouverte_yoga_hanches'
  and exists (select 1 from public.trainings where id = 'decouverte_yoga_hanches' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('decouverte_yoga_hanches', 'main', 1, 'chat_vache', 1, null, null),
  ('decouverte_yoga_hanches', 'main', 2, 'fente_basse', 2, null, null),
  ('decouverte_yoga_hanches', 'main', 3, 'guerrier_2', 2, null, null),
  ('decouverte_yoga_hanches', 'main', 4, 'pigeon', 2, null, null),
  ('decouverte_yoga_hanches', 'main', 5, 'papillon', 2, null, null),
  ('decouverte_yoga_hanches', 'main', 6, 'pince_assise', 2, null, null),
  ('decouverte_yoga_hanches', 'main', 7, 'bebe_heureux', 2, null, null),
  ('decouverte_yoga_hanches', 'main', 8, 'torsion_couchee', 1, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'decouverte_yoga_hanches' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('decouverte_scan_corporel', 'Scan corporel', 'Parcourir le corps de la tête aux pieds pour se poser.', 'decouverte', 1, '{}'::text[], 'meditation', 1, 5, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'decouverte_scan_corporel'
  and exists (select 1 from public.trainings where id = 'decouverte_scan_corporel' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('decouverte_scan_corporel', 'main', 1, 'respiration', 1, null, null),
  ('decouverte_scan_corporel', 'main', 2, 'scan_corporel', 2, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'decouverte_scan_corporel' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('express_reveil', 'Réveil en 4 minutes', 'Mobilité du matin, sans quitter la chambre.', 'express', 1, array['corps_entier']::text[], 'etirement', 1, 5, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'express_reveil'
  and exists (select 1 from public.trainings where id = 'express_reveil' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('express_reveil', 'main', 1, 'cercles_bras', 1, null, null),
  ('express_reveil', 'main', 2, 'rotations_buste', 1, null, null),
  ('express_reveil', 'main', 3, 'cercles_hanches', 1, null, null),
  ('express_reveil', 'main', 4, 'chat_vache', 1, null, null),
  ('express_reveil', 'main', 5, 'squat', 1, 8, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'express_reveil' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('express_cardio', 'Coup de boost cardio', 'Quatre minutes pour se réchauffer, sans saut.', 'express', 1, array['corps_entier']::text[], 'cardio', 2, 10, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'express_cardio'
  and exists (select 1 from public.trainings where id = 'express_cardio' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('express_cardio', 'main', 1, 'step_jacks', 2, 30, null),
  ('express_cardio', 'main', 2, 'boxe_ombre', 1, 30, null),
  ('express_cardio', 'main', 3, 'marche_genoux_hauts', 2, 30, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'express_cardio' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('express_abdos', 'Abdos express', 'Quatre exercices de gainage enchaînés deux fois.', 'express', 1, array['abdos']::text[], 'gainage', 2, 10, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'express_abdos'
  and exists (select 1 from public.trainings where id = 'express_abdos' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('express_abdos', 'main', 1, 'planche', 2, 20, null),
  ('express_abdos', 'main', 2, 'dead_bug', 1, 8, null),
  ('express_abdos', 'main', 3, 'crunch', 1, 12, null),
  ('express_abdos', 'main', 4, 'planche_laterale', 1, 20, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'express_abdos' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('express_jambes', 'Jambes express', 'Squats, fentes et pont : l''essentiel des jambes.', 'express', 1, array['jambes', 'fessiers']::text[], 'renforcement', 2, 10, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'express_jambes'
  and exists (select 1 from public.trainings where id = 'express_jambes' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('express_jambes', 'main', 1, 'squat', 1, 8, null),
  ('express_jambes', 'main', 2, 'fente_arriere', 1, 6, null),
  ('express_jambes', 'main', 3, 'pont', 1, 10, null),
  ('express_jambes', 'main', 4, 'releve_mollets', 1, 10, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'express_jambes' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('express_pause_bureau', 'Pause bureau', 'Dénouer la nuque, les épaules et le dos entre deux réunions.', 'express', 1, array['dos', 'epaules']::text[], 'etirement', 1, 5, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'express_pause_bureau'
  and exists (select 1 from public.trainings where id = 'express_pause_bureau' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('express_pause_bureau', 'main', 1, 'chin_tuck', 1, null, null),
  ('express_pause_bureau', 'main', 2, 'omoplates', 1, null, null),
  ('express_pause_bureau', 'main', 3, 'trapezes', 1, 40, null),
  ('express_pause_bureau', 'main', 4, 'epaule_bras_croise', 1, null, null),
  ('express_pause_bureau', 'main', 5, 'etirement_lateral', 1, 30, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'express_pause_bureau' and approved = false)
on conflict (training_id, phase, position) do nothing;

insert into public.trainings (id, title, description, kind, level, areas, discipline, rounds, rest_seconds, approved, source)
values ('express_respiration', 'Trois minutes pour respirer', 'Respiration lente pour faire redescendre la pression.', 'express', 1, '{}'::text[], 'meditation', 1, 0, false, 'Composé pour l''app (bloc 2 V5), voir docs/CONTENU-V5.md')
on conflict (id) do update set title = excluded.title, description = excluded.description, kind = excluded.kind,
  level = excluded.level, areas = excluded.areas, discipline = excluded.discipline, rounds = excluded.rounds,
  rest_seconds = excluded.rest_seconds, source = excluded.source
where public.trainings.approved = false;
delete from public.training_items where training_id = 'express_respiration'
  and exists (select 1 from public.trainings where id = 'express_respiration' and approved = false);
insert into public.training_items (training_id, phase, position, exercise_id, level, value, sets)
select v.* from (values
  ('express_respiration', 'main', 1, 'coherence_cardiaque', 1, null, null)
) as v(training_id, phase, position, exercise_id, level, value, sets)
where exists (select 1 from public.trainings where id = 'express_respiration' and approved = false)
on conflict (training_id, phase, position) do nothing;

-- ---------------------------------------------------------------- 4. Programmes
insert into public.programs (id, title, description, goals, areas, level, approved, source)
values ('remise_en_forme', 'Remise en forme', '28 jours pour retrouver la forme : bas du corps, haut du corps et cardio doux en alternance, sans matériel et sans saut. Les séances passent de 10 à 25 minutes au fil des semaines.', array['garder_la_forme', 'perdre_du_poids', 'renforcer']::text[], array['corps_entier']::text[], 1, false, 'Composé pour l''app (bloc 2 V5). Repères : OMS 2020 (renforcement au moins 2 jours par semaine, https://pmc.ncbi.nlm.nih.gov/articles/PMC7719906/) ; ACSM 2026, renforcement musculaire et progression (https://acsm.org/science-spotlight-acsm-releases-new-position-stand-on-resistance-training/).')
on conflict (id) do update set title = excluded.title, description = excluded.description, goals = excluded.goals,
  areas = excluded.areas, level = excluded.level, source = excluded.source
where public.programs.approved = false;
delete from public.program_days where program_id = 'remise_en_forme'
  and exists (select 1 from public.programs where id = 'remise_en_forme' and approved = false);
insert into public.program_days (program_id, day, training_id)
select v.* from (values
  ('remise_en_forme', 1, 'rf_s1_a'),
  ('remise_en_forme', 2, 'rf_s1_b'),
  ('remise_en_forme', 3, 'prog_mobilite_s1'),
  ('remise_en_forme', 4, 'rf_s1_c'),
  ('remise_en_forme', 5, 'rf_s1_a'),
  ('remise_en_forme', 6, 'rf_s1_b'),
  ('remise_en_forme', 7, 'prog_recup_s1'),
  ('remise_en_forme', 8, 'rf_s2_a'),
  ('remise_en_forme', 9, 'rf_s2_b'),
  ('remise_en_forme', 10, 'prog_mobilite_s2'),
  ('remise_en_forme', 11, 'rf_s2_c'),
  ('remise_en_forme', 12, 'rf_s2_a'),
  ('remise_en_forme', 13, 'rf_s2_b'),
  ('remise_en_forme', 14, 'prog_recup_s2'),
  ('remise_en_forme', 15, 'rf_s3_a'),
  ('remise_en_forme', 16, 'rf_s3_b'),
  ('remise_en_forme', 17, 'prog_mobilite_s3'),
  ('remise_en_forme', 18, 'rf_s3_c'),
  ('remise_en_forme', 19, 'rf_s3_a'),
  ('remise_en_forme', 20, 'rf_s3_b'),
  ('remise_en_forme', 21, 'prog_recup_s3'),
  ('remise_en_forme', 22, 'rf_s4_a'),
  ('remise_en_forme', 23, 'rf_s4_b'),
  ('remise_en_forme', 24, 'prog_mobilite_s4'),
  ('remise_en_forme', 25, 'rf_s4_c'),
  ('remise_en_forme', 26, 'rf_s4_a'),
  ('remise_en_forme', 27, 'rf_s4_b'),
  ('remise_en_forme', 28, 'prog_recup_s4')
) as v(program_id, day, training_id)
where exists (select 1 from public.programs where id = 'remise_en_forme' and approved = false)
on conflict (program_id, day) do nothing;

insert into public.programs (id, title, description, goals, areas, level, approved, source)
values ('hanches_fessiers', 'Hanches et fessiers', '28 jours pour tonifier les fessiers et les jambes : ponts, fentes, travail de hanche et un peu de cardio, sans matériel et sans saut. De 10 à 25 minutes par séance.', array['tonifier', 'renforcer']::text[], array['fessiers', 'jambes']::text[], 1, false, 'Composé pour l''app (bloc 2 V5). Repères : OMS 2020 (renforcement au moins 2 jours par semaine, https://pmc.ncbi.nlm.nih.gov/articles/PMC7719906/) ; ACSM 2026, renforcement musculaire et progression (https://acsm.org/science-spotlight-acsm-releases-new-position-stand-on-resistance-training/).')
on conflict (id) do update set title = excluded.title, description = excluded.description, goals = excluded.goals,
  areas = excluded.areas, level = excluded.level, source = excluded.source
where public.programs.approved = false;
delete from public.program_days where program_id = 'hanches_fessiers'
  and exists (select 1 from public.programs where id = 'hanches_fessiers' and approved = false);
insert into public.program_days (program_id, day, training_id)
select v.* from (values
  ('hanches_fessiers', 1, 'hf_s1_a'),
  ('hanches_fessiers', 2, 'hf_s1_b'),
  ('hanches_fessiers', 3, 'prog_mobilite_s1'),
  ('hanches_fessiers', 4, 'hf_s1_c'),
  ('hanches_fessiers', 5, 'hf_s1_a'),
  ('hanches_fessiers', 6, 'hf_s1_b'),
  ('hanches_fessiers', 7, 'prog_recup_s1'),
  ('hanches_fessiers', 8, 'hf_s2_a'),
  ('hanches_fessiers', 9, 'hf_s2_b'),
  ('hanches_fessiers', 10, 'prog_mobilite_s2'),
  ('hanches_fessiers', 11, 'hf_s2_c'),
  ('hanches_fessiers', 12, 'hf_s2_a'),
  ('hanches_fessiers', 13, 'hf_s2_b'),
  ('hanches_fessiers', 14, 'prog_recup_s2'),
  ('hanches_fessiers', 15, 'hf_s3_a'),
  ('hanches_fessiers', 16, 'hf_s3_b'),
  ('hanches_fessiers', 17, 'prog_mobilite_s3'),
  ('hanches_fessiers', 18, 'hf_s3_c'),
  ('hanches_fessiers', 19, 'hf_s3_a'),
  ('hanches_fessiers', 20, 'hf_s3_b'),
  ('hanches_fessiers', 21, 'prog_recup_s3'),
  ('hanches_fessiers', 22, 'hf_s4_a'),
  ('hanches_fessiers', 23, 'hf_s4_b'),
  ('hanches_fessiers', 24, 'prog_mobilite_s4'),
  ('hanches_fessiers', 25, 'hf_s4_c'),
  ('hanches_fessiers', 26, 'hf_s4_a'),
  ('hanches_fessiers', 27, 'hf_s4_b'),
  ('hanches_fessiers', 28, 'prog_recup_s4')
) as v(program_id, day, training_id)
where exists (select 1 from public.programs where id = 'hanches_fessiers' and approved = false)
on conflict (program_id, day) do nothing;

insert into public.programs (id, title, description, goals, areas, level, approved, source)
values ('gainage_calisthenie', 'Gainage et calisthénie', '28 jours pour un tronc solide et les bases de la calisthénie : planches, dead bug, pompes et travail du dos au poids du corps. De 10 à 25 minutes par séance.', array['renforcer', 'tonifier']::text[], array['abdos', 'bras', 'dos']::text[], 1, false, 'Composé pour l''app (bloc 2 V5). Repères : OMS 2020 (renforcement au moins 2 jours par semaine, https://pmc.ncbi.nlm.nih.gov/articles/PMC7719906/) ; ACSM 2026, renforcement musculaire et progression (https://acsm.org/science-spotlight-acsm-releases-new-position-stand-on-resistance-training/).')
on conflict (id) do update set title = excluded.title, description = excluded.description, goals = excluded.goals,
  areas = excluded.areas, level = excluded.level, source = excluded.source
where public.programs.approved = false;
delete from public.program_days where program_id = 'gainage_calisthenie'
  and exists (select 1 from public.programs where id = 'gainage_calisthenie' and approved = false);
insert into public.program_days (program_id, day, training_id)
select v.* from (values
  ('gainage_calisthenie', 1, 'gc_s1_a'),
  ('gainage_calisthenie', 2, 'gc_s1_b'),
  ('gainage_calisthenie', 3, 'prog_mobilite_s1'),
  ('gainage_calisthenie', 4, 'gc_s1_c'),
  ('gainage_calisthenie', 5, 'gc_s1_a'),
  ('gainage_calisthenie', 6, 'gc_s1_b'),
  ('gainage_calisthenie', 7, 'prog_recup_s1'),
  ('gainage_calisthenie', 8, 'gc_s2_a'),
  ('gainage_calisthenie', 9, 'gc_s2_b'),
  ('gainage_calisthenie', 10, 'prog_mobilite_s2'),
  ('gainage_calisthenie', 11, 'gc_s2_c'),
  ('gainage_calisthenie', 12, 'gc_s2_a'),
  ('gainage_calisthenie', 13, 'gc_s2_b'),
  ('gainage_calisthenie', 14, 'prog_recup_s2'),
  ('gainage_calisthenie', 15, 'gc_s3_a'),
  ('gainage_calisthenie', 16, 'gc_s3_b'),
  ('gainage_calisthenie', 17, 'prog_mobilite_s3'),
  ('gainage_calisthenie', 18, 'gc_s3_c'),
  ('gainage_calisthenie', 19, 'gc_s3_a'),
  ('gainage_calisthenie', 20, 'gc_s3_b'),
  ('gainage_calisthenie', 21, 'prog_recup_s3'),
  ('gainage_calisthenie', 22, 'gc_s4_a'),
  ('gainage_calisthenie', 23, 'gc_s4_b'),
  ('gainage_calisthenie', 24, 'prog_mobilite_s4'),
  ('gainage_calisthenie', 25, 'gc_s4_c'),
  ('gainage_calisthenie', 26, 'gc_s4_a'),
  ('gainage_calisthenie', 27, 'gc_s4_b'),
  ('gainage_calisthenie', 28, 'prog_recup_s4')
) as v(program_id, day, training_id)
where exists (select 1 from public.programs where id = 'gainage_calisthenie' and approved = false)
on conflict (program_id, day) do nothing;
