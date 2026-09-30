#!/bin/bash

# ==============================================================================
# UNIVERSAL INSTALLER FOR PENGUINS-EGGS (Standard Version)
# - Scarica direttamente da https://penguins-eggs.net/basket/packages/
# - Rileva automaticamente Distro e Architettura
# - Individua l'ultima release parsando la directory web (salta le legacy)
# ==============================================================================

set -euo pipefail

URL_BASE="https://penguins-eggs.net/basket/packages"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

usage() {
    echo "Uso: $0 [--gui | --help]"
    echo "  senza opzioni: installa penguins-eggs (Go), richiede root e curl"
    echo "  --gui: scarica penguins-gui.AppImage nella directory corrente"
    echo "         richiede curl e python3; avviala come utente normale"
}

case "${1:-}" in
    --help|-h) usage; exit 0 ;;
    --gui)
        [[ $# -eq 1 ]] || { usage >&2; exit 1; }
        for dependency in curl python3; do
            command -v "$dependency" >/dev/null 2>&1 || {
                echo "Errore: installa $dependency e riprova." >&2
                exit 1
            }
        done
        source "${SCRIPT_DIR}/stage-gui-appimage.sh"
        STAGE_DIR=$(mktemp -d)
        trap 'rm -rf "$STAGE_DIR"' EXIT
        stage_gui_appimage "$STAGE_DIR" "$(uname -m)" || exit 1
        APPIMAGES=("$STAGE_DIR"/*.AppImage)
        [[ ${#APPIMAGES[@]} -eq 1 && -f "${APPIMAGES[0]}" ]] || {
            echo "Errore: la release deve contenere una sola AppImage compatibile." >&2
            exit 1
        }
        mv -- "${APPIMAGES[0]}" ./penguins-gui.AppImage
        echo "Avvia: ./penguins-gui.AppImage (senza sudo)."
        echo "Poi scegli Edit → Install penguins-egg CLI per installare Eggs."
        echo "Se FUSE non è disponibile: APPIMAGE_EXTRACT_AND_RUN=1 ./penguins-gui.AppImage"
        exit 0
        ;;
    "") [[ $# -eq 0 ]] || { usage >&2; exit 1; } ;;
    *) usage >&2; exit 1 ;;
esac

function title {
    if [[ -t 1 && -n "${TERM:-}" ]]; then clear || true; fi
    echo "=========================================================="
    echo " UNIVERSAL INSTALLER FOR PENGUINS-EGGS"
    echo "=========================================================="
    echo ""
}

# --- Controllo root ---
if [[ "$EUID" -ne 0 ]]; then
    echo "❌ Errore: Questo script deve essere eseguito come root (usa sudo)." >&2
    exit 1
fi

# --- Dipendenze essenziali ---
if ! command -v curl >/dev/null 2>&1; then
    echo "❌ Errore: 'curl' è necessario per esplorare la repository. Installalo e riprova." >&2
    exit 1
fi

# --- Rilevamento Architettura ---
ARCH=$(uname -m)
case $ARCH in
    x86_64)  DEB_ARCH="amd64" ;;
    aarch64) DEB_ARCH="arm64" ;;
    riscv64) DEB_ARCH="riscv64" ;;
    i386|i686) DEB_ARCH="i386" ;;
    *)       DEB_ARCH="$ARCH" ;;
esac

# --- Rilevamento Distribuzione ---
if [ -f /etc/os-release ]; then
    source /etc/os-release
else
    echo "❌ Errore: /etc/os-release non trovato. Impossibile determinare la distribuzione." >&2
    exit 1
fi

title
echo "Distro rilevata: $PRETTY_NAME"
echo "Architettura: $ARCH (Debian-style: $DEB_ARCH)"
echo ""

FOLDER=""
INSTALL_CMD=()
PATTERN=""

# Mappatura della distribuzione verso la cartella sul server e il comando di installazione
# Il pattern cerca esplicitamente un numero dopo "penguins-eggs-" o "penguins-eggs_",
# escludendo così in modo naturale i pacchetti "penguins-eggs-legacy".

case "$ID" in
    debian | devuan | ubuntu | linuxmint | pop)
        FOLDER="debs"
        PATTERN="penguins-eggs_[0-9][a-zA-Z0-9.-]*_${DEB_ARCH}\.deb"
        INSTALL_CMD=(apt-get install -y)
        ;;
    fedora)
        FOLDER="fedora"
        PATTERN="penguins-eggs-[0-9][a-zA-Z0-9.-]*\.rpm"
        INSTALL_CMD=(dnf install -y)
        ;;
    almalinux | rocky | centos | rhel)
        FOLDER="el9"
        PATTERN="penguins-eggs-[0-9][a-zA-Z0-9.-]*\.rpm"
        INSTALL_CMD=(dnf install -y)
        ;;
    sles | opensuse-tumbleweed | opensuse-slowroll | opensuse-leap)
        FOLDER="opensuse"
        PATTERN="penguins-eggs-[0-9][a-zA-Z0-9.-]*\.rpm"
        INSTALL_CMD=(zypper install -y --allow-unsigned-rpm)
        ;;
    arch | cachyos | endeavouros)
        FOLDER="aur"
        PATTERN="penguins-eggs-[0-9][a-zA-Z0-9.-]*\.pkg\.tar\.zst"
        INSTALL_CMD=(pacman -U --noconfirm)
        ;;
    manjaro | biglinux)
        FOLDER="manjaro"
        PATTERN="penguins-eggs-[0-9][a-zA-Z0-9.-]*\.pkg\.tar\.zst"
        INSTALL_CMD=(pacman -U --noconfirm)
        ;;
    alpine)
        FOLDER="alpine"
        PATTERN="penguins-eggs-[0-9][a-zA-Z0-9.-]*\.apk"
        INSTALL_CMD=(apk add --allow-untrusted)
        ;;
    *)
        # Fallback tramite ID_LIKE
        case "${ID_LIKE:-}" in
            *debian*)
                FOLDER="debs"
                PATTERN="penguins-eggs_[0-9][a-zA-Z0-9.-]*_${DEB_ARCH}\.deb"
                INSTALL_CMD=(apt-get install -y)
                ;;
            *fedora*|*rhel*|*centos*)
                FOLDER="el9" # Default prudenziale
                PATTERN="penguins-eggs-[0-9][a-zA-Z0-9.-]*\.rpm"
                INSTALL_CMD=(dnf install -y)
                ;;
            *arch*)
                FOLDER="aur"
                PATTERN="penguins-eggs-[0-9][a-zA-Z0-9.-]*\.pkg\.tar\.zst"
                INSTALL_CMD=(pacman -U --noconfirm)
                ;;
            *)
                echo "❌ Distribuzione non supportata: $PRETTY_NAME" >&2
                exit 1
                ;;
        esac
        ;;
esac

# ==============================================================================
# --- Ricerca e Download ---
# ==============================================================================

FETCH_URL="${URL_BASE}/${FOLDER}/"
echo "🔍 Cerco l'ultima versione in: $FETCH_URL"

# Legge la pagina web, estrae i link corrispondenti al pattern, 
# li ordina per versione (sort -V) e prende l'ultimo (tail -n 1)
INDEX=$(curl --fail --silent --show-error --location "$FETCH_URL")
LATEST_PKG=$(printf '%s\n' "$INDEX" | grep -oE "$PATTERN" | sort -u | sort -V | tail -n 1 || true)

if [ -z "$LATEST_PKG" ]; then
    echo "❌ Errore: Nessun pacchetto compatibile trovato per $PRETTY_NAME ($ARCH)."
    exit 1
fi

DOWNLOAD_URL="${FETCH_URL}${LATEST_PKG}"
DOWNLOAD_DIR=$(mktemp -d)
trap 'rm -rf "$DOWNLOAD_DIR"' EXIT
LOCAL_FILE="${DOWNLOAD_DIR}/${LATEST_PKG}"

echo "✅ Trovato: $LATEST_PKG"
echo "⬇️  Download in corso..."

if ! curl --fail -L -o "$LOCAL_FILE" "$DOWNLOAD_URL"; then
    echo "❌ Errore durante il download del file." >&2
    exit 1
fi

echo "✅ Download completato: $LOCAL_FILE"
echo ""

# ==============================================================================
# --- Installazione ---
# ==============================================================================

printf "🚀 Eseguo l'installazione: "
printf '%q ' "${INSTALL_CMD[@]}" "$LOCAL_FILE"
printf '\n'
echo "----------------------------------------------------------"

if ! "${INSTALL_CMD[@]}" "$LOCAL_FILE"; then
    echo "----------------------------------------------------------"
    echo "❌ Errore: L'installazione è fallita." >&2
    exit 1
fi

echo "----------------------------------------------------------"
echo "🎉 Installazione di penguins-eggs completata con successo!"
