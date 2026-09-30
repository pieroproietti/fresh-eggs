#!/bin/bash

# Funzione per scoprire automaticamente l'ultima versione disponibile sul server
function discover_latest {
    local file_pattern="$1"
    local repo_url="${URL_BASE}/${FOLDER}/"
    
    echo ">> Rilevamento versione in: ${FOLDER}..."
    
    # Recupera l'elenco, filtra, ordina e prendi l'ultimo
    local latest_file
    latest_file=$(curl -sL "$repo_url" | grep -oP "$file_pattern" | sort -V | tail -n 1)

    if [[ -z "$latest_file" ]]; then
        echo ">> Error: nessun pacchetto trovato in ${repo_url} con pattern ${file_pattern}" >&2
        return 1
    fi

    # Estrazione universale versione e release (funziona con _ o - come separatori)
    LAST_VERSION=$(echo "$latest_file" | sed -E 's/.*[-_]([0-9.]+)-([0-9]+).*/\1/')
    LAST_RELEASE=$(echo "$latest_file" | sed -E 's/.*[-_]([0-9.]+)-([0-9]+).*/\2/')
    
    echo ">> Rilevato: ${LAST_VERSION}-${LAST_RELEASE}"
}

function not_supported {
    echo "Your distribution ($PRETTY_NAME) is not supported." >&2
    exit 1
}

function prepare_aur {
    FOLDER="arch"
    discover_latest "penguins-eggs-legacy-[0-9.]*-[0-9]*-any\.pkg\.tar\.zst"
    PACKAGES=("penguins-eggs-legacy-${LAST_VERSION}-${LAST_RELEASE}-any.pkg.tar.zst")
    INSTALL_CMDS=("pacman -U --noconfirm /tmp/${PACKAGES[0]}")
}

function prepare_alpine {
    FOLDER="alpine/x86_64"
    discover_latest "penguins-eggs-legacy-[0-9.]*-r[0-9]*\.apk"
    PACKAGES=(
        "penguins-eggs-legacy-${LAST_VERSION}-r${LAST_RELEASE}.apk"
        "penguins-eggs-legacy-bash-completion-${LAST_VERSION}-r${LAST_RELEASE}.apk"
        "penguins-eggs-legacy-doc-${LAST_VERSION}-r${LAST_RELEASE}.apk"
    )
    INSTALL_CMDS=("apk add --allow-untrusted /tmp/${PACKAGES[0]} /tmp/${PACKAGES[1]} /tmp/${PACKAGES[2]}")
}

function prepare_debs {
    FOLDER="deb/pool/main"
    ARCHITECTURE=$(dpkg --print-architecture)
    discover_latest "penguins-eggs-legacy_[0-9.]*-[0-9]*_${ARCHITECTURE}\.deb"
    PACKAGES=("penguins-eggs-legacy_${LAST_VERSION}-${LAST_RELEASE}_${ARCHITECTURE}.deb")
    INSTALL_CMDS=("apt-get install /tmp/${PACKAGES[0]} -y")
}

function prepare_fedora_or_el {
    if [[ "$ID" == "rhel" || "$ID_LIKE" == *rhel* ]]; then
        EL_MAJOR="${VERSION_ID%%.*}"
        FOLDER="rpm/el${EL_MAJOR}/x86_64"
        discover_latest "penguins-eggs-legacy-[0-9.]*-[0-9]*\.el${EL_MAJOR}\.x86_64\.rpm"
        PACKAGES=("penguins-eggs-legacy-${LAST_VERSION}-${LAST_RELEASE}.el${EL_MAJOR}.x86_64.rpm")
        INSTALL_CMDS=("dnf install -y /tmp/${PACKAGES[0]}")
    else
        FEDORA_VER="${FEDORA_TAG#fc}"
        FOLDER="rpm/fedora/${FEDORA_VER}/x86_64"
        discover_latest "penguins-eggs-legacy-[0-9.]*-[0-9]*\.${FEDORA_TAG}\.x86_64\.rpm"
        PACKAGES=("penguins-eggs-legacy-${LAST_VERSION}-${LAST_RELEASE}.${FEDORA_TAG}.x86_64.rpm")
        INSTALL_CMDS=("dnf install -y /tmp/${PACKAGES[0]}")
    fi
}

function prepare_manjaro {
    FOLDER="manjaro"
    discover_latest "penguins-eggs-legacy-[0-9.]*-[0-9]*-any\.pkg\.tar\.zst"
    PACKAGES=("penguins-eggs-legacy-${LAST_VERSION}-${LAST_RELEASE}-any.pkg.tar.zst")
    INSTALL_CMDS=("pacman -U --noconfirm /tmp/${PACKAGES[0]}")
}

function prepare_openmamba {
    FOLDER="openmamba"
    discover_latest "penguins-eggs-legacy-[0-9.]*-[0-9]*mamba\.x86_64\.rpm"
    PACKAGES=("penguins-eggs-legacy-${LAST_VERSION}-${LAST_RELEASE}mamba.x86_64.rpm")
    INSTALL_CMDS=("dnf install /tmp/${PACKAGES[0]}")
}

function prepare_opensuse {
    FOLDER="rpm/opensuse/leap/x86_64"
    discover_latest "penguins-eggs-legacy-[0-9.]*-[0-9]*\.x86_64\.rpm"
    PACKAGES=("penguins-eggs-legacy-${LAST_VERSION}-${LAST_RELEASE}.x86_64.rpm")
    INSTALL_CMDS=("zypper --non-interactive install --allow-unsigned-rpm /tmp/${PACKAGES[0]}")
}
