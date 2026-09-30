#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if [[ $# -ne 0 ]]; then
    echo "Usage: $0 (download penguins-gui.AppImage to the current directory)" >&2
    exit 1
fi
for dependency in curl python3; do
    command -v "$dependency" >/dev/null 2>&1 || {
        echo "Error: Install $dependency and try again." >&2
        exit 1
    }
done
source "${SCRIPT_DIR}/stage-gui-appimage.sh"
STAGE_DIR=$(mktemp -d)
trap 'rm -rf "$STAGE_DIR"' EXIT
stage_gui_appimage "$STAGE_DIR" "$(uname -m)" || exit 1
APPIMAGES=("$STAGE_DIR"/*.AppImage)
[[ ${#APPIMAGES[@]} -eq 1 && -f "${APPIMAGES[0]}" ]] || {
    echo "Error: The release must contain exactly one compatible AppImage." >&2
    exit 1
}
mv -- "${APPIMAGES[0]}" ./penguins-gui.AppImage
echo "Run: ./penguins-gui.AppImage (without sudo)."
echo "Then choose Edit → Install penguins-egg CLI to install Eggs."
echo "If FUSE is unavailable: APPIMAGE_EXTRACT_AND_RUN=1 ./penguins-gui.AppImage"
