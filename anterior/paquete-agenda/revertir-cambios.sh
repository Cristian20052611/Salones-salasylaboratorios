#!/bin/bash
# Deshace los cambios: restaura el estado original guardado por aplicar-cambios.sh.
# Uso:   bash revertir-cambios.sh                      (usa /home/salas/agenda/app)
#        bash revertir-cambios.sh /otra/ruta/a/app

set -e

APP_DIR="${1:-/home/salas/agenda/app}"
CSS_BAK="$APP_DIR/styles.css.antes-de-cambios.bak"
HTML_BAK="$APP_DIR/index.html.antes-de-cambios.bak"

if [ ! -f "$CSS_BAK" ] || [ ! -f "$HTML_BAK" ]; then
  echo "ERROR: no encontre el respaldo original (*.antes-de-cambios.bak) en $APP_DIR"
  exit 1
fi

cp "$CSS_BAK" "$APP_DIR/styles.css"
cp "$HTML_BAK" "$APP_DIR/index.html"
rm -f "$APP_DIR/pisos.js"

echo "Restaurado el estado original (styles.css e index.html). Se elimino pisos.js."
echo "Los respaldos se conservan por si quieres volver a aplicar los cambios."
echo "En el navegador haz Ctrl + Shift + R."
