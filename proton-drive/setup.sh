#!/bin/bash
# Installe le service/timer systemd --user suivis dans Dotfiles (voir
# sync.sh) et active le timer. Pas besoin de root : tout tourne dans la
# session utilisateur (c'est là que vit la session Proton Drive stockée
# via libsecret).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST_DIR="$HOME/.config/systemd/user"

mkdir -p "$DEST_DIR"
cp "$SCRIPT_DIR/proton-drive-sync.service" "$DEST_DIR/proton-drive-sync.service"
cp "$SCRIPT_DIR/proton-drive-sync.timer" "$DEST_DIR/proton-drive-sync.timer"

systemctl --user daemon-reload
systemctl --user enable --now proton-drive-sync.timer

echo "Timer proton-drive-sync activé (push horaire)."
