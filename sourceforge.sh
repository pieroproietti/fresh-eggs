#!/bin/bash

# --- CONFIGURAZIONE ---
SF_USER="pproietti"
SF_HOST="frs.sourceforge.net"
SF_BASE_DIR="/home/frs/project/penguins-eggs/Packages"

declare -A REPOS
REPOS["/var/www/html/repos/alpine/x86_64/"]="alpine/"
REPOS["/var/www/html/repos/arch/"]="aur/"
REPOS["/var/www/html/repos/deb/pool/main/"]="debs/"
REPOS["/var/www/html/repos/manjaro/"]="manjaro/"
REPOS["/var/www/html/repos/rpm/el9/x86_64/"]="el9/"
REPOS["/var/www/html/repos/rpm/fedora/42/x86_64/"]="fedora/"
REPOS["/var/www/html/repos/rpm/opensuse/leap/x86_64/"]="opensuse/"

# --- CONNESSIONE MASTER SSH ---
SOCKET="/tmp/sf_ssh_socket_$$"

echo "🔑 Apro la connessione con SourceForge."
echo "Inserisci la password ORA (varrà per tutti i file)..."
ssh -M -S "$SOCKET" -fN "${SF_USER}@${SF_HOST}"

if [ $? -ne 0 ]; then
    echo "❌ Errore di connessione a SourceForge. Esco."
    exit 1
fi
echo "✅ Connessione stabilita, inizio l'upload..."

# Funzione per trovare la versione e caricare i file
upload_latest_version() {
    local src_dir=$1
    local dest_subdir=$2
    local is_legacy=$3
    local dest_path="${SF_USER}@${SF_HOST}:${SF_BASE_DIR}/${dest_subdir}"

    # Trova il file più recente: 
    # Usiamo [-_] per catturare sia il trattino (Arch/RPM/Alpine) sia l'underscore (Debian)
    if [ "$is_legacy" = true ]; then
        local latest_file=$(ls -t "${src_dir}"penguins-eggs-legacy* 2>/dev/null | head -n 1)
    else
        local latest_file=$(ls -t "${src_dir}"penguins-eggs[-_]* 2>/dev/null | grep -v "legacy" | head -n 1)
    fi

    if [ -z "$latest_file" ]; then
        return
    fi

    # Estrae la versione dal nome del file (es: 0.9.2-1, 0.9.2-r1, 26.6.27-1)
    local version=$(basename "$latest_file" | sed -E 's/.*penguins-eggs(-legacy)?_?-?([0-9]+\.[0-9]+\.[0-9]+-[a-zA-Z0-9]+).*/\2/')
    
    echo "📌 Trovata versione $version in $src_dir"

    # Prepara la lista dei file che matchano esattamente quella versione
    if [ "$is_legacy" = true ]; then
        local files_to_upload=$(ls "${src_dir}"*legacy*"${version}"* 2>/dev/null)
    else
        local files_to_upload=$(ls "${src_dir}"*"${version}"* 2>/dev/null | grep -v "legacy")
    fi

    # Esegue l'upload di tutti i file trovati per questa versione
    for f in $files_to_upload; do
        if [ -f "$f" ]; then
            echo "   🚀 Upload: $(basename "$f") -> $dest_subdir"
            rsync -avP -e "ssh -S $SOCKET" "$f" "$dest_path"
        fi
    done
}

# --- INIZIO CICLO ---
for SRC_DIR in "${!REPOS[@]}"; do
    DEST_SUBDIR="${REPOS[$SRC_DIR]}"
    
    if [ ! -d "$SRC_DIR" ]; then
        echo "⚠️  Saltata: $SRC_DIR (non esiste)"
        continue
    fi

    echo "---------------------------------------------------"
    echo "Analizzo: $SRC_DIR"

    # Carica la Standard
    upload_latest_version "$SRC_DIR" "$DEST_SUBDIR" false
    # Carica la Legacy
    upload_latest_version "$SRC_DIR" "$DEST_SUBDIR" true
done

echo "---------------------------------------------------"
echo "Chiudo la connessione master..."
ssh -S "$SOCKET" -O exit "${SF_USER}@${SF_HOST}" 2>/dev/null
echo "✅ Script completato."