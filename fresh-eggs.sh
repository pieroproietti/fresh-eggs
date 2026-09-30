#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
usage() {
    echo "Uso: $0 [--gui | --cli | --legacy | --help]"
    echo "  --gui: scarica penguins-gui.AppImage nella directory corrente"
    echo "  --cli: installa penguins-eggs (Go), richiede sudo se necessario"
    echo "  --legacy: installa penguins-eggs-legacy (Node.js), richiede sudo se necessario"
}
[[ $# -gt 0 ]] || { usage; exit 0; }
[[ $# -le 1 ]] || { usage >&2; exit 1; }
case "$1" in
    --gui) target="penguins-gui" ;;
    --cli) target="penguins-eggs" ;;
    --legacy) target="penguins-eggs-legacy" ;;
    --help|-h) usage; exit 0 ;;
    *) usage >&2; exit 1 ;;
esac
if [[ "$target" != "penguins-gui" && "$EUID" -ne 0 ]]; then
    if ! command -v sudo >/dev/null 2>&1; then
        echo "Errore: sudo non disponibile. Esegui l'installer come root." >&2
        exit 1
    fi
    exec sudo bash "${SCRIPT_DIR}/${target}/install.sh"
fi
exec bash "${SCRIPT_DIR}/${target}/install.sh"
