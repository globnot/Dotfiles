#!/bin/bash
# Installe les règles udev suivies dans Dotfiles (voir udev-rules/) et
# recharge udev pour les appliquer sans reboot. Nécessite root (écrit
# dans /etc/udev/rules.d/).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$SCRIPT_DIR/../udev-rules"

cp "$SRC_DIR"/*.rules /etc/udev/rules.d/
udevadm control --reload-rules
udevadm trigger --subsystem-match=usb

echo "Règles udev installées et rechargées."
