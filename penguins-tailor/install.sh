#!/bin/bash
set -euo pipefail
URL_BASE="https://penguins-eggs.net/basket/packages"
if [[ $# -ne 0 ]]; then
    echo "Usage: sudo $0" >&2
    exit 1
fi

function title {
    if [[ -t 1 && -n "${TERM:-}" ]]; then clear || true; fi
    echo "=========================================================="
    echo " UNIVERSAL INSTALLER FOR PENGUINS-TAILOR"
    echo "=========================================================="
    echo ""
}

# --- Root check ---
if [[ "$EUID" -ne 0 ]]; then
    echo "❌ Error: This script must be run as root (use sudo)." >&2
    exit 1
fi

# --- Required dependencies ---
if ! command -v curl >/dev/null 2>&1; then
    echo "❌ Error: 'curl' is required to browse the repository. Install it and try again." >&2
    exit 1
fi

# --- Architecture detection ---
ARCH=$(uname -m)
case $ARCH in
    x86_64)  DEB_ARCH="amd64" ;;
    aarch64) DEB_ARCH="arm64" ;;
    riscv64) DEB_ARCH="riscv64" ;;
    i386|i686) DEB_ARCH="i386" ;;
    *)       DEB_ARCH="$ARCH" ;;
esac

# --- Distribution detection ---
if [ -f /etc/os-release ]; then
    source /etc/os-release
else
    echo "❌ Error: /etc/os-release not found. Cannot determine the distribution." >&2
    exit 1
fi

title
echo "Detected distribution: $PRETTY_NAME"
echo "Architecture: $ARCH (Debian-style: $DEB_ARCH)"
echo ""

FOLDER=""
INSTALL_CMD=()
PATTERN=""

# Map the distribution to its server directory and installation command

case "$ID" in
    debian | devuan | ubuntu | linuxmint | pop)
        FOLDER="debs"
        PATTERN="penguins-tailor_[0-9][a-zA-Z0-9.-]*_${DEB_ARCH}\.deb"
        INSTALL_CMD=(apt-get install -y)
        ;;
    fedora)
        FOLDER="fedora"
        PATTERN="penguins-tailor-[0-9][a-zA-Z0-9.-]*\.rpm"
        INSTALL_CMD=(dnf install -y)
        ;;
    almalinux | rocky | centos | rhel)
        FOLDER="el9"
        PATTERN="penguins-tailor-[0-9][a-zA-Z0-9.-]*\.rpm"
        INSTALL_CMD=(dnf install -y)
        ;;
    sles | opensuse-tumbleweed | opensuse-slowroll | opensuse-leap)
        FOLDER="opensuse"
        PATTERN="penguins-tailor-[0-9][a-zA-Z0-9.-]*\.rpm"
        INSTALL_CMD=(zypper install -y --allow-unsigned-rpm)
        ;;
    arch | cachyos | endeavouros)
        FOLDER="aur"
        PATTERN="penguins-tailor-[0-9][a-zA-Z0-9.-]*\.pkg\.tar\.zst"
        INSTALL_CMD=(pacman -U --noconfirm)
        ;;
    manjaro | biglinux)
        FOLDER="manjaro"
        PATTERN="penguins-tailor-[0-9][a-zA-Z0-9.-]*\.pkg\.tar\.zst"
        INSTALL_CMD=(pacman -U --noconfirm)
        ;;
    alpine)
        FOLDER="alpine"
        PATTERN="penguins-tailor-[0-9][a-zA-Z0-9.-]*\.apk"
        INSTALL_CMD=(apk add --allow-untrusted)
        ;;
    *)
        # Fallback using ID_LIKE
        case "${ID_LIKE:-}" in
            *debian*)
                FOLDER="debs"
                PATTERN="penguins-tailor_[0-9][a-zA-Z0-9.-]*_${DEB_ARCH}\.deb"
                INSTALL_CMD=(apt-get install -y)
                ;;
            *fedora*|*rhel*|*centos*)
                FOLDER="el9" # Conservative default
                PATTERN="penguins-tailor-[0-9][a-zA-Z0-9.-]*\.rpm"
                INSTALL_CMD=(dnf install -y)
                ;;
            *arch*)
                FOLDER="aur"
                PATTERN="penguins-tailor-[0-9][a-zA-Z0-9.-]*\.pkg\.tar\.zst"
                INSTALL_CMD=(pacman -U --noconfirm)
                ;;
            *)
                echo "❌ Unsupported distribution: $PRETTY_NAME" >&2
                exit 1
                ;;
        esac
        ;;
esac

# ==============================================================================
# --- Search and download ---
# ==============================================================================

FETCH_URL="${URL_BASE}/${FOLDER}/"
echo "🔍 Looking for the latest version at: $FETCH_URL"

# Read the web page and extract links matching the pattern,
# sort them by version (sort -V) and select the last one (tail -n 1)
INDEX=$(curl --fail --silent --show-error --location "$FETCH_URL")
LATEST_PKG=$(printf '%s\n' "$INDEX" | grep -oE "$PATTERN" | sort -u | sort -V | tail -n 1 || true)

if [ -z "$LATEST_PKG" ]; then
    echo "❌ Error: No compatible package found for $PRETTY_NAME ($ARCH)."
    exit 1
fi

DOWNLOAD_URL="${FETCH_URL}${LATEST_PKG}"
DOWNLOAD_DIR=$(mktemp -d)
trap 'rm -rf "$DOWNLOAD_DIR"' EXIT
LOCAL_FILE="${DOWNLOAD_DIR}/${LATEST_PKG}"

echo "✅ Found: $LATEST_PKG"
echo "⬇️  Downloading..."

if ! curl --fail -L -o "$LOCAL_FILE" "$DOWNLOAD_URL"; then
    echo "❌ Error downloading the file." >&2
    exit 1
fi

echo "✅ Download complete: $LOCAL_FILE"
echo ""

# ==============================================================================
# --- Installation ---
# ==============================================================================

printf "🚀 Running installation: "
printf '%q ' "${INSTALL_CMD[@]}" "$LOCAL_FILE"
printf '\n'
echo "----------------------------------------------------------"

if ! "${INSTALL_CMD[@]}" "$LOCAL_FILE"; then
    echo "----------------------------------------------------------"
    echo "❌ Error: Installation failed." >&2
    exit 1
fi

echo "----------------------------------------------------------"
echo "🎉 penguins-tailor installed successfully!"
