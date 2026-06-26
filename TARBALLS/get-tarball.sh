#!/bin/bash
if [ -z "$1" ]; then
    VERSION="10.1.1"
else
    VERSION="$1"
fi
VERSIONS=$1

VERSION="10.1.1-10"
TAR_NAME="penguins-eggs-legacy_$VERSION-linux-x64.tar.gz"
DOWNLOAD_PAGE="https://sourceforge.net/projects/penguins-eggs/files/Packages/tarballs/"
wget -q  -O "$TAR_NAME" "${DOWNLOAD_PAGE}/$TAR_NAME/download"


