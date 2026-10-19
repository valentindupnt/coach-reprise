-- =====================================================================
-- Remise à zéro d'Alice après tes tests (à lancer AVANT de lui donner le lien)
-- Efface ses séances, son journal, remet tous les niveaux à 1, enlève la
-- pause, et génère un NOUVEAU lien (celui de tes tests ne marchera plus).
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
  update public.program_items set level = 1 where athlete_id = a_id;
  update public.athletes
  set frozen = false,
      frozen_at = null,
      coach_message = null,
      start_date = current_date,
      access_token = encode(gen_random_bytes(24), 'hex')
  where id = a_id;
end;
$$;
