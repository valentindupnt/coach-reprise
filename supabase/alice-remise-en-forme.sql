-- Bloc 1.5 (version simple) : Alice repart de zéro sur le programme « Remise en forme ».
-- À lancer APRÈS content-v5-validation.sql, puis reset-alice.sql (qui efface son historique et crée un NOUVEAU lien).
-- Relançable : l'éventuel programme actif est clôturé avant d'en démarrer un nouveau.
do $$
declare a_id uuid;
begin
  select id into a_id from public.athletes where first_name = 'Alice' order by created_at limit 1;
  if a_id is null then raise exception 'Alice introuvable'; end if;
  if not exists (select 1 from public.programs where id = 'remise_en_forme' and approved) then
    raise exception 'Programme remise_en_forme absent ou non validé : lance content-v5.sql puis content-v5-validation.sql';
  end if;
  update public.athlete_programs set status = 'abandonne', ended_at = now() where athlete_id = a_id and status = 'actif';
  insert into public.athlete_programs (athlete_id, program_id, started_on) values (a_id, 'remise_en_forme', current_date);
end $$;

select a.first_name, a.access_token, ap.program_id, ap.started_on
from public.athletes a join public.athlete_programs ap on ap.athlete_id = a.id and ap.status = 'actif'
where a.first_name = 'Alice';
