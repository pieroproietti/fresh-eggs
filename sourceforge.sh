#!/bin/bash

# --- CONFIGURAZIONE ---
# Inserisci il tuo username di SourceForge
SF_USER="pproietti"
SF_HOST="frs.sourceforge.net"
# Questo è il path di base assoluto del tuo progetto sul server FRS
SF_BASE_DIR="/home/frs/project/penguins-eggs/Packages"

# Dizionario associativo: Mappa ogni directory sorgente alla sua cartella di destinazione su SF
declare -A REPOS
REPOS["/var/www/html/repos/alpine/x86_64/"]="alpine/" # <-- Controlla che 'alpine/' sia il nome corretto
REPOS["/var/www/html/repos/arch/"]="aur/"
REPOS["/var/www/html/repos/deb/"]="debs/"
REPOS["/var/www/html/repos/manjaro/"]="manjaro/"
REPOS["/var/www/html/repos/rpm/el9/x86_64/"]="el9/"
REPOS["/var/www/html/repos/rpm/fedora/42/x86_64/"]="fedora/"

echo "Inizio sincronizzazione fottutamente automatica verso SourceForge..."

for SRC_DIR in "${!REPOS[@]}"; do
    DEST_SUBDIR="${REPOS[$SRC_DIR]}"
    DEST_PATH="${SF_USER}@${SF_HOST}:${SF_BASE_DIR}/${DEST_SUBDIR}"
    
    if [ ! -d "$SRC_DIR" ]; then
        echo "⚠️  Directory saltata (non esiste sul disco locale): $SRC_DIR"
        continue
    fi

    echo "Analizzo: $SRC_DIR"

    # 1. Trova l'ultima versione del pacchetto LEGACY
    LATEST_LEGACY=$(ls -t "${SRC_DIR}"penguins-eggs-legacy* 2>/dev/null | head -n 1)
    
    # 2. Trova l'ultima versione STANDARD (escludendo i file legacy per evitare doppioni)
    LATEST_STANDARD=$(ls -t "${SRC_DIR}"penguins-eggs-* 2>/dev/null | grep -v "legacy" | head -n 1)

    # Funzione per l'upload tramite rsync over SSH
    upload_file() {
        local file=$1
        if [ -n "$file" ] && [ -f "$file" ]; then
            echo "🚀 Upload in corso: $(basename "$file") -> $DEST_SUBDIR"
            # Usa rsync con protocollo ssh
            rsync -avP -e ssh "$file" "$DEST_PATH"
        else
            echo "   Nessun file trovato per questo ramo in $SRC_DIR"
        fi
    }

    # Esegui gli upload
    upload_file "$LATEST_LEGACY"
    upload_file "$LATEST_STANDARD"
    
    echo "---------------------------------------------------"
done

echo "✅ Script completato."
