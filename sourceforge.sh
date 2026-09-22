#!/bin/bash

# --- CONFIGURAZIONE ---
SF_USER="pproietti"
SF_HOST="frs.sourceforge.net"
SF_BASE_DIR="/home/frs/project/penguins-eggs/Packages"

declare -A REPOS
REPOS["/var/www/html/repos/alpine/x86_64/"]="alpine"
REPOS["/var/www/html/repos/arch/"]="aur"
REPOS["/var/www/html/repos/deb/pool/main/"]="debs"
REPOS["/var/www/html/repos/manjaro/"]="manjaro"
REPOS["/var/www/html/repos/rpm/el9/x86_64/"]="el9"
REPOS["/var/www/html/repos/rpm/fedora/42/x86_64/"]="fedora"
REPOS["/var/www/html/repos/rpm/opensuse/leap/x86_64/"]="opensuse"

# Creiamo l'area di staging temporanea
STAGE_BASE="/tmp/sf_stage_$$"
mkdir -p "$STAGE_BASE"

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

# --- FUNZIONE DI RICERCA (IL "CERCATORE") ---
# Trova esattamente l'ultimo file che rispetta il pattern e lo copia nello Stage
stage_latest() {
    local src_dir=$1
    local stage_dir=$2
    local pattern=$3

    # Troviamo l'ultimo file (head -n 1 prende il più recente)
    local latest=$(ls -t "${src_dir}"/${pattern} 2>/dev/null | head -n 1)
    
    if [ -n "$latest" ] && [ -f "$latest" ]; then
        cp -a "$latest" "$stage_dir/"
        echo "    ✅ Selezionato: $(basename "$latest")"
    fi
}

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

    # Definiamo le regole di selezione (chirurgiche!)
    if [ "$DEST_SUBDIR" = "debs" ]; then
        # Debian: Vogliamo standard, legacy e penguins-gui per OGNI architettura
        for arch in amd64 arm64 riscv64 i386; do
            stage_latest "$SRC_DIR" "$STAGE_DIR" "penguins-eggs_[0-9]*_${arch}.deb"
            stage_latest "$SRC_DIR" "$STAGE_DIR" "penguins-eggs-legacy_[0-9]*_${arch}.deb"
            stage_latest "$SRC_DIR" "$STAGE_DIR" "penguins-gui_[0-9]*_${arch}.deb"
        done
        
    elif [[ "$DEST_SUBDIR" == "fedora" || "$DEST_SUBDIR" == "el9" || "$DEST_SUBDIR" == "opensuse" ]]; then
        # RPM
        stage_latest "$SRC_DIR" "$STAGE_DIR" "penguins-eggs-[0-9]*.rpm"
        stage_latest "$SRC_DIR" "$STAGE_DIR" "penguins-eggs-legacy-[0-9]*.rpm"
        stage_latest "$SRC_DIR" "$STAGE_DIR" "penguins-gui-[0-9]*.rpm"
        
    elif [[ "$DEST_SUBDIR" == "aur" || "$DEST_SUBDIR" == "manjaro" ]]; then
        # Arch / Manjaro
        stage_latest "$SRC_DIR" "$STAGE_DIR" "penguins-eggs-[0-9]*.pkg.tar.zst"
        stage_latest "$SRC_DIR" "$STAGE_DIR" "penguins-eggs-legacy-[0-9]*.pkg.tar.zst"
        stage_latest "$SRC_DIR" "$STAGE_DIR" "penguins-gui-[0-9]*.pkg.tar.zst"
        
    elif [ "$DEST_SUBDIR" = "alpine" ]; then
        # Alpine
        stage_latest "$SRC_DIR" "$STAGE_DIR" "penguins-eggs-[0-9]*.apk"
        stage_latest "$SRC_DIR" "$STAGE_DIR" "penguins-eggs-legacy-[0-9]*.apk"
        stage_latest "$SRC_DIR" "$STAGE_DIR" "penguins-gui-[0-9]*.apk"
    fi

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
rm -rf "$STAGE_BASE"

echo "Chiudo la connessione master..."
ssh -S "$SOCKET" -O exit "${SF_USER}@${SF_HOST}" 2>/dev/null
echo "✅ Specchio su SourceForge allineato perfettamente."
