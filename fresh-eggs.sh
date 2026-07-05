#!/bin/bash

# ==============================================================================
# UNIVERSAL INSTALLER FOR PENGUINS-EGGS (Standard Version)
# - Scarica direttamente da https://penguins-eggs.net/basket/packages/
# - Rileva automaticamente Distro e Architettura
# - Individua l'ultima release parsando la directory web (salta le legacy)
# ==============================================================================

URL_BASE="https://penguins-eggs.net/basket/packages"

function title {
    clear
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
INSTALL_CMD=""
PATTERN=""

# Mappatura della distribuzione verso la cartella sul server e il comando di installazione
# Il pattern cerca esplicitamente un numero dopo "penguins-eggs-" o "penguins-eggs_",
# escludendo così in modo naturale i pacchetti "penguins-eggs-legacy".

case "$ID" in
    debian | devuan | ubuntu | linuxmint | pop)
        FOLDER="debs"
        PATTERN="penguins-eggs_[0-9][a-zA-Z0-9.-]*_${DEB_ARCH}\.deb"
        INSTALL_CMD="apt-get install -y"
        ;;
    fedora)
        FOLDER="fedora"
        PATTERN="penguins-eggs-[0-9][a-zA-Z0-9.-]*\.rpm"
        INSTALL_CMD="dnf install -y"
        ;;
    almalinux | rocky | centos | rhel)
        FOLDER="el9"
        PATTERN="penguins-eggs-[0-9][a-zA-Z0-9.-]*\.rpm"
        INSTALL_CMD="dnf install -y"
        ;;
    sles | opensuse-tumbleweed | opensuse-slowroll | opensuse-leap)
        FOLDER="opensuse"
        PATTERN="penguins-eggs-[0-9][a-zA-Z0-9.-]*\.rpm"
        INSTALL_CMD="zypper install -y --allow-unsigned-rpm"
        ;;
    arch | cachyos | endeavouros)
        FOLDER="aur"
        PATTERN="penguins-eggs-[0-9][a-zA-Z0-9.-]*\.pkg\.tar\.zst"
        INSTALL_CMD="pacman -U --noconfirm"
        ;;
    manjaro | biglinux)
        FOLDER="manjaro"
        PATTERN="penguins-eggs-[0-9][a-zA-Z0-9.-]*\.pkg\.tar\.zst"
        INSTALL_CMD="pacman -U --noconfirm"
        ;;
    alpine)
        FOLDER="alpine"
        PATTERN="penguins-eggs-[0-9][a-zA-Z0-9.-]*\.apk"
        INSTALL_CMD="apk add --allow-untrusted"
        ;;
    *)
        # Fallback tramite ID_LIKE
        case "$ID_LIKE" in
            *debian*)
                FOLDER="debs"
                PATTERN="penguins-eggs_[0-9][a-zA-Z0-9.-]*_${DEB_ARCH}\.deb"
                INSTALL_CMD="apt-get install -y"
                ;;
            *fedora*|*rhel*|*centos*)
                FOLDER="el9" # Default prudenziale
                PATTERN="penguins-eggs-[0-9][a-zA-Z0-9.-]*\.rpm"
                INSTALL_CMD="dnf install -y"
                ;;
            *arch*)
                FOLDER="aur"
                PATTERN="penguins-eggs-[0-9][a-zA-Z0-9.-]*\.pkg\.tar\.zst"
                INSTALL_CMD="pacman -U --noconfirm"
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
LATEST_PKG=$(curl -sL "$FETCH_URL" | grep -oE "$PATTERN" | sort -u | sort -V | tail -n 1)

if [ -z "$LATEST_PKG" ]; then
    echo "❌ Errore: Nessun pacchetto compatibile trovato per $PRETTY_NAME ($ARCH)."
    exit 1
fi

DOWNLOAD_URL="${FETCH_URL}${LATEST_PKG}"
LOCAL_FILE="/tmp/${LATEST_PKG}"

echo "✅ Trovato: $LATEST_PKG"
echo "⬇️  Download in corso..."

curl --fail -L -o "$LOCAL_FILE" "$DOWNLOAD_URL"

if [ $? -ne 0 ]; then
    echo "❌ Errore durante il download del file." >&2
    exit 1
fi

echo "✅ Download completato: $LOCAL_FILE"
echo ""

# ==============================================================================
# --- Installazione ---
# ==============================================================================

FULL_CMD="$INSTALL_CMD $LOCAL_FILE"

echo "🚀 Eseguo l'installazione: $FULL_CMD"
echo "----------------------------------------------------------"

if ! eval "$FULL_CMD"; then
    echo "----------------------------------------------------------"
    echo "❌ Errore: L'installazione è fallita." >&2
    exit 1
fi

echo "----------------------------------------------------------"
echo "🎉 Installazione di penguins-eggs completata con successo!"
rm -f "$LOCAL_FILE"
