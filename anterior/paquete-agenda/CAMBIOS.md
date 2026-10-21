# Documentación de cambios: interfaz de la agenda de salones

**Fecha:** 19 de octubre de 2026
**Responsable:** ______________________
**Proyecto:** Agenda de salones y laboratorios (panel del estudiante y panel del coordinador)

---

## 1. Resumen

Se rediseñó la apariencia de la aplicación sin modificar su lógica ni sus datos. Los cambios son:

1. Mejoras visuales en la tabla del panel del coordinador.
2. Cambio de la paleta de colores a una institucional, basada en el azul marino y el amarillo dorado del sitio web de la universidad.
3. Organización de los salones por pisos.
4. Ajustes para que la interfaz sea más intuitiva.

## 2. Entorno

| Elemento | Detalle |
|---|---|
| Servidor | Máquina virtual en VMware Workstation, Ubuntu 24.04.5 LTS |
| Aplicación | Contenedor Docker `agenda-web` |
| Carpeta publicada | `/home/salas/agenda/app/` |
| Copia del diseño original | `/home/salas/agenda_app_original/` (sin modificar) |
| Copia de trabajo | `/home/salas/agenda_app_nueva/` |

## 3. Archivos creados o modificados

| Archivo | Acción | Para qué sirve |
|---|---|---|
| `styles.css` | Modificado | Se agregaron las reglas del tema institucional, de la tabla y de los pisos al final del archivo |
| `pisos.js` | Nuevo | Agrupa los salones por piso y etiqueta el piso en la tabla del coordinador |
| `index.html` | Modificado | Se agregó una línea `<script src="pisos.js">` antes de `</body>` |

Además, el paquete incluye `aplicar-cambios.sh` y `revertir-cambios.sh` para instalar y deshacer los cambios.

No se modificó ningún archivo con la lógica de reservas ni con los datos.

## 4. Detalle de los cambios

### 4.1 Tabla del panel del coordinador

- Encabezado de la tabla fijo mientras se desplaza.
- Filas alternadas en dos tonos y resalte al pasar el cursor.
- Zona de la tabla con scroll propio, para que la barra superior siempre quede visible.
- Botones de acción (Cambiar salón, Editar, Borrar) con bordes redondeados y efecto al pasar el cursor.
- El botón **Borrar** se muestra en rojo suave para distinguirlo de las otras acciones.
- La columna de botones **no** queda fija a la derecha, porque tapaba el texto de las columnas vecinas.
- Ajuste del tamaño de letra y del espaciado en pantallas pequeñas.

### 4.2 Paleta institucional

Se tomaron como referencia el azul marino, el amarillo dorado y el blanco del sitio web de la universidad. Los tonos son **aproximados**, tomados de una captura de pantalla, y no corresponden a los códigos oficiales del manual de marca.

| Uso | Antes | Ahora |
|---|---|---|
| Azul principal (barra superior, títulos) | `#0B3D77` | `#0B1B3F` |
| Azul de acento y disponible | `#2E6FD9` | `#1E4FA3` |
| Acento destacado (línea de la barra, botón confirmar) | azul `#2E6FD9` | dorado `#FFC61A` |
| Fondo claro | `#EAF2FC` | `#EEF3FA` |
| Texto secundario | `#55688A` | `#5A6B85` |

Otros cambios de color:

- La barra superior lleva una línea dorada en la parte inferior.
- Los botones de confirmar son dorados con texto azul oscuro.
- El avatar del usuario es dorado.
- La pantalla de ingreso usa un degradado azul marino.

Antes se probó un tema con turquesa y gris pizarra. Se descartó porque, al ser una página institucional, se pidió usar los colores de la universidad (azul y gris).

### 4.3 Organización por pisos

- En la vista de salones, las tarjetas se agrupan bajo un título **Piso 1**, **Piso 2**, etc.
- Cada título muestra el número de piso y la cantidad de salones.
- Dentro de cada piso, los salones se ordenan por número.
- Los espacios cuyo código no tiene un número de tres cifras o más aparecen en **Otros espacios**.
- En la tabla del coordinador, bajo el número del salón aparece una pequeña etiqueta con el piso.

**Regla usada:** el piso es el número que queda al quitar las dos últimas cifras del código del salón. Ejemplos: 102 → Piso 1, 205 → Piso 2, 301 → Piso 3.

### 4.4 Interfaz más intuitiva

- Agrupación por pisos, para ubicar un salón más rápido.
- Contador de salones por piso.
- Indicador ● antes del estado (Disponible / Ocupado) de cada tarjeta.
- Etiqueta de piso en la tabla del coordinador.

## 5. Cómo aplicar y revertir

Los cambios se entregan en un paquete (`paquete-agenda.tar.gz`) con un instalador. Antes de modificar nada, el instalador guarda una copia del estado original (`styles.css.antes-de-cambios.bak` e `index.html.antes-de-cambios.bak`) y no la sobrescribe si se vuelve a ejecutar.

Para aplicar, dentro de la carpeta del paquete:

```bash
bash aplicar-cambios.sh
```

Si la aplicación no está en `/home/salas/agenda/app`, se indica la carpeta donde están `index.html` y `styles.css`:

```bash
bash aplicar-cambios.sh /ruta/a/la/app
```

Para volver al estado anterior:

```bash
bash revertir-cambios.sh
```

Para volver al diseño original completo de la aplicación (si se conserva la copia `agenda_app_original`):

```bash
cp /home/salas/agenda_app_original/styles.css /home/salas/agenda/app/styles.css
```

## 6. Publicación para la demostración

La aplicación corre en una red privada (`192.168.x.x`), por lo que desde fuera no es accesible. Para mostrarla a otras personas se usa un túnel de Cloudflare, que genera un enlace temporal `https://...trycloudflare.com`.

- El enlace cambia cada vez que se reinicia el túnel o la máquina virtual.
- La máquina virtual debe estar encendida y sin suspender mientras se muestra.
- Quienes abren el enlace solo ven la página web, no acceden a la red ni al servidor.
- Se recomienda compartir únicamente usuarios de prueba.

## 7. Limitaciones

- La agrupación por pisos se hace en el navegador mediante JavaScript, a partir del código de cada salón. Si cambia la forma de numerar los salones, hay que ajustar la regla.
- Los colores son aproximados a los del sitio de la universidad.
- La agrupación por pisos debe revisarse en el navegador después de aplicarla (la consola, con F12, no debe mostrar errores), porque depende de las clases `.room-grid`, `.room-card` y `.room-code` de la aplicación.
