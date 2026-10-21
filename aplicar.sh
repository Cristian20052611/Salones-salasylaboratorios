#!/usr/bin/env bash
# Actualización completa de la Agenda de Aulas (incluye todo lo anterior + actualización 03).
# Uso en la máquina virtual:   sudo bash aplicar.sh
# Hace: 1) respaldo de la base, 2) copia de TODA la carpeta app actual, 3) copia los archivos nuevos
#       (NO toca supabase-config.js ni email-config.js), 4) aplica sql/10-tiempo-real.sql.
# No borra datos. Para continuar aunque app.js tenga cambios propios:  sudo FORZAR=1 bash aplicar.sh
set -euo pipefail
AQUI="$(cd "$(dirname "$0")" && pwd)"
[ "$(id -u)" = "0" ] || { echo "Ejecuta con sudo: sudo bash aplicar.sh"; exit 1; }
if [ -n "${AGENDA:-}" ]; then :; elif [ -n "${SUDO_USER:-}" ]; then AGENDA="$(getent passwd "$SUDO_USER" | cut -d: -f6)/agenda"; else AGENDA="$HOME/agenda"; fi
[ -f "$AGENDA/instalar.sh" ] || { echo "No encuentro la instalación en $AGENDA (indica otra con: sudo AGENDA=/ruta bash aplicar.sh)"; exit 1; }
sed -i 's/\r$//' "$AQUI"/sql/*.sql

ACTUAL="$(sha256sum "$AGENDA/app/app.js" | cut -d' ' -f1)"
NUEVO="$(sha256sum "$AQUI/app/app.js" | cut -d' ' -f1)"
ESPERADO="$(cat "$AQUI/.app-js-esperado")"
if [ "$ACTUAL" != "$ESPERADO" ] && [ "$ACTUAL" != "$NUEVO" ] && [ "${FORZAR:-}" != "1" ]; then
  echo "ATENCIÓN: el app.js de la VM no es el de la actualización 02 ni el nuevo (tiene otros cambios)."
  echo "No se copió nada. Revisa los cambios o repite con FORZAR=1 (se hace respaldo igualmente)."
  exit 1
fi

SELLO="$(date +%Y-%m-%d_%H%M)"
RESP="$AGENDA/app.antes-$SELLO"

echo "==> 1/4 Respaldo de la base de datos"
bash "$AGENDA/scripts/respaldo.sh"

echo "==> 2/4 Respaldo de la carpeta app actual en $RESP"
cp -a "$AGENDA/app" "$RESP"

echo "==> 3/4 Copiando los archivos nuevos (se conservan supabase-config.js y email-config.js)"
for f in index.html app.js styles.css confirmar.html restablecer.html; do cp "$AQUI/app/$f" "$AGENDA/app/$f"; done
mkdir -p "$AGENDA/app/vendor"; cp -r "$AQUI/app/vendor/." "$AGENDA/app/vendor/"
chmod -R a+rX "$AGENDA/app"
if [ "$(grep -c 'id="f-software"' "$AGENDA/app/index.html")" != "1" ]; then
  echo "El index.html no quedó bien; restaurando."; rm -rf "$AGENDA/app"; cp -a "$RESP" "$AGENDA/app"; exit 1
fi

echo "==> 4/4 Aplicando el SQL de tiempo real"
cp "$AQUI/sql/10-tiempo-real.sql" "$AGENDA/sql/"
if ! bash "$AGENDA/scripts/cargar-sql.sh"; then
  echo "El SQL falló (no quedó nada a medias). Restaurando la carpeta app anterior."
  rm -rf "$AGENDA/app"; cp -a "$RESP" "$AGENDA/app"; exit 1
fi

bash "$AGENDA/scripts/servicio.sh" prueba
echo
echo "Listo. Recarga la app (Ctrl+F5)."
echo "Para volver atrás:  sudo bash revertir.sh   (restaura $RESP)"
