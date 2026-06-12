#!/bin/bash

# ==============================================================================
# Aggiorna le destinazioni di distribuzione con gli ultimi pacchetti
# prodotti dal CI in /var/www/html/repos.
#
# Uso: ./refresh.sh basket|eggs|oa-tools [...]
#   basket    aggiorna il basket (penguins-eggs.net/basket) e genera LATEST
#   eggs      svuota /eggs e lo ripopola con penguins-eggs
#   oa-tools  aggiunge oa-tools a /eggs (eseguire dopo eggs)
#
# I target si possono combinare, es: ./refresh.sh eggs oa-tools
# ==============================================================================

SOURCE="/var/www/html/repos"
BASKET="/home/artisan/basket/packages"
EGGS="/eggs"

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
    local dest="$1"
    mkdir -p "${dest}/alpine/x86_64/old" "${dest}/aur/old" "${dest}/manjaro/old"
    mv ${dest}/alpine/x86_64/penguins-eggs* "${dest}/alpine/x86_64/old" 2>/dev/null
    mv ${dest}/aur/penguins-eggs* "${dest}/aur/old" 2>/dev/null
    mv ${dest}/manjaro/penguins-eggs* "${dest}/manjaro/old" 2>/dev/null
    rm -f ${dest}/debs/penguins-eggs* ${dest}/fedora/penguins-eggs* ${dest}/opensuse/penguins-eggs*
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

# ==============================================================================
# --- Esecuzione ---
# ==============================================================================

if [ $# -eq 0 ]; then
    echo "Uso: $0 basket|eggs|oa-tools [...]" >&2
    exit 1
fi

DID_BASKET=0
for target in "$@"; do
    case "$target" in
        basket)
            archive_old_basket "${BASKET}"
            copy_eggs "${BASKET}"
            DID_BASKET=1
            ;;
        eggs)
            # :? blocca il comando se EGGS fosse vuota
            rm -fr "${EGGS:?}"
            copy_eggs "${EGGS}"
            ;;
        oa-tools)
            copy_oa_tools "${EGGS}"
            ;;
        *)
            echo "ERRORE: target sconosciuto: $target (basket|eggs|oa-tools)" >&2
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

echo "Refresh completato: $*"
