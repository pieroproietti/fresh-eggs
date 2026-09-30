#!/bin/bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../penguins-gui/stage-gui-appimage.sh" || exit 1
source "${SCRIPT_DIR}/common.sh" || exit 1

# --- CONFIGURAZIONE ---
DEST_BASE_DIR="/home/artisan/basket/packages"

# Creiamo l'area di staging temporanea
STAGE_BASE="/tmp/local_stage_$$"
mkdir -p "$STAGE_BASE" || exit 1
trap 'rm -rf "$STAGE_BASE"' EXIT

# Completiamo il download prima di modificare le destinazioni.
if ! stage_gui_appimage "${STAGE_BASE}/appimage"; then
    echo "❌ Download AppImage di penguins-gui fallito. Esco senza sincronizzare." >&2
    exit 1
fi
REPOS["${STAGE_BASE}/appimage"]="appimage"

# Assicuriamoci che la directory di destinazione finale esista
mkdir -p "$DEST_BASE_DIR"

# --- INIZIO CICLO REPOSITORY ---
for SRC_DIR in "${!REPOS[@]}"; do
    DEST_SUBDIR="${REPOS[$SRC_DIR]}"
    
    if [ ! -d "$SRC_DIR" ]; then
        echo "⚠️  Saltata: $SRC_DIR (non esiste localmente)"
        continue
    fi

    echo "---------------------------------------------------"
    echo "Analizzo sorgente: $SRC_DIR"
    
    # Prepariamo la cartella vuota (lo specchio perfetto)
    STAGE_DIR="${STAGE_BASE}/${DEST_SUBDIR}"
    mkdir -p "$STAGE_DIR"

    stage_packages "$SRC_DIR" "$STAGE_DIR" "$DEST_SUBDIR"

    # Controllo di sicurezza: se la cartella stage è vuota, non sincronizziamo
    if [ -z "$(ls -A "$STAGE_DIR")" ]; then
        echo "⚠️  Nessun pacchetto trovato da caricare per $DEST_SUBDIR. Salto la sincronizzazione."
        continue
    fi

    # Prepariamo la sottocartella di destinazione finale se non esiste
    mkdir -p "${DEST_BASE_DIR}/${DEST_SUBDIR}"

    # --- LA MAGIA: RSYNC --DELETE ---
    echo "🚀 Sincronizzo in locale (copio i nuovi, cancello il passato)..."
    rsync -avP --delete "${STAGE_DIR}/" "${DEST_BASE_DIR}/${DEST_SUBDIR}/"

done

echo "---------------------------------------------------"
echo "🧹 Pulizia area di staging temporanea..."

echo "✅ Specchio locale allineato perfettamente in ${DEST_BASE_DIR}."
