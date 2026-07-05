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
echo "Inserisci la password ORA (varrà per tutti gli upload e le pulizie)..."
ssh -M -S "$SOCKET" -fN "${SF_USER}@${SF_HOST}"

if [ $? -ne 0 ]; then
    echo "❌ Errore di connessione a SourceForge. Esco."
    exit 1
fi
echo "✅ Connessione stabilita."

# --- FUNZIONE LOGICA DI UPLOAD ---
# Accetta un quarto parametro opzionale per filtrare l'architettura (es. amd64, riscv64, arm64)
upload_latest_version() {
    local src_dir=$1
    local dest_subdir=$2
    local is_legacy=$3
    local arch_filter=$4
    local dest_path="${SF_USER}@${SF_HOST}:${SF_BASE_DIR}/${dest_subdir}"

    local latest_file=""

    # 1. Ricerca dell'ultimo file specifico per tipo ed eventuale architettura
    if [ "$is_legacy" = true ]; then
        if [ -n "$arch_filter" ]; then
            latest_file=$(ls -t "${src_dir}"penguins-eggs-legacy*_*${arch_filter}* 2>/dev/null | head -n 1)
        else
            latest_file=$(ls -t "${src_dir}"penguins-eggs-legacy* 2>/dev/null | head -n 1)
        fi
    else
        if [ -n "$arch_filter" ]; then
            latest_file=$(ls -t "${src_dir}"penguins-eggs[-_]*_*${arch_filter}* 2>/dev/null | grep -v "legacy" | head -n 1)
        else
            latest_file=$(ls -t "${src_dir}"penguins-eggs[-_]* 2>/dev/null | grep -v "legacy" | head -n 1)
        fi
    fi

    if [ -z "$latest_file" ]; then
        return
    fi

    # 2. Estrazione della versione dal file identificato
    local version=$(basename "$latest_file" | sed -E 's/.*penguins-eggs(-legacy)?_?-?([0-9]+\.[0-9]+\.[0-9]+-[a-zA-Z0-9]+).*/\2/')
    
    if [ -n "$arch_filter" ]; then
        echo "📌 [${arch_filter}] Trovata ultima versione: $version"
    else
        echo "📌 Trovata ultima versione: $version"
    fi

    # 3. Raccolta dei file corrispondenti alla versione (escludendo gli sha256)
    local files_to_upload=""
    if [ "$is_legacy" = true ]; then
        if [ -n "$arch_filter" ]; then
            files_to_upload=$(ls "${src_dir}"*legacy*"${version}"*_${arch_filter}* 2>/dev/null | grep -v "\.sha256$")
        else
            files_to_upload=$(ls "${src_dir}"*legacy*"${version}"* 2>/dev/null | grep -v "\.sha256$")
        fi
    else
        if [ -n "$arch_filter" ]; then
            files_to_upload=$(ls "${src_dir}"*"${version}"*_${arch_filter}* 2>/dev/null | grep -v "legacy" | grep -v "\.sha256$")
        else
            files_to_upload=$(ls "${src_dir}"*"${version}"* 2>/dev/null | grep -v "legacy" | grep -v "\.sha256$")
        fi
    fi

    # 4. Spedizione su SourceForge via rsync sfruttando il socket aperto
    for f in $files_to_upload; do
        if [ -f "$f" ]; then
            echo "    🚀 Upload: $(basename "$f") -> $dest_subdir"
            rsync -avP -e "ssh -S $SOCKET" "$f" "$dest_path"
        fi
    done
}

# --- INIZIO CICLO REPOSITORY ---
for SRC_DIR in "${!REPOS[@]}"; do
    DEST_SUBDIR="${REPOS[$SRC_DIR]}"
    
    if [ ! -d "$SRC_DIR" ]; then
        echo "⚠️  Saltata: $SRC_DIR (non esiste)"
        continue
    fi

    echo "---------------------------------------------------"
    echo "Analizzo sorgente: $SRC_DIR"

    # A. TABULA RASA: Rimuove TOTALMENTE il contenuto precedente nella cartella remota di SourceForge
    echo "🧹 Rimozione totale versioni precedenti in $DEST_SUBDIR su SourceForge..."
    ssh -S "$SOCKET" "${SF_USER}@${SF_HOST}" "rm -f '${SF_BASE_DIR}/${DEST_SUBDIR}'* 2>/dev/null"

    # B. APPLICAZIONE DELLA LOGICA DI CARICAMENTO
    if [ "$DEST_SUBDIR" = "debs/" ]; then
        echo "📦 Rilevata directory Debian Multi-Arch. Scompongo le architetture..."
        
        # Gestione Standard per Debian (amd64 e la neonata riscv64, inclusa arm64)
        for arch in amd64 riscv64 arm64; do
            upload_latest_version "$SRC_DIR" "$DEST_SUBDIR" false "$arch"
        done
        
        # Gestione Legacy per Debian (amd64 e arm64)
        for arch in amd64 arm64; do
            upload_latest_version "$SRC_DIR" "$DEST_SUBDIR" true "$arch"
        done
    else
        # Logica standard lineare per tutti gli altri repository single-arch
        upload_latest_version "$SRC_DIR" "$DEST_SUBDIR" false
        upload_latest_version "$SRC_DIR" "$DEST_SUBDIR" true
    fi
done

echo "---------------------------------------------------"
echo "Chiudo la connessione master..."
ssh -S "$SOCKET" -O exit "${SF_USER}@${SF_HOST}" 2>/dev/null
echo "✅ Script completato con successo."
