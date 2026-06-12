#!/bin/bash
# Dry-run dell'upload su SourceForge: nessun file viene trasferito.
# Verifica chiave ssh e percorsi prima di lanciare ./refresh.sh sourceforge
rsync -avn -e "ssh -o StrictHostKeyChecking=accept-new" \
    /eggs/ pproietti@frs.sourceforge.net:/home/frs/project/penguins-eggs/Packages/
