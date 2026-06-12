#!/bin/bash
# Dry-run dell'upload su SourceForge: nessun file viene trasferito.
# Verifica autenticazione e percorsi prima di lanciare ./refresh.sh sourceforge
# Usa la stessa autenticazione di refresh.sh: la password in ../.sf-passwd.txt
# se presente (via sshpass), altrimenti la chiave ssh.

SF_USER="pproietti"
SF_DEST="/home/frs/project/penguins-eggs/Packages"
SF_PASSWD_FILE="$(dirname "$0")/../.sf-passwd.txt"

RSH="ssh -o StrictHostKeyChecking=accept-new"
if [ -f "${SF_PASSWD_FILE}" ]; then
    if ! command -v sshpass >/dev/null 2>&1; then
        echo "ERRORE: trovato ${SF_PASSWD_FILE} ma sshpass non è installato" >&2
        exit 1
    fi
    RSH="sshpass -f ${SF_PASSWD_FILE} ${RSH}"
fi

rsync -avn -e "${RSH}" /eggs/ "${SF_USER}@frs.sourceforge.net:${SF_DEST}/"
