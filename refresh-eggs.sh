#!/bin/bash

# ==============================================================================
# Script di installazione per penguins-eggs
# - Rileva la distribuzione
# - Definisce i pacchetti da scaricare e i comandi da eseguire
# - Esegue il download e l'installazione in un unico flusso
# ==============================================================================

# --- Variabili Globali ---
#LAST_RELEASE="25.11.12"
SOURCE="/var/www/html/repos"
DEST="/home/artisan/basket/packages"
# Alpine
DEST_ALPINE="${DEST}/alpine/x86_64"
DEST_AUR="${DEST}/aur"
DEST_DEBS="${DEST}/debs"
DEST_EL9="${DEST}/el9"
DEST_FEDORA="${DEST}/fedora"
DEST_MANJARO="${DEST}/manjaro"
DEST_OPENSUSE="${DEST}/opensuse"

# pacchetti old
ALPINE_OLD="${DEST_ALPINE}/old"
AUR_OLD="${DEST_AUR}/old"
MANJARO_OLD="${DEST_MANJARO}/old"

# Crea struttura
mkdir -p ${ALPINE_OLD}
mkdir -p ${AUR_OLD}
mkdir -p ${DEST_DEBS}
mkdir -p ${DEST_EL9}
mkdir -p ${DEST_FEDORA}
mkdir -p ${MANJARO_OLD}
mkdir -p ${DEST_OPENSUSE}

# Sposta/elimina i vecchi pacchetti
mv ${DEST_ALPINE}/penguins-eggs* ${ALPINE_OLD}
mv ${DEST_AUR}/penguins-eggs* ${AUR_OLD}
rm ${DEST_DEBS}/penguins-eggs* 
rm ${DEST_EL9}/penguins-eggs* 
rm ${DEST_FEDORA}/penguins-eggs* 
mv ${DEST_MANJARO}/penguins-eggs* ${MANJARO_OLD}
rm ${DEST_OPENSUSE}/penguins-eggs* 


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
LAST_DEB=$(ls ${SOURCE}/deb/pool/main/penguins-eggs*amd64.deb | sort -V | tail -n 1)
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

