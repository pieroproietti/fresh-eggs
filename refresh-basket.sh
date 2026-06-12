#!/bin/bash

# ==============================================================================
# Aggiorna il basket (penguins-eggs.net/basket) con gli ultimi pacchetti
# prodotti dal CI in /var/www/html/repos e genera il file LATEST.
# ==============================================================================

# --- Variabili Globali ---
SOURCE="/var/www/html/repos"
DEST="/home/artisan/basket/packages"

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
mkdir -p ${DEST_FEDORA}
mkdir -p ${MANJARO_OLD}
mkdir -p ${DEST_OPENSUSE}

# Sposta/elimina i vecchi pacchetti (al primo giro le cartelle sono vuote)
mv ${DEST_ALPINE}/penguins-eggs* ${ALPINE_OLD} 2>/dev/null
mv ${DEST_AUR}/penguins-eggs* ${AUR_OLD} 2>/dev/null
rm -f ${DEST_DEBS}/penguins-eggs*
rm -f ${DEST_FEDORA}/penguins-eggs*
mv ${DEST_MANJARO}/penguins-eggs* ${MANJARO_OLD} 2>/dev/null
rm -f ${DEST_OPENSUSE}/penguins-eggs*


# --- Alpine ---
# il [0-9] esclude -doc e -bash-completion
copy_last "${DEST_ALPINE}" ${SOURCE}/alpine/penguins-eggs-[0-9]*.apk
copy_last "${DEST_ALPINE}" ${SOURCE}/alpine/penguins-eggs-bash-completion*.apk
copy_last "${DEST_ALPINE}" ${SOURCE}/alpine/penguins-eggs-doc*.apk

# --- Arch ---
copy_last "${DEST_AUR}" ${SOURCE}/arch/penguins-eggs*.pkg.tar.zst

# --- Debian ---
copy_last "${DEST_DEBS}" ${SOURCE}/deb/pool/main/penguins-eggs_*amd64.deb
copy_last "${DEST_DEBS}" ${SOURCE}/deb/pool/main/penguins-eggs_*arm64.deb
copy_last "${DEST_DEBS}" ${SOURCE}/deb/pool/main/penguins-eggs_*i386.deb
copy_last "${DEST_DEBS}" ${SOURCE}/deb/pool/main/penguins-eggs_*riscv64.deb

# --- EL (RHEL/Rocky/Alma: el9, el10, ...) ---
# Copia ogni release EL presente in ${SOURCE}/rpm/
for EL_DIR in ${SOURCE}/rpm/el[0-9]*/; do
    if [ ! -d "$EL_DIR" ]; then
        echo "ERRORE: nessuna directory el* in ${SOURCE}/rpm/" >&2
        ERRORS=1
        break
    fi
    EL_NAME=$(basename "$EL_DIR")
    mkdir -p "${DEST}/${EL_NAME}"
    rm -f ${DEST}/${EL_NAME}/penguins-eggs*
    copy_last "${DEST}/${EL_NAME}" ${EL_DIR}penguins-eggs*.rpm
done

# --- Fedora ---
# Usa l'ultima release di Fedora presente in ${SOURCE}/rpm/fedora/
FEDORA_DIR=$(ls -d ${SOURCE}/rpm/fedora/*/ 2>/dev/null | sort -V | tail -n 1)
copy_last "${DEST_FEDORA}" ${FEDORA_DIR}penguins-eggs*.rpm

# --- Manjaro ---
copy_last "${DEST_MANJARO}" ${SOURCE}/manjaro/penguins-eggs*.pkg.tar.zst

# --- openSUSE ---
copy_last "${DEST_OPENSUSE}" ${SOURCE}/rpm/opensuse/leap/penguins-eggs*.rpm

# Se qualche pacchetto manca non aggiorna LATEST: meglio un basket vecchio
# ma coerente che uno nuovo incompleto.
if [ $ERRORS -ne 0 ]; then
    echo "ERRORE: alcuni pacchetti non sono stati copiati, LATEST non aggiornato" >&2
    exit 1
fi

# --- LATEST ---
# Genera il file LATEST letto da fresh-eggs.sh per conoscere versione e release
# correnti. Ricava i valori dal nome del deb amd64 appena copiato,
# es. penguins-eggs_26.6.2-1_amd64.deb -> 26.6.2 e 1
PKG=$(basename "$(ls ${DEST_DEBS}/penguins-eggs_*amd64.deb 2>/dev/null | sort -V | tail -n 1)")
VER_REL="${PKG#penguins-eggs_}"
VER_REL="${VER_REL%%_*}"
LAST_VERSION="${VER_REL%-*}"
LAST_RELEASE="${VER_REL##*-}"

# Tag fedora (fc42, fc43, ...) dal nome dell'rpm appena copiato nel basket
FEDORA_TAG=$(ls ${DEST_FEDORA}/penguins-eggs*.rpm 2>/dev/null | sort -V | tail -n 1 | grep -o 'fc[0-9]*')

if [ -n "$LAST_VERSION" ] && [ -n "$LAST_RELEASE" ]; then
    cat > "${DEST}/LATEST" <<EOF
LAST_VERSION=${LAST_VERSION}
LAST_RELEASE=${LAST_RELEASE}
FEDORA_TAG=${FEDORA_TAG}
EOF
    echo "LATEST aggiornato: ${LAST_VERSION}-${LAST_RELEASE}"
else
    echo "ERRORE: impossibile ricavare la versione, LATEST non aggiornato" >&2
    exit 1
fi
