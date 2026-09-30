#!/bin/bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../penguins-gui/stage-gui-appimage.sh" || exit 1
source "${SCRIPT_DIR}/common.sh" || exit 1

# --- CONFIGURAZIONE ---
SF_USER="pproietti"
SF_HOST="frs.sourceforge.net"
SF_BASE_DIR="/home/frs/project/penguins-eggs/Packages"

# Creiamo l'area di staging temporanea
STAGE_BASE="/tmp/sf_stage_$$"
mkdir -p "$STAGE_BASE" || exit 1
trap 'rm -rf "$STAGE_BASE"' EXIT

# Completiamo il download prima di modificare le destinazioni.
if ! stage_gui_appimage "${STAGE_BASE}/appimage"; then
    echo "❌ Download AppImage di penguins-gui fallito. Esco senza sincronizzare." >&2
    exit 1
fi
REPOS["${STAGE_BASE}/appimage"]="appimage"

# --- CONNESSIONE MASTER SSH ---
SOCKET="/tmp/sf_ssh_socket_$$"

echo "🔑 Apro la connessione con SourceForge."
echo "Inserisci la password ORA (varrà per tutti gli upload)..."
ssh -M -S "$SOCKET" -fN "${SF_USER}@${SF_HOST}"

if [ $? -ne 0 ]; then
    echo "❌ Errore di connessione a SourceForge. Esco."
    exit 1
fi
echo "✅ Connessione stabilita."

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

    # Controllo di sicurezza: se la cartella stage è vuota, non sincronizziamo (evita di piallare SF per errore)
    if [ -z "$(ls -A "$STAGE_DIR")" ]; then
        echo "⚠️  Nessun pacchetto trovato da caricare per $DEST_SUBDIR. Salto la sincronizzazione."
        continue
    fi

    # --- LA MAGIA: RSYNC --DELETE ---
    echo "🚀 Sincronizzo con SourceForge (carico i nuovi, cancello il passato)..."
    rsync -avP --delete -e "ssh -S $SOCKET" "${STAGE_DIR}/" "${SF_USER}@${SF_HOST}:${SF_BASE_DIR}/${DEST_SUBDIR}/"

done

echo "---------------------------------------------------"
echo "🧹 Pulizia area di staging temporanea..."

echo "Chiudo la connessione master..."
ssh -S "$SOCKET" -O exit "${SF_USER}@${SF_HOST}" 2>/dev/null
echo "✅ Specchio su SourceForge allineato perfettamente."
