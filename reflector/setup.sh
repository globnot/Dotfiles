#!/bin/bash
# Installe la config reflector suivie dans Dotfiles (voir reflector.conf),
# régénère /etc/pacman.d/mirrorlist tout de suite, et active le timer
# systemd pour que ça se refasse automatiquement (évite que la liste
# repourrisse avec des miroirs morts avec le temps). Nécessite root.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cp "$SCRIPT_DIR/reflector.conf" /etc/xdg/reflector/reflector.conf
reflector @/etc/xdg/reflector/reflector.conf
systemctl enable --now reflector.timer

echo "Mirrorlist régénérée et reflector.timer activé."
