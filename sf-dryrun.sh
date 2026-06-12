#!/bin/bash
# Dry-run dell'upload su SourceForge: nessun file viene trasferito.
# Verifica autenticazione e percorsi prima di lanciare ./refresh.sh sourceforge
# Da lanciare come utente normale (la chiave ssh registrata su SourceForge
# è la sua, non quella di root).

SF_USER="pproietti"
SF_DEST="/home/frs/project/penguins-eggs/Packages"

# Stesse opzioni di refresh.sh: --delete rimuove da SourceForge i pacchetti
# delle release precedenti (in dry-run li mostra come "deleting ...")
rsync -avn --delete \
    --exclude=README.md --exclude=tarballs/ \
    -e "ssh -o StrictHostKeyChecking=accept-new" \
    /eggs/ "${SF_USER}@frs.sourceforge.net:${SF_DEST}/"
