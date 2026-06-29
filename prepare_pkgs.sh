#!/bin/bash

function not_supported {
        echo "Your distribution ($PRETTY_NAME) is not supported." >&2
        exit 1
}

function prepare_aur {
    # Allineato al percorso reale della repo
    FOLDER="arch"
    PACKAGES=("penguins-eggs-legacy-${LAST_VERSION}-${LAST_RELEASE}-any.pkg.tar.zst")
    INSTALL_CMDS=("pacman -U --noconfirm /tmp/${PACKAGES[0]}")
}

function prepare_alpine {
    FOLDER="alpine/x86_64"
    PACKAGES=(
        "penguins-eggs-legacy-${LAST_VERSION}-r${LAST_RELEASE}.apk"
        "penguins-eggs-legacy-bash-completion-${LAST_VERSION}-r${LAST_RELEASE}.apk"
        "penguins-eggs-legacy-doc-${LAST_VERSION}-r${LAST_RELEASE}.apk"
    )
    INSTALL_CMDS=("apk add --allow-untrusted /tmp/${PACKAGES[0]} /tmp/${PACKAGES[1]} /tmp/${PACKAGES[2]}")
}

function prepare_debs {
    # Allineato al percorso reale della repo
    FOLDER="deb/pool/main"
    ARCHITECTURE=$(dpkg --print-architecture)
    PACKAGES=("penguins-eggs-legacy_${LAST_VERSION}-${LAST_RELEASE}_${ARCHITECTURE}.deb")
    # In debian -y va dopo!
    INSTALL_CMDS=(
        "apt-get install /tmp/${PACKAGES[0]} -y"
    )
}

function prepare_fedora_or_el {
    if [[ "$ID" == "rhel" || "$ID_LIKE" == *rhel* ]]; then
        EL_MAJOR="${VERSION_ID%%.*}"
        # Allineato al nuovo albero RPM
        FOLDER="rpm/el${EL_MAJOR}/x86_64"
        PACKAGES=("penguins-eggs-legacy-${LAST_VERSION}-${LAST_RELEASE}.el${EL_MAJOR}.x86_64.rpm")
        INSTALL_CMDS=("dnf install -y /tmp/${PACKAGES[0]}")
    else
        # Estraiamo il numero puro (es. 42) per il percorso della cartella
        FEDORA_VER="${FEDORA_TAG#fc}"
        # Allineato al nuovo albero RPM
        FOLDER="rpm/fedora/${FEDORA_VER}/x86_64"
        PACKAGES=("penguins-eggs-legacy-${LAST_VERSION}-${LAST_RELEASE}.${FEDORA_TAG}.x86_64.rpm")
        INSTALL_CMDS=("dnf install -y /tmp/${PACKAGES[0]}")
    fi
}

function prepare_manjaro {
    FOLDER="manjaro"
    PACKAGES=("penguins-eggs-legacy-${LAST_VERSION}-${LAST_RELEASE}-any.pkg.tar.zst")
    INSTALL_CMDS=("pacman -U --noconfirm /tmp/${PACKAGES[0]}")
}

function prepare_openmamba {
    FOLDER="openmamba"
    PACKAGES=("penguins-eggs-legacy-${LAST_VERSION}-${LAST_RELEASE}mamba.x86_64.rpm")
    INSTALL_CMDS=("dnf install  /tmp/${PACKAGES[0]}")
}

function prepare_opensuse {
    # Allineato al nuovo albero RPM
    FOLDER="rpm/opensuse/leap/x86_64"
    # Corretto il nome del pacchetto (rimosso .opensuse. che non è presente nel file reale)
    PACKAGES=("penguins-eggs-legacy-${LAST_VERSION}-${LAST_RELEASE}.x86_64.rpm")
    INSTALL_CMDS=("zypper --non-interactive install --allow-unsigned-rpm /tmp/${PACKAGES[0]}")
}
