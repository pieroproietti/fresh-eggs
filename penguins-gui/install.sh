#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if [[ $# -ne 0 ]]; then
    echo "Uso: $0 (scarica penguins-gui.AppImage nella directory corrente)" >&2
    exit 1
fi
for dependency in curl python3; do
    command -v "$dependency" >/dev/null 2>&1 || {
        echo "Errore: installa $dependency e riprova." >&2
        exit 1
    }
done
source "${SCRIPT_DIR}/stage-gui-appimage.sh"
STAGE_DIR=$(mktemp -d)
trap 'rm -rf "$STAGE_DIR"' EXIT
stage_gui_appimage "$STAGE_DIR" "$(uname -m)" || exit 1
APPIMAGES=("$STAGE_DIR"/*.AppImage)
[[ ${#APPIMAGES[@]} -eq 1 && -f "${APPIMAGES[0]}" ]] || {
    echo "Errore: la release deve contenere una sola AppImage compatibile." >&2
    exit 1
}
mv -- "${APPIMAGES[0]}" ./penguins-gui.AppImage
echo "Avvia: ./penguins-gui.AppImage (senza sudo)."
echo "Poi scegli Edit → Install penguins-egg CLI per installare Eggs."
echo "Se FUSE non è disponibile: APPIMAGE_EXTRACT_AND_RUN=1 ./penguins-gui.AppImage"
