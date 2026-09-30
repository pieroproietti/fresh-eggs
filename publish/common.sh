#!/bin/bash

declare -A REPOS
REPOS["/var/www/html/repos/alpine/x86_64/"]="alpine"
REPOS["/var/www/html/repos/arch/"]="aur"
REPOS["/var/www/html/repos/deb/pool/main/"]="debs"
REPOS["/var/www/html/repos/manjaro/"]="manjaro"
REPOS["/var/www/html/repos/rpm/el9/x86_64/"]="el9"
REPOS["/var/www/html/repos/rpm/fedora/42/x86_64/"]="fedora"
REPOS["/var/www/html/repos/rpm/opensuse/leap/x86_64/"]="opensuse"

stage_latest() {
    local src_dir=$1
    local stage_dir=$2
    local pattern=$3

    # Troviamo l'ultimo file (head -n 1 prende il più recente)
    local latest=$(ls -t "${src_dir}"/${pattern} 2>/dev/null | head -n 1)

    if [ -n "$latest" ] && [ -f "$latest" ]; then
        cp -a "$latest" "$stage_dir/"
        echo "    ✅ Selezionato: $(basename "$latest")"
    fi
}

stage_packages() {
    local src_dir=$1 stage_dir=$2 destination=$3
    local package arch suffix
    case "$destination" in
        appimage) return 0 ;; # Already downloaded into staging.
        debs)
            for arch in amd64 arm64 riscv64 i386; do
                for package in penguins-eggs penguins-eggs-legacy penguins-gui; do
                    stage_latest "$src_dir" "$stage_dir" "${package}_[0-9]*_${arch}.deb"
                done
            done
            return 0
            ;;
        fedora|el9|opensuse) suffix=rpm ;;
        aur|manjaro) suffix=pkg.tar.zst ;;
        alpine) suffix=apk ;;
        *) return 1 ;;
    esac
    for package in penguins-eggs penguins-eggs-legacy penguins-gui; do
        stage_latest "$src_dir" "$stage_dir" "${package}-[0-9]*.${suffix}"
    done
}
