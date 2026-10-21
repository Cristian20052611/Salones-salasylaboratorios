#!/bin/bash
# Aplica los cambios visuales (tema institucional + pisos) a la agenda.
# Uso:   bash aplicar-cambios.sh                      (usa /home/salas/agenda/app)
#        bash aplicar-cambios.sh /otra/ruta/a/app     (si la app esta en otra carpeta)

set -e

APP_DIR="${1:-/home/salas/agenda/app}"
AQUI="$(cd "$(dirname "$0")" && pwd)"

if [ ! -f "$APP_DIR/styles.css" ] || [ ! -f "$APP_DIR/index.html" ]; then
  echo "ERROR: no encontre styles.css e index.html en: $APP_DIR"
  echo "Uso: bash aplicar-cambios.sh /ruta/a/la/carpeta/de/la/app"
  exit 1
fi

for f in styles.css pisos.js; do
  if [ ! -f "$AQUI/$f" ]; then
    echo "ERROR: falta $f junto a este script ($AQUI)"
    exit 1
  fi
done

if ! grep -q "PANEL COORDINADOR" "$APP_DIR/styles.css" && ! grep -q "TEMA UNIVERSIDAD" "$APP_DIR/styles.css"; then
  echo "AVISO: el styles.css de $APP_DIR no parece ser el de la agenda."
  echo "Se hara copia de respaldo igualmente. Cancela con Ctrl+C en los proximos 5 segundos si no es la carpeta correcta."
  sleep 5
fi

# El respaldo se crea UNA sola vez, con el estado original (antes de cualquier cambio).
# Si se vuelve a ejecutar este script, el respaldo original se conserva.
if [ ! -f "$APP_DIR/styles.css.antes-de-cambios.bak" ]; then
  cp "$APP_DIR/styles.css" "$APP_DIR/styles.css.antes-de-cambios.bak"
  cp "$APP_DIR/index.html" "$APP_DIR/index.html.antes-de-cambios.bak"
  echo "Respaldo creado: styles.css.antes-de-cambios.bak e index.html.antes-de-cambios.bak"
else
  echo "Ya existe el respaldo original; se conserva sin tocarlo."
fi

cp "$AQUI/styles.css" "$APP_DIR/styles.css"
cp "$AQUI/pisos.js" "$APP_DIR/pisos.js"
chmod 644 "$APP_DIR/styles.css" "$APP_DIR/pisos.js"

# Quitar el script de badges de una prueba anterior, si quedo enganchado
sed -i 's#<script src="jornada-badges.js"></script>##' "$APP_DIR/index.html"

# Enganchar pisos.js una sola vez
if ! grep -q 'pisos.js' "$APP_DIR/index.html"; then
  sed -i 's#</body>#<script src="pisos.js"></script></body>#' "$APP_DIR/index.html"
fi

echo
echo "Verificacion:"
echo "  TEMA UNIVERSIDAD en styles.css : $(grep -c 'TEMA UNIVERSIDAD' "$APP_DIR/styles.css")  (debe ser 1)"
echo "  POR PISOS en styles.css        : $(grep -c 'POR PISOS' "$APP_DIR/styles.css")  (debe ser 1)"
echo "  pisos.js en index.html         : $(grep -c 'pisos.js' "$APP_DIR/index.html")  (debe ser 1)"
echo
echo "Listo. En el navegador haz Ctrl + Shift + R para ver los cambios."
echo "Para deshacer: bash revertir-cambios.sh $APP_DIR"
