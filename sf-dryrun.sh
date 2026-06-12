#!/bin/bash
# Dry-run dell'upload su SourceForge: nessun file viene trasferito.
# Verifica autenticazione e percorsi prima di lanciare ./refresh.sh sourceforge
# Da lanciare come utente normale (la chiave ssh registrata su SourceForge
# è la sua, non quella di root).

SF_USER="pproietti"
SF_DEST="/home/frs/project/penguins-eggs/Packages"

rsync -avn -e "ssh -o StrictHostKeyChecking=accept-new" \
    /eggs/ "${SF_USER}@frs.sourceforge.net:${SF_DEST}/"
