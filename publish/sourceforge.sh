#!/bin/bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../penguins-gui/stage-gui-appimage.sh" || exit 1
source "${SCRIPT_DIR}/common.sh" || exit 1

# --- CONFIGURATION ---
SF_USER="pproietti"
SF_HOST="frs.sourceforge.net"
SF_BASE_DIR="/home/frs/project/penguins-eggs/Packages"

# Create the temporary staging area
STAGE_BASE="/tmp/sf_stage_$$"
mkdir -p "$STAGE_BASE" || exit 1
trap 'rm -rf "$STAGE_BASE"' EXIT

# Complete the download before modifying destinations.
if ! stage_gui_appimage "${STAGE_BASE}/appimage"; then
    echo "❌ Failed to download penguins-gui AppImages. Exiting without syncing." >&2
    exit 1
fi
REPOS["${STAGE_BASE}/appimage"]="appimage"

# --- MASTER SSH CONNECTION ---
SOCKET="/tmp/sf_ssh_socket_$$"

echo "🔑 Opening the connection to SourceForge."
echo "Enter your password NOW (it will be used for all uploads)..."
ssh -M -S "$SOCKET" -fN "${SF_USER}@${SF_HOST}"

if [ $? -ne 0 ]; then
    echo "❌ Failed to connect to SourceForge. Exiting."
    exit 1
fi
echo "✅ Connection established."

# --- REPOSITORY LOOP ---
for SRC_DIR in "${!REPOS[@]}"; do
    DEST_SUBDIR="${REPOS[$SRC_DIR]}"
    
    if [ ! -d "$SRC_DIR" ]; then
        echo "⚠️  Skipped: $SRC_DIR (does not exist locally)"
        continue
    fi

    echo "---------------------------------------------------"
    echo "Inspecting source: $SRC_DIR"
    
    # Prepare the empty directory for mirroring
    STAGE_DIR="${STAGE_BASE}/${DEST_SUBDIR}"
    mkdir -p "$STAGE_DIR"

    stage_packages "$SRC_DIR" "$STAGE_DIR" "$DEST_SUBDIR"

    # Safety check: skip syncing if staging is empty to avoid accidentally deleting files on SourceForge
    if [ -z "$(ls -A "$STAGE_DIR")" ]; then
        echo "⚠️  No packages found to upload for $DEST_SUBDIR. Skipping sync."
        continue
    fi

    # --- MIRROR USING RSYNC --DELETE ---
    echo "🚀 Syncing with SourceForge (uploading new files, deleting old files)..."
    rsync -avP --delete -e "ssh -S $SOCKET" "${STAGE_DIR}/" "${SF_USER}@${SF_HOST}:${SF_BASE_DIR}/${DEST_SUBDIR}/"

done

echo "---------------------------------------------------"
echo "🧹 Cleaning up the temporary staging area..."

echo "Closing the master connection..."
ssh -S "$SOCKET" -O exit "${SF_USER}@${SF_HOST}" 2>/dev/null
echo "✅ SourceForge mirror fully synchronized."
