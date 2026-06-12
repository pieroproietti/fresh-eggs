#!/bin/bash

# ==============================================================================
# Script di copia per oa-tools su /eggs
# ==============================================================================

# --- Variabili Globali ---
SOURCE="/var/www/html/repos"
DEST="/eggs/"

# remove all
#rm -fr $DEST

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
# Cerca e copia l'ultimo pacchetto base (il [0-9] esclude -doc e -bash-completion)
LAST_ALPINE=$(ls ${SOURCE}/alpine/oa-tools-*.apk | sort -V | tail -n 1)
cp "${LAST_ALPINE}" "${DEST_ALPINE}"

# --- Arch ---
LAST_AUR=$(ls ${SOURCE}/arch/oa-tools-arch*.pkg.tar.zst | sort -V | tail -n 1)
cp "${LAST_AUR}" "${DEST_AUR}"

# --- Debian ---
LAST_DEB=$(ls ${SOURCE}/deb/pool/main/oa-tools_*.deb | sort -V | tail -n 1)
cp "${LAST_DEB}" "${DEST_DEBS}"

# --- Fedora ---
# Usa l'ultima release di Fedora presente in ${SOURCE}/rpm/fedora/
FEDORA_DIR=$(ls -d ${SOURCE}/rpm/fedora/*/ | sort -V | tail -n 1)
LAST_FEDORA=$(ls ${FEDORA_DIR}oa-tools*.rpm | sort -V | tail -n 1)
cp "${LAST_FEDORA}" "${DEST_FEDORA}"

# --- Manjaro ---
LAST_MANJARO=$(ls ${SOURCE}/manjaro/oa-tools-manjaro*.pkg.tar.zst | sort -V | tail -n 1)
cp "${LAST_MANJARO}" "${DEST_MANJARO}"

# --- openSUSE ---
LAST_OPENSUSE=$(ls ${SOURCE}/rpm/opensuse/leap/oa-tools*.rpm | sort -V | tail -n 1)
cp "${LAST_OPENSUSE}" "${DEST_OPENSUSE}"

