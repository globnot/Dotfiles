#!/bin/bash
# Installe la surcharge systemd suivie dans Dotfiles pour fprintd (voir
# systemd-overrides/fprintd.service.d/) et redémarre le service pour
# l'appliquer sans reboot. Nécessite root (écrit dans /etc/systemd/system/).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$SCRIPT_DIR/../systemd-overrides/fprintd.service.d/override.conf"
DEST_DIR="/etc/systemd/system/fprintd.service.d"

mkdir -p "$DEST_DIR"
cp "$SRC" "$DEST_DIR/override.conf"
systemctl daemon-reload
systemctl restart fprintd.service

echo "Surcharge fprintd installée et service redémarré."
