#!/bin/bash -e
source /etc/os-release

FOUND=0
case $ID in 
    almalinux)
        FOUND=1
        ;;
    fedora)
        FOUND=1
        ;;
    nobara)
        FOUND=1
        ;;
    opensuse)
        FOUND=1
        ;;
    rocky)
        FOUND=1
        ;;
esac

VERSION="10.1.1-10"
DOWNLOAD_PAGE="https://sourceforge.net/projects/penguins-eggs/files/Packages/tarballs/"

clear
if [[ $FOUND == 1 ]]; then
    echo ">> fresh-eggs: OK, is $ID, penguins-eggs-legacy can be installed"
    echo ""
    echo "First: if SELINUX is enbled, disable it, and reboot;"
    echo ""
    echo "- edit /etc/selinux/conf, add the  line SELINUX=disabled at the end"
    echo "- reboot"
    echo ""
    echo "Install requirements:"
    echo "sudo tarballs/requirements/$ID/install.sh"
    echo ""
    echo "Download penguins-eggs-legacy_$VERSION-linux-x64.tar.gz from "
    echo ""
    echo "Install penguins-eggs-legacy:"
    echo "tarballs/setup ~/Downloads/penguins-eggs-legacy_$VERSION-linux-x64.tar.gz from $DOWNLOAD_PAGE"
    echo ""
    echo "enjoy it!"
else
    echo ">> fresh-eggs: is $ID, penguins-eggs-legacy install the package"
fi
