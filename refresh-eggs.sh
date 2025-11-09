
# ==============================================================================
# Script di installazione per penguins-eggs
# - Rileva la distribuzione
# - Definisce i pacchetti da scaricare e i comandi da eseguire
# - Esegue il download e l'installazione in un unico flusso
# ==============================================================================

# --- Variabili Globali ---
LAST_RELEASE="25.11.8"
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
mv ${DEST_AUR}/penguins-eggs* ${AUR_OLD_OLD}
rm ${DEST_DEBS}/penguins-eggs* 
rm ${DEST_EL9}/penguins-eggs* 
rm ${DEST_FEDORA}/penguins-eggs* 
mv ${DEST_MANJARO}/penguins-eggs* ${MANJARO_OLD}
rm ${DEST_OPENSUSE}/penguins-eggs* 

# Carica i nuovi
cp ${SOURCE}/alpine/penguins-eggs*.apk ${DEST_ALPINE}
cp ${SOURCE}/arch/penguins-eggs*.pkg.tar.zst ${DEST_AUR}
cp ${SOURCE}/deb/pool/main/penguins-eggs*amd64.deb ${DEST_DEBS}
cp ${SOURCE}/rpm/el9/penguins-eggs*.rpm ${DEST_EL9}
cp ${SOURCE}/rpm/fedora/42/penguins-eggs*.rpm ${DEST_FEDORA}
cp ${SOURCE}/manjaro/penguins-eggs*.pkg.tar.zst ${DEST_MANJARO}
cp ${SOURCE}/rpm/opensuse/leap/penguins-eggs*.rpm ${DEST_OPENSUSE}

