#!/bin/bash

# ==============================================================================
# Script di installazione per penguins-eggs
# - Rileva la distribuzione
# - Definisce i pacchetti da scaricare e i comandi da eseguire
# - Esegue il download e l'installazione in un unico flusso
# ==============================================================================

# --- Variabili Globali ---
LAST_RELEASE="25.11.21"
URL_BASE="https://penguins-eggs.net/basket/packages"

source ./ensure-node20.sh
source ./prepare_pkgs.sh

function title {
    clear
    echo "====================================="
    echo "UNIVERSAL INSTALLER FOR penguins-eggs" 
    echo "====================================="
    echo ""
}

function press_a_key_to_continue {
    echo ""
    echo ""
    read -rp ">> Press enter to continue or CTRL-C to abort."
    title
}


# --- Controllo utente Root ---
title
if [[ "$EUID" -ne 0 ]]; then
    echo ">> This script must be run as root. Please use sudo or log in as root and try again." >&2
    exit 1
fi

# --- Logica di Rilevamento Distribuzione ---
if [ -f /etc/os-release ]; then
    source /etc/os-release
else
    echo "Error: /etc/os-release not found. Cannot determine the distribution." >&2
    exit 1
fi

echo "Distro detected: $PRETTY_NAME"
echo ""

FOLDER=""
PACKAGES=()      # Array per i pacchetti da scaricare
INSTALL_CMDS=()  # Array per i comandi da eseguire in sequenza

case "$ID" in
    # NOT SUPPORTED
    garuda)
        not_supported
        ;;

    # SUPPORTED
    alpine)
        prepare_alpine
        ;;

    arch)
        prepare_aur
        ;;

    debian | devuan| ubuntu)
        ensure_node18
        title
        echo "Distro detected: $PRETTY_NAME"
        echo ""
        prepare_debs
        ;;

    fedora)
        prepare_fedora_or_el9
        ;;

    manjaro | biglinux)
        prepare_manjaro
        ;;

    openmamba)
        prepare_openmamba
        ;;

    sles | opensuse-tumbleweed | opensuse-slowroll | opensuse-leap)
        prepare_opensuse
        ;;
    
    *)
        # Logica di fallback per i derivati basata su ID_LIKE
        case "$ID_LIKE" in
            *arch*)
                prepare_aur
                ;;

            *debian*)
                ensure_node18
                title
                echo "Distro detected: $PRETTY_NAME"
                echo ""
                prepare_debs
                ;;

            *fedora*)
                prepare_fedora_or_el9
                ;;
            # Aggiungere altri fallback se necessario
            *)
                echo "Your distribution ($PRETTY_NAME) is not currently supported." >&2
                exit 1
                ;;
        esac
        ;;
esac

# Controlla se sono stati trovati pacchetti/comandi
if [ ${#PACKAGES[@]} -eq 0 ]; then
    echo "Configuration for your distribution ($PRETTY_NAME) could not be determined." >&2
    exit 1
fi


# ==============================================================================
# --- Esecuzione ---
# ==============================================================================

# 1. Download dei Pacchetti
echo "From ${URL_BASE}/${FOLDER}/ will download:"
for pkg in "${PACKAGES[@]}"; do
    echo "  - ${pkg}"
done
press_a_key_to_continue

for pkg in "${PACKAGES[@]}"; do
    echo ">> Downloading ${pkg}..."
    local_file="/tmp/${pkg}"
    rm -f $local_file
    remote_url="${URL_BASE}/${FOLDER}/${pkg}"

    if command -v curl >/dev/null 2>&1; then
        curl --fail -L -o "$local_file" "$remote_url"
    elif command -v wget >/dev/null 2>&1; then
        wget -q -O "$local_file" "$remote_url"
    else
        echo "Error: Neither curl nor wget is available to download files." >&2
        exit 1
    fi
    
    if [ $? -ne 0 ]; then
        echo "Error: Failed to download ${pkg}." >&2
        exit 1
    fi
done

echo "All packages downloaded successfully."
echo ""

# 2. Esecuzione dei Comandi di Installazione
echo "The following commands will be executed for installation:"
for cmd in "${INSTALL_CMDS[@]}"; do
    echo "  - ${cmd}"
done
press_a_key_to_continue

for cmd in "${INSTALL_CMDS[@]}"; do
    echo ">> Running: $cmd"
    if ! eval "$cmd"; then
        echo "Error: Command failed to execute successfully: '$cmd'" >&2
        echo "Aborting installation." >&2
        exit 1
    fi
done

echo "Installation completed successfully!"
