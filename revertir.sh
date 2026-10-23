#!/usr/bin/env bash
# Restaura la carpeta app al último respaldo hecho por aplicar.sh. Uso: sudo bash revertir.sh
# (el SQL de tiempo real es aditivo y puede quedarse; solo deja de usarse si vuelve el app.js anterior)
set -euo pipefail
[[ "$(id -u)" = "0" ]] || { echo "Ejecuta con sudo: sudo bash revertir.sh"; exit 1; }
if [[ -n "${AGENDA:-}" ]]; then :; elif [[ -n "${SUDO_USER:-}" ]]; then AGENDA="$(getent passwd "$SUDO_USER" | cut -d: -f6)/agenda"; else AGENDA="$HOME/agenda"; fi
RESP="$(ls -1d "$AGENDA"/app.antes-* 2>/dev/null | tail -n1 || true)"
[[ -n "$RESP" ]] || { echo "No hay respaldo app.antes-* en $AGENDA"; exit 1; }
rm -rf "$AGENDA/app"; cp -a "$RESP" "$AGENDA/app"
echo "Restaurado desde $RESP. Recarga con Ctrl+F5."
