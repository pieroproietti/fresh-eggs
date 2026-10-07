#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
usage() {
    echo "Usage: $0 [--gui | --cli | --legacy | --chef | --help]"
    echo "  --gui: download penguins-gui.AppImage to the current directory"
    echo "  --cli: install penguins-eggs (Go), using sudo if needed"
    echo "  --legacy: install penguins-eggs-legacy (Node.js), using sudo if needed"
    echo "  --chef: install penguins-chef, using sudo if needed"
}
[[ $# -gt 0 ]] || { usage; exit 0; }
[[ $# -le 1 ]] || { usage >&2; exit 1; }
case "$1" in
    --gui) target="penguins-gui" ;;
    --cli) target="penguins-eggs" ;;
    --legacy) target="penguins-eggs-legacy" ;;
    --chef) target="penguins-chef" ;;
    --help|-h) usage; exit 0 ;;
    *) usage >&2; exit 1 ;;
esac
if [[ "$target" != "penguins-gui" && "$EUID" -ne 0 ]]; then
    if ! command -v sudo >/dev/null 2>&1; then
        echo "Error: sudo is unavailable. Run the installer as root." >&2
        exit 1
    fi
    exec sudo bash "${SCRIPT_DIR}/${target}/install.sh"
fi
exec bash "${SCRIPT_DIR}/${target}/install.sh"
