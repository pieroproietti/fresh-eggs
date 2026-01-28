#!/bin/bash

# ==============================================================================
# Script di installazione per penguins-eggs
# - Rileva la distribuzione
# - Definisce i pacchetti da scaricare e i comandi da eseguire
# - Esegue il download e l'installazione in un unico flusso
# ==============================================================================

# --- Variabili Globali ---
SOURCE="/var/www/html/repos"
DEST="/eggs/"

# remove all
rm -fr $DEST

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
LAST_ALPINE_BASE=$(ls ${SOURCE}/alpine/penguins-eggs-[0-9]*.apk | sort -V | tail -n 1)
cp "${LAST_ALPINE_BASE}" "${DEST_ALPINE}"

# Cerca e copia l'ultimo pacchetto bash-completion
LAST_ALPINE_BASH=$(ls ${SOURCE}/alpine/penguins-eggs-bash-completion*.apk | sort -V | tail -n 1)
cp "${LAST_ALPINE_BASH}" "${DEST_ALPINE}"

# Cerca e copia l'ultimo pacchetto doc
LAST_ALPINE_DOC=$(ls ${SOURCE}/alpine/penguins-eggs-doc*.apk | sort -V | tail -n 1)
cp "${LAST_ALPINE_DOC}" "${DEST_ALPINE}"

# --- Arch ---
LAST_AUR=$(ls ${SOURCE}/arch/penguins-eggs*.pkg.tar.zst | sort -V | tail -n 1)
cp "${LAST_AUR}" "${DEST_AUR}"

# --- Debian ---
LAST_DEB=$(ls ${SOURCE}/deb/pool/main/penguins-eggs_26.*amd64.deb | sort -V | tail -n 1)
cp "${LAST_DEB}" "${DEST_DEBS}"

LAST_DEB=$(ls ${SOURCE}/deb/pool/main/penguins-eggs_26.*arm64.deb | sort -V | tail -n 1)
cp "${LAST_DEB}" "${DEST_DEBS}"

LAST_DEB=$(ls ${SOURCE}/deb/pool/main/penguins-eggs_26.*i386.deb | sort -V | tail -n 1)
cp "${LAST_DEB}" "${DEST_DEBS}"

LAST_DEB=$(ls ${SOURCE}/deb/pool/main/penguins-eggs_26.*riscv64.deb | sort -V | tail -n 1)
cp "${LAST_DEB}" "${DEST_DEBS}"

# --- EL9 (RHEL/Rocky/Alma) ---
LAST_EL9=$(ls ${SOURCE}/rpm/el9/penguins-eggs*.rpm | sort -V | tail -n 1)
cp "${LAST_EL9}" "${DEST_EL9}"

# --- Fedora ---
LAST_FEDORA=$(ls ${SOURCE}/rpm/fedora/42/penguins-eggs*.rpm | sort -V | tail -n 1)
cp "${LAST_FEDORA}" "${DEST_FEDORA}"

# --- Manjaro ---
LAST_MANJARO=$(ls ${SOURCE}/manjaro/penguins-eggs*.pkg.tar.zst | sort -V | tail -n 1)
cp "${LAST_MANJARO}" "${DEST_MANJARO}"

# --- openSUSE ---
LAST_OPENSUSE=$(ls ${SOURCE}/rpm/opensuse/leap/penguins-eggs*.rpm | sort -V | tail -n 1)
cp "${LAST_OPENSUSE}" "${DEST_OPENSUSE}"

