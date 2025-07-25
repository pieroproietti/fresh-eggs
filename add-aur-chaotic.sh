function main {
    is_arch
    is_aur

    echo ""
    echo ">> get-eggs: add spare tools..."
    echo ""
    pacman -S  bash-completion \
                dialog \
                man-db \
                nano \
                openssh \
                wget

    echo ""
    echo ">> get-eggs: add AUR repository..."
    echo ""
    echo 
    pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
    pacman-key --lsign-key 3056513887B78AEB
    pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
    echo "[chaotic-aur]" >> /etc/pacman.conf
    echo "Include = /etc/pacman.d/chaotic-mirrorlist" >> /etc/pacman.conf

    echo ""
    echo ">> get-eggs: Installing penguins-eggs..."
    echo ""
    pacman -Sy penguins-eggs

    echo ""
    read -rp ">> get-eggs: press a key to edit /etc/sudoers"
    echo ""
    export EDITOR=nano
    visudo

    eggs dad -d

    echo ">> get-eggs: finished! You can remove it"
}

main
