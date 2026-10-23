-- FASE 8 · Software instalado por salón (solo salones con computadores).
-- Ejecutar DESPUÉS de fase7-carga-reemplazo.sql (necesita las tablas salones y recursos).
-- Aditivo: no borra datos. Se puede correr más de una vez sin duplicar nada.
-- Los logos están en la carpeta logos/ de la página (se guardan como ruta, ej. 'logos/python.svg').
-- Los que sube el administrador desde el panel se guardan como imagen pequeña dentro de la misma columna.

create table if not exists public.software (
  id bigserial primary key,
  nombre text not null unique,
  logo text,
  activo boolean not null default true,
  created_at timestamptz not null default now()
);
create table if not exists public.salon_software (
  room text not null references public.salones(code) on update cascade on delete cascade,
  software_id bigint not null references public.software(id) on delete cascade,
  primary key (room, software_id)
);
alter table public.software enable row level security;
alter table public.salon_software enable row level security;
drop policy if exists software_leer on public.software;
create policy software_leer on public.software for select using (true);
drop policy if exists salon_software_leer on public.salon_software;
create policy salon_software_leer on public.salon_software for select using (true);
-- Sin políticas de insert/update/delete: solo se escribe con las funciones de abajo (solo administrador).

create or replace function public.es_admin() returns boolean language sql stable security definer set search_path = public as $$
  select coalesce(public.current_rol(),'') = 'administrador' $$;

-- Un salón "tiene computadores" si su campo equipo dice PC:n (n>0) o tiene un recurso Computador activo.
create or replace function public.salon_tiene_pc(p_code text) returns boolean language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.salones s where s.code = p_code and s.equipo ~ 'PC:[1-9]')
      or exists (select 1 from public.recursos r where r.room = p_code and r.activo and r.cantidad > 0 and lower(r.tipo) like 'computador%') $$;

create or replace function public.upsert_software(p_id bigint, p_nombre text, p_logo text) returns bigint
language plpgsql security definer set search_path = public as $$
declare v_id bigint;
begin
  if not public.es_admin() then raise exception 'Solo el administrador puede gestionar el software.'; end if;
  if coalesce(trim(p_nombre), '') = '' then raise exception 'El nombre del software es obligatorio.'; end if;
  if p_logo is not null and length(p_logo) > 400000 then raise exception 'La imagen es demasiado pesada.'; end if;
  if p_id is null then
    insert into public.software(nombre, logo) values (trim(p_nombre), p_logo) returning id into v_id;
  else
    update public.software set nombre = trim(p_nombre), logo = coalesce(p_logo, logo) where id = p_id returning id into v_id;
    if v_id is null then raise exception 'El software no existe.'; end if;
  end if;
  return v_id;
exception when unique_violation then
  raise exception 'Ya existe un software con ese nombre.';
end $$;

create or replace function public.delete_software(p_id bigint) returns void
language plpgsql security definer set search_path = public as $$
begin
  if not public.es_admin() then raise exception 'Solo el administrador puede gestionar el software.'; end if;
  delete from public.software where id = p_id;  -- también lo quita de todos los salones
end $$;

create or replace function public.set_room_software(p_room text, p_ids bigint[]) returns void
language plpgsql security definer set search_path = public as $$
begin
  if not public.es_admin() then raise exception 'Solo el administrador puede gestionar el software.'; end if;
  if not public.salon_tiene_pc(p_room) then raise exception 'Este salón no tiene computadores.'; end if;
  delete from public.salon_software where room = p_room;
  insert into public.salon_software(room, software_id)
    select p_room, s.id from public.software s where s.id = any (coalesce(p_ids, '{}'::bigint[]));
end $$;

grant execute on function public.es_admin(), public.salon_tiene_pc(text), public.upsert_software(bigint,text,text),
  public.delete_software(bigint), public.set_room_software(text,bigint[]) to authenticated;
grant execute on function public.salon_tiene_pc(text) to anon;

-- Catálogo inicial (los 28 logos de la carpeta logos/)
insert into public.software(nombre, logo) values
  ('Android Studio', 'logos/androidstudio.svg'),
  ('Audacity', 'logos/audacity.svg'),
  ('Blender', 'logos/blender.svg'),
  ('Canva', 'logos/canva.svg'),
  ('Docker', 'logos/docker.svg'),
  ('Eclipse IDE', 'logos/eclipseide.svg'),
  ('Figma', 'logos/figma.svg'),
  ('Firefox', 'logos/firefoxbrowser.svg'),
  ('GIMP', 'logos/gimp.svg'),
  ('Git', 'logos/git.svg'),
  ('GitHub', 'logos/github.svg'),
  ('Google Chrome', 'logos/googlechrome.svg'),
  ('Inkscape', 'logos/inkscape.svg'),
  ('IntelliJ IDEA', 'logos/intellijidea.svg'),
  ('Jupyter', 'logos/jupyter.svg'),
  ('Kali Linux', 'logos/kalilinux.svg'),
  ('MongoDB', 'logos/mongodb.svg'),
  ('MySQL', 'logos/mysql.svg'),
  ('Node.js', 'logos/nodedotjs.svg'),
  ('OBS Studio', 'logos/obsstudio.svg'),
  ('PostgreSQL', 'logos/postgresql.svg'),
  ('Postman', 'logos/postman.svg'),
  ('PyCharm', 'logos/pycharm.svg'),
  ('Python', 'logos/python.svg'),
  ('VirtualBox', 'logos/virtualbox.svg'),
  ('Visual Studio Code', 'logos/visualstudiocode.svg'),
  ('Wireshark', 'logos/wireshark.svg'),
  ('Zoom', 'logos/zoom.svg')
on conflict (nombre) do nothing;

-- Asignación AL AZAR (solo la primera vez, si aún no hay nada asignado):
-- cada salón con computadores recibe entre 5 y 9 programas distintos, no todos.
do $$
begin
  if not exists (select 1 from public.salon_software) then
    insert into public.salon_software(room, software_id)
    select r.code, s.id
    from (select code from public.salones where activo and public.salon_tiene_pc(code)) r
    cross join lateral (
      select id from public.software where activo order by random() limit (5 + floor(random() * 5))::int
    ) s;
  end if;
end $$;
