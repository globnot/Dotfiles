#!/bin/bash
# Installe le thème SDDM "gruvbrutal" (écrit à la main, neobrutalism sur base
# Gruvbox Light + fuchsia, voir ../sddm-theme/gruvbrutal/) et le sélectionne
# comme thème actif. Nécessite root (écrit dans /usr/share et /etc).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$SCRIPT_DIR/../sddm-theme/gruvbrutal"
THEME_DIR="/usr/share/sddm/themes/gruvbrutal"

mkdir -p "$THEME_DIR"
cp "$SRC_DIR/Main.qml" "$THEME_DIR/Main.qml"
cp "$SRC_DIR/metadata.desktop" "$THEME_DIR/metadata.desktop"

mkdir -p /etc/sddm.conf.d
cat > /etc/sddm.conf.d/theme.conf <<'EOF'
[Theme]
Current=gruvbrutal
EOF

echo "Thème SDDM 'gruvbrutal' installé et sélectionné. Teste avec: sddm-greeter-qt6 --test-mode --theme $THEME_DIR (si dispo), ou au prochain verrouillage/redémarrage."
