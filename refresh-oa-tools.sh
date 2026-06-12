#!/bin/bash

# ==============================================================================
# Script di copia per oa-tools su /eggs
# (eseguire DOPO refresh-eggs.sh, che svuota e ricrea /eggs)
# ==============================================================================

# --- Variabili Globali ---
SOURCE="/var/www/html/repos"
DEST="/eggs"

ERRORS=0

# Copia in $1 l'ultimo pacchetto (per versione) che corrisponde al glob.
# Se il glob non trova nulla segnala l'errore e prosegue con le altre distro.
function copy_last {
    local dest="$1"
    shift
    local last
    last=$(ls "$@" 2>/dev/null | sort -V | tail -n 1)
    if [ -z "$last" ]; then
        echo "ERRORE: nessun pacchetto trovato per: $*" >&2
        ERRORS=1
        return 1
    fi
    cp "$last" "$dest"
}

# Alpine
DEST_ALPINE="${DEST}/alpine/x86_64"
DEST_AUR="${DEST}/aur"
DEST_DEBS="${DEST}/debs"
DEST_EL9="${DEST}/el9"
DEST_FEDORA="${DEST}/fedora"
DEST_MANJARO="${DEST}/manjaro"
DEST_OPENSUSE="${DEST}/opensuse"

# Crea struttura
mkdir -p ${DEST_ALPINE}
mkdir -p ${DEST_AUR}
mkdir -p ${DEST_DEBS}
mkdir -p ${DEST_EL9}
mkdir -p ${DEST_FEDORA}
mkdir -p ${DEST_MANJARO}
mkdir -p ${DEST_OPENSUSE}


# --- Alpine ---
copy_last "${DEST_ALPINE}" ${SOURCE}/alpine/oa-tools-*.apk

# --- Arch ---
copy_last "${DEST_AUR}" ${SOURCE}/arch/oa-tools-arch*.pkg.tar.zst

# --- Debian ---
copy_last "${DEST_DEBS}" ${SOURCE}/deb/pool/main/oa-tools_*.deb

# --- Fedora ---
# Usa l'ultima release di Fedora presente in ${SOURCE}/rpm/fedora/
FEDORA_DIR=$(ls -d ${SOURCE}/rpm/fedora/*/ 2>/dev/null | sort -V | tail -n 1)
copy_last "${DEST_FEDORA}" ${FEDORA_DIR}oa-tools*.rpm

# --- Manjaro ---
copy_last "${DEST_MANJARO}" ${SOURCE}/manjaro/oa-tools-manjaro*.pkg.tar.zst

# --- openSUSE ---
copy_last "${DEST_OPENSUSE}" ${SOURCE}/rpm/opensuse/leap/oa-tools*.rpm

if [ $ERRORS -ne 0 ]; then
    echo "ERRORE: alcuni pacchetti non sono stati copiati in ${DEST}" >&2
    exit 1
fi
echo "Copia in ${DEST} completata."
