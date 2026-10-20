-- =====================================================================
-- Remise à zéro d'Alice après tes tests (à lancer AVANT de lui donner le lien)
-- Efface ses séances et ses journaux, rétablit le programme de départ (niveaux à 1,
-- remplacements annulés), enlève la pause, et génère un NOUVEAU lien (celui de tes tests ne marchera plus).
-- =====================================================================
do $$
declare
  a_id uuid;
begin
  select id into a_id from public.athletes where first_name = 'Alice' order by created_at limit 1;
  if a_id is null then
    raise exception 'Alice introuvable : lance d''abord seed.sql';
  end if;

  delete from public.workouts where athlete_id = a_id;
  delete from public.level_changes where athlete_id = a_id;
  delete from public.program_changes where athlete_id = a_id;
  -- programme de départ rétabli (remplacements, ajouts, retraits et tours remis à zéro)
  delete from public.program_items where athlete_id = a_id;
  perform public._seed_program(a_id);
  update public.athletes
  set frozen = false,
      frozen_at = null,
      coach_message = null,
      start_date = current_date,
      access_token = encode(gen_random_bytes(24), 'hex')
  where id = a_id;
end;
$$;
