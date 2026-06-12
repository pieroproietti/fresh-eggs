#!/bin/bash

# ==============================================================================
# Aggiorna le destinazioni di distribuzione con gli ultimi pacchetti
# prodotti dal CI in /var/www/html/repos.
#
# Uso: ./refresh.sh basket|sourceforge [...]
#   basket       aggiorna il basket (penguins-eggs.net/basket) con
#                penguins-eggs + oa-tools e genera LATEST
#   sourceforge  svuota /eggs, lo ripopola con penguins-eggs + oa-tools
#                e lo carica via rsync/ssh su
#                sourceforge.net/projects/penguins-eggs (cartella Packages)
#
# I target si possono combinare, es: ./refresh.sh basket sourceforge
# ==============================================================================

SOURCE="/var/www/html/repos"
BASKET="/home/artisan/basket/packages"
EGGS="/eggs"

# Upload su SourceForge: richiede la chiave ssh del server registrata
# sull'account (sourceforge.net -> Account Settings -> SSH Settings)
# oppure la password nel file SF_PASSWD_FILE (fuori dal repo, chmod 600;
# in tal caso serve sshpass installato).
SF_USER="pproietti"
SF_DEST="/home/frs/project/penguins-eggs/Packages"
SF_PASSWD_FILE="$(dirname "$0")/../.sf-passwd.txt"

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
    copy_last "${dest}/alpine/x86_64" ${SOURCE}/alpine/penguins-eggs-[0-9]*.apk
    copy_last "${dest}/alpine/x86_64" ${SOURCE}/alpine/penguins-eggs-bash-completion*.apk
    copy_last "${dest}/alpine/x86_64" ${SOURCE}/alpine/penguins-eggs-doc*.apk

    # --- Arch ---
    copy_last "${dest}/aur" ${SOURCE}/arch/penguins-eggs*.pkg.tar.zst

    # --- Debian ---
    copy_last "${dest}/debs" ${SOURCE}/deb/pool/main/penguins-eggs_*amd64.deb
    copy_last "${dest}/debs" ${SOURCE}/deb/pool/main/penguins-eggs_*arm64.deb
    copy_last "${dest}/debs" ${SOURCE}/deb/pool/main/penguins-eggs_*i386.deb
    copy_last "${dest}/debs" ${SOURCE}/deb/pool/main/penguins-eggs_*riscv64.deb

    # --- EL (RHEL/Rocky/Alma: el9, el10, ...) ---
    # Copia ogni release EL presente in ${SOURCE}/rpm/
    local el_dir el_name
    for el_dir in ${SOURCE}/rpm/el[0-9]*/; do
        if [ ! -d "$el_dir" ]; then
            echo "ERRORE: nessuna directory el* in ${SOURCE}/rpm/" >&2
            ERRORS=1
            break
        fi
        el_name=$(basename "$el_dir")
        mkdir -p "${dest}/${el_name}"
        rm -f ${dest}/${el_name}/penguins-eggs*
        copy_last "${dest}/${el_name}" ${el_dir}penguins-eggs*.rpm
    done

    # --- Fedora ---
    # Usa l'ultima release di Fedora presente in ${SOURCE}/rpm/fedora/
    local fedora_dir
    fedora_dir=$(ls -d ${SOURCE}/rpm/fedora/*/ 2>/dev/null | sort -V | tail -n 1)
    copy_last "${dest}/fedora" ${fedora_dir}penguins-eggs*.rpm

    # --- Manjaro ---
    copy_last "${dest}/manjaro" ${SOURCE}/manjaro/penguins-eggs*.pkg.tar.zst

    # --- openSUSE ---
    copy_last "${dest}/opensuse" ${SOURCE}/rpm/opensuse/leap/penguins-eggs*.rpm
}

# Copia gli ultimi pacchetti oa-tools sotto $1
function copy_oa_tools {
    local dest="$1"
    make_dirs "${dest}"

    copy_last "${dest}/alpine/x86_64" ${SOURCE}/alpine/oa-tools-*.apk
    copy_last "${dest}/aur" ${SOURCE}/arch/oa-tools-arch*.pkg.tar.zst
    copy_last "${dest}/debs" ${SOURCE}/deb/pool/main/oa-tools_*.deb

    local fedora_dir
    fedora_dir=$(ls -d ${SOURCE}/rpm/fedora/*/ 2>/dev/null | sort -V | tail -n 1)
    copy_last "${dest}/fedora" ${fedora_dir}oa-tools*.rpm

    copy_last "${dest}/manjaro" ${SOURCE}/manjaro/oa-tools-manjaro*.pkg.tar.zst
    copy_last "${dest}/opensuse" ${SOURCE}/rpm/opensuse/leap/oa-tools*.rpm
}

# Nel basket i vecchi pacchetti di alpine/aur/manjaro vengono archiviati
# in old/, gli altri eliminati (gli el* li ripulisce il ciclo EL).
# Al primo giro le cartelle sono vuote: i mv falliscono in silenzio.
function archive_old_basket {
    local dest="$1" pkg
    mkdir -p "${dest}/alpine/x86_64/old" "${dest}/aur/old" "${dest}/manjaro/old"
    for pkg in penguins-eggs oa-tools; do
        mv ${dest}/alpine/x86_64/${pkg}* "${dest}/alpine/x86_64/old" 2>/dev/null
        mv ${dest}/aur/${pkg}* "${dest}/aur/old" 2>/dev/null
        mv ${dest}/manjaro/${pkg}* "${dest}/manjaro/old" 2>/dev/null
        rm -f ${dest}/debs/${pkg}* ${dest}/fedora/${pkg}* ${dest}/opensuse/${pkg}*
    done
}

# Genera il file LATEST letto da fresh-eggs.sh per conoscere versione e
# release correnti. Ricava i valori dal nome del deb amd64 appena copiato,
# es. penguins-eggs_26.6.2-1_amd64.deb -> 26.6.2 e 1
function make_latest {
    local dest="$1"
    local pkg ver_rel last_version last_release fedora_tag
    pkg=$(basename "$(ls ${dest}/debs/penguins-eggs_*amd64.deb 2>/dev/null | sort -V | tail -n 1)")
    ver_rel="${pkg#penguins-eggs_}"
    ver_rel="${ver_rel%%_*}"
    last_version="${ver_rel%-*}"
    last_release="${ver_rel##*-}"

    # Tag fedora (fc42, fc43, ...) dal nome dell'rpm appena copiato nel basket
    fedora_tag=$(ls ${dest}/fedora/penguins-eggs*.rpm 2>/dev/null | sort -V | tail -n 1 | grep -o 'fc[0-9]*')

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

# Carica /eggs su SourceForge. Niente --delete: come con FileZilla,
# i pacchetti delle release precedenti restano online.
function upload_sourceforge {
    local rsh="ssh -o StrictHostKeyChecking=accept-new"
    if [ -f "${SF_PASSWD_FILE}" ]; then
        if ! command -v sshpass >/dev/null 2>&1; then
            echo "ERRORE: trovato ${SF_PASSWD_FILE} ma sshpass non è installato" >&2
            exit 1
        fi
        rsh="sshpass -f ${SF_PASSWD_FILE} ${rsh}"
    fi
    echo "Upload di ${EGGS}/ su SourceForge (${SF_DEST})..."
    if ! rsync -av -e "${rsh}" "${EGGS}/" "${SF_USER}@frs.sourceforge.net:${SF_DEST}/"; then
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
            archive_old_basket "${BASKET}"
            copy_eggs "${BASKET}"
            copy_oa_tools "${BASKET}"
            DID_BASKET=1
            ;;
        sourceforge)
            # :? blocca il comando se EGGS fosse vuota
            rm -fr "${EGGS:?}"
            copy_eggs "${EGGS}"
            copy_oa_tools "${EGGS}"
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
