#!/bin/bash

# Funzione condivisa da basket.sh e sourceforge.sh.
# Scarica tutte le AppImage di penguins-gui dall'ultima release stabile.
stage_gui_appimage() {
    local stage_dir=$1
    local metadata="${stage_dir}/release.json"
    local assets="${stage_dir}/assets.tsv"
    local name url

    mkdir -p "$stage_dir" || return 1
    curl --fail --silent --show-error --location --retry 3 \
        https://api.github.com/repos/pieroproietti/penguins-gui/releases/latest \
        -o "$metadata" || return 1

    python3 - "$metadata" > "$assets" <<'PY'
import json
import re
import sys

with open(sys.argv[1]) as source:
    release = json.load(source)
assets = [a for a in release["assets"]
          if re.fullmatch(r"penguins-gui-[A-Za-z0-9._+-]+\.AppImage", a["name"])]
if not assets:
    sys.exit("Nessuna AppImage di penguins-gui nell'ultima release.")
for asset in assets:
    url = asset["browser_download_url"]
    if not url.startswith("https://github.com/pieroproietti/penguins-gui/releases/download/") or any(c.isspace() for c in url):
        sys.exit("URL AppImage non valido.")
    print(asset["name"] + "\t" + url)
PY
    if [ $? -ne 0 ]; then
        return 1
    fi

    while IFS=$'\t' read -r name url; do
        echo "📥 Scarico $name"
        curl --fail --silent --show-error --location --retry 3 \
            "$url" -o "${stage_dir}/${name}.part" || return 1
        [ -s "${stage_dir}/${name}.part" ] || return 1
        chmod 755 "${stage_dir}/${name}.part" || return 1
        mv "${stage_dir}/${name}.part" "${stage_dir}/${name}" || return 1
    done < "$assets"

    rm -f "$metadata" "$assets"
}
