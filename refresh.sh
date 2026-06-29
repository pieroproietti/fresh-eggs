#!/bin/bash

# ==============================================================================
# Aggiorna le destinazioni di distribuzione con gli ultimi pacchetti
# prodotti dal CI in /var/www/html/repos.
#
# Uso: ./refresh.sh basket|sourceforge [...]
#   basket       aggiorna il basket (penguins-eggs.net/basket) con
#                penguins-eggs-legacy + penguins-eggs e genera LATEST
#   sourceforge  svuota /eggs, lo ripopola con penguins-eggs-legacy + penguins-eggs
#                e lo carica via rsync/ssh su
#                sourceforge.net/projects/penguins-eggs (cartella Packages)
#
# I target si possono combinare, es: ./refresh.sh basket sourceforge
# ==============================================================================

SOURCE="/var/www/html/repos"
BASKET="/var/www/html/basket/packages"
EGGS="/eggs"

# Upload su SourceForge: richiede la chiave ssh dell'utente registrata
# sull'account (sourceforge.net -> Account Settings -> SSH Settings).
# Lo script va lanciato come utente normale, non con sudo: /eggs e il
# basket devono appartenere all'utente (una tantum: sudo chown).
SF_USER="pproietti"
SF_DEST="/home/frs/project/penguins-eggs/Packages"

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

# Crea le sottocartelle per distro sotto $1
function make_dirs {
    local dest="$1"
    mkdir -p "${dest}/alpine/x86_64" "${dest}/aur" "${dest}/debs" \
             "${dest}/fedora" "${dest}/manjaro" "${dest}/opensuse"
}

# Copia gli ultimi pacchetti penguins-eggs sotto $1
function copy_eggs {
    local dest="$1"
    make_dirs "${dest}"

    # --- Alpine ---
    # il [0-9] esclude -doc e -bash-completion
    #copy_last "${dest}/alpine/x86_64" ${SOURCE}/alpine/x86_64/penguins-eggs-legacy-[0-9]*.apk
    #copy_last "${dest}/alpine/x86_64" ${SOURCE}/alpine/x86_64/penguins-eggs-legacy-bash-completion*.apk
    #copy_last "${dest}/alpine/x86_64" ${SOURCE}/alpine/x86_64/penguins-eggs-legacy-doc*.apk

    # --- Arch ---
    copy_last "${dest}/aur" ${SOURCE}/arch/penguins-eggs-legacy*.pkg.tar.zst

    # --- Debian ---
    copy_last "${dest}/debs" ${SOURCE}/deb/pool/main/penguins-eggs-legacy_*amd64.deb
    copy_last "${dest}/debs" ${SOURCE}/deb/pool/main/penguins-eggs-legacy_*arm64.deb
    copy_last "${dest}/debs" ${SOURCE}/deb/pool/main/penguins-eggs-legacy_*i386.deb
    copy_last "${dest}/debs" ${SOURCE}/deb/pool/main/penguins-eggs-legacy_*riscv64.deb

    # --- EL (RHEL/Rocky/Alma: el9, el10, ...) ---
    # Copia ogni release EL presente in ${SOURCE}/rpm/
    local el_dir el_name
    for el_dir in ${SOURCE}/rpm/el[0-9]*/x86_64/; do
        if [ ! -d "$el_dir" ]; then
            echo "ERRORE: nessuna directory el* in ${SOURCE}/rpm/" >&2
            ERRORS=1
            break
        fi
        el_name=$(basename "$el_dir")
        mkdir -p "${dest}/${el_name}"
        rm -f ${dest}/${el_name}/penguins-eggs-legacy*
        copy_last "${dest}/${el_name}" ${el_dir}penguins-eggs-legacy*.rpm
    done

    # --- Fedora ---
    # Usa l'ultima release di Fedora presente in ${SOURCE}/rpm/fedora/
    local fedora_dir
    fedora_dir=$(ls -d ${SOURCE}/rpm/fedora/*/x86_64 2>/dev/null | sort -V | tail -n 1)
    copy_last "${dest}/fedora" ${fedora_dir}/x86_64/penguins-eggs-legacy*.rpm

    # --- Manjaro ---
    copy_last "${dest}/manjaro" ${SOURCE}/manjaro/penguins-eggs-legacy*.pkg.tar.zst

    # --- openSUSE ---
    copy_last "${dest}/opensuse" ${SOURCE}/rpm/opensuse/leap/penguins-eggs-legacy*.rpm
}

# Copia gli ultimi pacchetti penguins-eggs sotto $1
function copy_penguins_eggs {
    local dest="$1"
    make_dirs "${dest}"

    copy_last "${dest}/alpine/x86_64" ${SOURCE}/alpine/penguins-eggs-*.apk
    copy_last "${dest}/aur" ${SOURCE}/arch/penguins-eggs-arch*.pkg.tar.zst
    copy_last "${dest}/debs" ${SOURCE}/deb/pool/main/penguins-eggs_*.deb

    local fedora_dir
    fedora_dir=$(ls -d ${SOURCE}/rpm/fedora/*/ 2>/dev/null | sort -V | tail -n 1)
    copy_last "${dest}/fedora" ${fedora_dir}penguins-eggs*.rpm

    copy_last "${dest}/manjaro" ${SOURCE}/manjaro/penguins-eggs-manjaro*.pkg.tar.zst
    copy_last "${dest}/opensuse" ${SOURCE}/rpm/opensuse/leap/penguins-eggs*.rpm
}

# Rimuove dal basket i pacchetti del giro precedente prima di copiare
# i nuovi (gli el* li ripulisce il ciclo EL). Le versioni passate restano
# disponibili nelle release su GitHub: niente più archivio in old/.
function clean_basket {
    local dest="$1" pkg
    for pkg in penguins-eggs-legacy penguins-eggs; do
        rm -f ${dest}/alpine/x86_64/${pkg}* ${dest}/aur/${pkg}* \
              ${dest}/manjaro/${pkg}* ${dest}/debs/${pkg}* \
              ${dest}/fedora/${pkg}* ${dest}/opensuse/${pkg}*
    done
}

# Genera il file LATEST letto da fresh-eggs.sh per conoscere versione e
# release correnti. Ricava i valori dal nome del deb amd64 appena copiato,
# es. penguins-eggs_26.6.2-1_amd64.deb -> 26.6.2 e 1
function make_latest {
    local dest="$1"
    local pkg ver_rel last_version last_release fedora_tag
    pkg=$(basename "$(ls ${dest}/debs/penguins-eggs-legacy_*amd64.deb 2>/dev/null | sort -V | tail -n 1)")
    ver_rel="${pkg#penguins-eggs-legacy_}"
    ver_rel="${ver_rel%%_*}"
    last_version="${ver_rel%-*}"
    last_release="${ver_rel##*-}"

    # Tag fedora (fc42, fc43, ...) dal nome dell'rpm appena copiato nel basket
    fedora_tag=$(ls ${dest}/fedora/penguins-eggs-legacy*.rpm 2>/dev/null | sort -V | tail -n 1 | grep -o 'fc[0-9]*')

    if [ -n "$last_version" ] && [ -n "$last_release" ]; then
        cat > "${dest}/LATEST" <<EOF
LAST_VERSION=${last_version}
LAST_RELEASE=${last_release}
FEDORA_TAG=${fedora_tag}
EOF
        echo "LATEST aggiornato: ${last_version}-${last_release}"
    else
        echo "ERRORE: impossibile ricavare la versione, LATEST non aggiornato" >&2
        exit 1
    fi
}

# Carica /eggs su SourceForge. Con --delete la cartella Packages diventa
# lo specchio esatto di /eggs: i pacchetti delle release precedenti vengono
# rimossi. Gli --exclude proteggono dalla cancellazione i contenuti extra
# di Packages che non vivono in /eggs.
function upload_sourceforge {
    # Se lo script gira con sudo, l'upload torna all'utente reale:
    # è la sua chiave ssh ad essere registrata su SourceForge, non quella di root.
    local runas=()
    if [ "$EUID" -eq 0 ] && [ -n "$SUDO_USER" ]; then
        runas=(sudo -u "$SUDO_USER")
    fi
    echo "Upload di ${EGGS}/ su SourceForge (${SF_DEST})..."
    if ! "${runas[@]}" rsync -av --delete \
            --exclude=README.md --exclude=tarballs/ \
            -e "ssh -o StrictHostKeyChecking=accept-new" \
            "${EGGS}/" "${SF_USER}@frs.sourceforge.net:${SF_DEST}/"; then
        echo "ERRORE: upload su SourceForge fallito" >&2
        exit 1
    fi
    echo "Upload su SourceForge completato."
}

# ==============================================================================
# --- Esecuzione ---
# ==============================================================================

if [ $# -eq 0 ]; then
    echo "Uso: $0 basket|sourceforge [...]" >&2
    exit 1
fi

DID_BASKET=0
DID_SOURCEFORGE=0
for target in "$@"; do
    case "$target" in
        basket)
            # Come per /eggs: niente sudo, il basket sotto /var/www deve
            # appartenere all'utente (i file restano leggibili dal web server)
            if [ ! -d "${BASKET}" ] || [ ! -w "${BASKET}" ]; then
                echo "ERRORE: ${BASKET} non esiste o non è scrivibile da $(whoami)." >&2
                echo "Esegui una tantum: sudo mkdir -p ${BASKET} && sudo chown -R \$USER ${BASKET%/*}" >&2
                exit 1
            fi
            clean_basket "${BASKET}"
            copy_eggs "${BASKET}"
            copy_penguins_eggs "${BASKET}"
            DID_BASKET=1
            ;;
        sourceforge)
            # /eggs viene svuotata, non rimossa: così può appartenere
            # all'utente e non serve sudo (:? blocca se EGGS fosse vuota)
            if [ ! -d "${EGGS}" ] || [ ! -w "${EGGS}" ]; then
                echo "ERRORE: ${EGGS} non esiste o non è scrivibile da $(whoami)." >&2
                echo "Esegui una tantum: sudo mkdir -p ${EGGS} && sudo chown \$USER ${EGGS}" >&2
                exit 1
            fi
            rm -rf "${EGGS:?}"/*
            copy_eggs "${EGGS}"
            copy_penguins_eggs "${EGGS}"
            DID_SOURCEFORGE=1
            ;;
        *)
            echo "ERRORE: target sconosciuto: $target (basket|sourceforge)" >&2
            exit 1
            ;;
    esac
done

# Se qualche pacchetto manca non aggiorna LATEST: meglio un basket vecchio
# ma coerente che uno nuovo incompleto.
if [ $ERRORS -ne 0 ]; then
    echo "ERRORE: alcuni pacchetti non sono stati copiati" >&2
    exit 1
fi

if [ $DID_BASKET -eq 1 ]; then
    make_latest "${BASKET}"
fi

if [ $DID_SOURCEFORGE -eq 1 ]; then
    upload_sourceforge
fi

echo "Refresh completato: $*"
