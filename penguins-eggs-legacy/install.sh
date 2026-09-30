#!/bin/bash

# ==============================================================================
# Installation script for penguins-eggs-legacy
# - Detect the distribution
# - Define the packages to download and the commands to run
# - Download and install packages in a single workflow
# ==============================================================================

# --- Global variables ---
FEDORA_TAG="fc42"

# Updated to the new direct path
URL_BASE="https://penguins-eggs.net/repos"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/ensure-node.sh" || exit 1
source "${SCRIPT_DIR}/prepare_pkgs.sh" || exit 1

function title {
    clear
    echo "====================================="
    echo "UNIVERSAL INSTALLER FOR penguins-eggs-legacy" 
    echo "====================================="
    echo ""
}

function press_a_key_to_continue {
    echo ""
    echo ""
    read -rp ">> Press enter to continue or CTRL-C to abort."
    title
}

# --- Root user check ---
title
if [[ "$EUID" -ne 0 ]]; then
    echo ">> This script must be run as root. Please use sudo or log in as root and try again." >&2
    exit 1
fi

# --- Distribution detection logic ---
if [ -f /etc/os-release ]; then
    source /etc/os-release
else
    echo "Error: /etc/os-release not found. Cannot determine the distribution." >&2
    exit 1
fi

echo "Distro detected: $PRETTY_NAME"

FOLDER=""
PACKAGES=()      # Array of packages to download
INSTALL_CMDS=()  # Array of commands to run sequentially

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

    cachyos)
        prepare_aur
        ;;

    debian | devuan | ubuntu)
        ensure_node
        title
        echo "Distro detected: $PRETTY_NAME"
        echo ""
        prepare_debs
        ;;

    fedora)
        prepare_fedora_or_el
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
        # Fallback logic for derivatives based on ID_LIKE
        case "$ID_LIKE" in
            *arch*)
                prepare_aur
                ;;

            *debian*)
                ensure_node
                title
                echo "Distro detected: $PRETTY_NAME"
                echo ""
                prepare_debs
                ;;

            *fedora*)
                prepare_fedora_or_el
                ;;
            # Add other fallbacks if needed
            *)
                echo "Your distribution ($PRETTY_NAME) is not currently supported." >&2
                exit 1
                ;;
        esac
        ;;
esac

# Check whether packages/commands were found
if [ ${#PACKAGES[@]} -eq 0 ]; then
    echo "Configuration for your distribution ($PRETTY_NAME) could not be determined." >&2
    exit 1
fi

# ==============================================================================
# --- Execution ---
# ==============================================================================

# 1. Download packages
echo "From ${URL_BASE}/${FOLDER}/ will download:"
for pkg in "${PACKAGES[@]}"; do
    echo "  - ${pkg}"
done
press_a_key_to_continue

for pkg in "${PACKAGES[@]}"; do
    echo ">> Downloading ${pkg}..."
    local_file="/tmp/${pkg}"
    rm -f "$local_file"
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

# 2. Run installation commands
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
