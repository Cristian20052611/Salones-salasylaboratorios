-- 10 · Disponibilidad en tiempo real (HU-11.1.1 / RNF11).
-- Cuando cambia una reserva, un bloqueo, el horario, un salón, sus recursos o su software,
-- la base de datos envía un aviso por WebSocket (Supabase Realtime, canal público "ocupacion")
-- y las pantallas abiertas se actualizan solas, sin recargar.
-- El aviso NO lleva datos personales: solo qué tabla cambió y, si aplica, el salón y la fecha.
-- Aditivo e idempotente. Si el aviso falla, la operación (por ejemplo la reserva) se guarda igual.

create or replace function public.rt_aviso_fila() returns trigger
language plpgsql security definer set search_path = public as $$
declare j jsonb;
begin
  j := to_jsonb(case when tg_op = 'DELETE' then old else new end);
  perform realtime.send(
    jsonb_build_object('tabla', tg_table_name, 'room', coalesce(j->>'room', j->>'code'), 'date', j->>'date'),
    'cambio', 'ocupacion', false);
  return null;
exception when others then
  return null;
end $$;

create or replace function public.rt_aviso_tabla() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  perform realtime.send(jsonb_build_object('tabla', tg_table_name), 'cambio', 'ocupacion', false);
  return null;
exception when others then
  return null;
end $$;

-- Reservas y bloqueos: un aviso por fila (son pocas a la vez y conviene saber salón y fecha)
drop trigger if exists rt_bookings on public.bookings;
create trigger rt_bookings after insert or update or delete on public.bookings
  for each row execute function public.rt_aviso_fila();
drop trigger if exists rt_bloqueos on public.bloqueos;
create trigger rt_bloqueos after insert or update or delete on public.bloqueos
  for each row execute function public.rt_aviso_fila();

-- Tablas que pueden cambiar en bloque (carga masiva): un solo aviso por operación
do $$ declare t text; begin
  foreach t in array array['horario_fijo','salones','recursos','software','salon_software'] loop
    if to_regclass('public.' || t) is not null then
      execute format('drop trigger if exists rt_%1$s on public.%1$I', t);
      execute format('create trigger rt_%1$s after insert or update or delete on public.%1$I
                      for each statement execute function public.rt_aviso_tabla()', t);
    end if;
  end loop;
end $$;

revoke execute on function public.rt_aviso_fila(), public.rt_aviso_tabla() from public, anon, authenticated;
