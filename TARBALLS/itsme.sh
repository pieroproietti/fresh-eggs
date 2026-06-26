#!/bin/bash
if [ -z "$1" ]; then
    REQUIREMENTS=""
else
    REQUIREMENTS="--requirements"
fi

rm -f penguins-eggs-legacy-tarball*
scp artisan@192.168.1.2:/eggs/tarballs/penguins-eggs-legacy-tarball* .
./setup ./penguins-eggs-legacy-tarball* $REQUIREMENTS
# 
rm -f penguins-eggs-legacy-tarball*
