-- Cambios en la base de datos: permitir reservar de 8:00 a 22:00
-- salvo las horas que chocan con una clase fija (tabla horario_fijo)

create or replace function public.slots_de(p_room text) returns text[]
 language sql stable security definer set search_path to 'public'
as $f$
  select case when (select tipo from public.salones where code = p_room) = 'lab'
    then array['18:00-19:00','19:00-20:00','20:00-21:00','21:00-22:00']
    else array['08:00-09:00','09:00-10:00','10:00-11:00','11:00-12:00','12:00-13:00','13:00-14:00','14:00-15:00','15:00-16:00','16:00-17:00','17:00-18:00','18:00-19:00','19:00-20:00','20:00-21:00','21:00-22:00'] end
$f$;

create or replace function public.check_rules(p_room text, p_date date, p_slot text, p_uid uuid, p_asist integer, p_excl bigint default null::bigint)
 returns void
 language plpgsql security definer set search_path to 'public'
as $function$
declare s public.salones; ahora timestamp := now() at time zone 'America/Bogota'; v_rol text; mx_d int; mx_a int; h int;
begin
  select * into s from public.salones where code = p_room;
  if not found then raise exception 'El espacio no existe.'; end if;
  if s.activo is false then raise exception 'Este espacio no está disponible para reservas.'; end if;
  if exists (select 1 from public.profiles where id = p_uid and suspendido_hasta > now()) then
    raise exception 'Estás suspendido para reservar por inasistencias reiteradas hasta %.', (select to_char(suspendido_hasta at time zone 'America/Bogota','DD/MM/YYYY HH24:MI') from public.profiles where id = p_uid); end if;
  if not (p_slot = any (public.slots_de(p_room))) then
    raise exception 'Ese horario no está habilitado para este espacio (bloques de 1 hora).'; end if;
  if exists (select 1 from public.horario_fijo hf where hf.code = p_room
       and (split_part(hf.block,'-',1))::int <= split_part(p_slot,':',1)::int
       and (split_part(hf.block,'-',2))::int > split_part(p_slot,':',1)::int) then
    raise exception 'Ese horario está ocupado por una clase fija.'; end if;
  if p_date is null or p_date < ahora::date or p_date > ahora::date + public.regla('dias_ventana') then
    raise exception 'Solo puedes reservar dentro de los próximos % días.', public.regla('dias_ventana'); end if;
  h := split_part(p_slot, ':', 1)::int;
  if p_date = ahora::date and h <= extract(hour from ahora)::int
     and not exists (select 1 from public.bookings where room = p_room and date = p_date and slot = p_slot and estado = 'no_asistio') then
    raise exception 'Esa hora ya pasó.'; end if;
  if p_asist is null or p_asist < 1 then raise exception 'Indica la cantidad de asistentes.'; end if;
  if s.sillas is not null and s.sillas > 0 and p_asist > s.sillas then
    raise exception 'Los % asistentes superan el aforo del espacio (% personas).', p_asist, s.sillas; end if;
  select rol into v_rol from public.profiles where id = p_uid;
  mx_d := public.regla(case when v_rol = 'estudiante' then 'max_dia_estudiante' else 'max_dia_docente' end);
  mx_a := public.regla(case when v_rol = 'estudiante' then 'max_activas_estudiante' else 'max_activas_docente' end);
  if (select count(*) from public.bookings where user_id = p_uid and date = p_date and estado in ('pendiente','confirmada') and id is distinct from p_excl) >= mx_d then
    raise exception 'Superaste el límite de % bloques por día.', mx_d; end if;
  if (select count(*) from public.bookings where user_id = p_uid and date >= ahora::date and estado in ('pendiente','confirmada') and id is distinct from p_excl) >= mx_a then
    raise exception 'Superaste el límite de % reservas activas. Cancela alguna para liberar cupo.', mx_a; end if;
  if exists (select 1 from public.bloqueos where room = p_room and activo and desde < (p_date + (split_part(p_slot, ':', 1) || ':00')::time + interval '1 hour') and hasta > (p_date + (split_part(p_slot, ':', 1) || ':00')::time)) then
    raise exception 'El espacio está bloqueado en ese horario.'; end if;
  if exists (select 1 from public.bookings where room = p_room and date = p_date and slot = p_slot and estado in ('pendiente','confirmada') and id is distinct from p_excl) then
    raise exception 'Ese horario ya fue reservado por otra persona.'; end if;
end $function$;
