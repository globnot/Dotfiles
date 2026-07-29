#!/bin/bash
# Configure sugar-candy comme thème SDDM, en Gruvbox Light avec le wallpaper
# déjà utilisé sur le bureau. Nécessite root (écrit dans /usr/share et /etc).
set -euo pipefail

THEME_DIR="/usr/share/sddm/themes/sugar-candy"
REAL_HOME="$(getent passwd "${SUDO_USER:-$USER}" | cut -d: -f6)"

cp "$REAL_HOME/Pictures/wallpapers/gruvbox-tranquility.png" "$THEME_DIR/Backgrounds/gruvbox-tranquility.png"

sed -i \
    -e 's|^Background=.*|Background="Backgrounds/gruvbox-tranquility.png"|' \
    -e 's|^DimBackgroundImage=.*|DimBackgroundImage="0.15"|' \
    -e 's|^HaveFormBackground=.*|HaveFormBackground="true"|' \
    -e 's|^FormPosition=.*|FormPosition="center"|' \
    -e 's|^MainColor=.*|MainColor="#3c3836"|' \
    -e 's|^AccentColor=.*|AccentColor="#af3a03"|' \
    -e 's|^BackgroundColor=.*|BackgroundColor="#ebdbb2"|' \
    -e 's|^Font=.*|Font="JetBrainsMono Nerd Font Mono"|' \
    -e 's|^HeaderText=.*|HeaderText="Bienvenue !"|' \
    -e 's|^ForceHideCompletePassword=.*|ForceHideCompletePassword="true"|' \
    "$THEME_DIR/theme.conf"

mkdir -p /etc/sddm.conf.d
cat > /etc/sddm.conf.d/theme.conf <<'EOF'
[Theme]
Current=sugar-candy
EOF

echo "Thème SDDM configuré. Teste avec: sddm-greeter-qt6 --test-mode --theme $THEME_DIR (si dispo), ou au prochain verrouillage/redémarrage."
