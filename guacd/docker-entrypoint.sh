#!/bin/bash
set -e

# --- Récupérer l'adresse de bind depuis l'environnement ou fallback à 0.0.0.0 ---
GUACD_BIND_ADDRESS="${GUACD_BIND_ADDRESS:-0.0.0.0}"

# --- Démarrage final en avant-plan ---
if [ "$1" = "bash" ]; then
    exec /bin/bash
else
    echo "Starting guacd on $GUACD_BIND_ADDRESS:4822..."
    exec /usr/local/sbin/guacd -b "$GUACD_BIND_ADDRESS" -f -L info
fi