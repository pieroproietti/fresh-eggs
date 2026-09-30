#!/bin/bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../penguins-gui/stage-gui-appimage.sh" || exit 1
source "${SCRIPT_DIR}/common.sh" || exit 1

# --- CONFIGURATION ---
DEST_BASE_DIR="/home/artisan/basket/packages"

# Create the temporary staging area
STAGE_BASE="/tmp/local_stage_$$"
mkdir -p "$STAGE_BASE" || exit 1
trap 'rm -rf "$STAGE_BASE"' EXIT

# Complete the download before modifying destinations.
if ! stage_gui_appimage "${STAGE_BASE}/appimage"; then
    echo "❌ Failed to download penguins-gui AppImages. Exiting without syncing." >&2
    exit 1
fi
REPOS["${STAGE_BASE}/appimage"]="appimage"

# Ensure the final destination directory exists
mkdir -p "$DEST_BASE_DIR"

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

    # Safety check: skip syncing if staging is empty
    if [ -z "$(ls -A "$STAGE_DIR")" ]; then
        echo "⚠️  No packages found to upload for $DEST_SUBDIR. Skipping sync."
        continue
    fi

    # Create the final destination subdirectory if it does not exist
    mkdir -p "${DEST_BASE_DIR}/${DEST_SUBDIR}"

    # --- MIRROR USING RSYNC --DELETE ---
    echo "🚀 Syncing locally (copying new files, deleting old files)..."
    rsync -avP --delete "${STAGE_DIR}/" "${DEST_BASE_DIR}/${DEST_SUBDIR}/"

done

echo "---------------------------------------------------"
echo "🧹 Cleaning up the temporary staging area..."

echo "✅ Local mirror fully synchronized at ${DEST_BASE_DIR}."
