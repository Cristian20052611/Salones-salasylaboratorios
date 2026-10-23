# Documentación: Agenda de Aulas y Laboratorios

Aplicación web (HTML, CSS y JavaScript) con Supabase en una máquina virtual. Este paquete junta en una sola carpeta todas las funciones agregadas hasta ahora.

## Funciones incluidas

1. **Tema institucional y panel del coordinador** (`styles.css`): colores azul marino y dorado, tabla del coordinador con encabezado fijo y filas alternadas.
2. **Salones por piso** (`pisos.js`): agrupa las tarjetas bajo "Piso 1", "Piso 2", etc. El piso sale de quitar las dos últimas cifras del código (102 es piso 1, 205 es piso 2). Los códigos que no siguen esa forma van en "Otros espacios".
3. **Software por salón** (`app.js`, `sql/08` y `sql/09`): cada salón con computadores muestra los programas instalados (logo y nombre). El administrador crea, edita y elimina programas y marca cuáles tiene cada salón desde el botón **Software**. Los logos están en `app/logos/`.
4. **Filtro por software y horario sin "null"** (`app.js`): se puede buscar salones por programa instalado.
5. **Disponibilidad en tiempo real** (`sql/10`): cuando cambia una reserva, un bloqueo, el horario o un salón, las pantallas abiertas se actualizan solas. El aviso no lleva datos personales.
6. **Reservas de 8:00 a 22:00** (`app.js`, `sql/11`): se puede reservar cualquier hora de ese rango menos las que chocan con una clase fija. Los laboratorios siguen de 18:00 a 22:00. Las tarjetas muestran las horas ocupadas (ej. Ocupado 8:00-10:00).

## Base de datos

Los archivos se cargan en orden con `scripts/cargar-sql.sh` de la VM.

| Archivo | Qué hace |
|---|---|
| 08-software.sql | Tablas `software` y `salon_software`, funciones para gestionarlas y los primeros 28 programas repartidos al azar (5 a 9 por salón con computadores, solo la primera vez) |
| 09-software-nuevos.sql | Agrega 25 programas más al catálogo, sin asignarlos a ningún salón |
| 10-tiempo-real.sql | Avisos por WebSocket cuando cambian las tablas de reservas, bloqueos, horario, salones, recursos y software |
| 11-horario-8-a-22.sql | Actualiza `slots_de` y `check_rules` para el horario de 8:00 a 22:00 |

Un salón cuenta como "con computadores" si su campo `equipo` dice `PC:n` (n mayor que 0) o tiene un recurso activo de tipo Computador.

Solo el rol administrador puede escribir en las tablas de software, y eso se controla en la base de datos (función `es_admin`), no solo ocultando el botón.

## Cosas a tener en cuenta

- Los SQL necesitan lo que ya existe en la VM de fases anteriores (tablas `salones`, `recursos`, `horario_fijo`, y funciones como `current_rol` y `regla`).
- El SQL 11 reemplaza la función `check_rules` completa.
- El coordinador no ve el botón Software; si se quiere dárselo, hay que cambiar `es_admin()` y la condición del botón en `app.js`.
- Los colores del tema son aproximados a los del sitio de la universidad, no los del manual de marca.
