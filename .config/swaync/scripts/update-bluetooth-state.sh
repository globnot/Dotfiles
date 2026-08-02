#!/bin/bash
# Réécrit bluetooth-state.css selon l'état réel du bluetooth (bouton 5 du buttons-grid),
# car le mécanisme "active" natif de swaync ne fonctionne pas de façon fiable
# (voir issue amont ErikReider/SwayNotificationCenter#739).
source "$HOME/Dotfiles/theme/palette.sh"
CSS_FILE="$HOME/.config/swaync/bluetooth-state.css"

if bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
    cat > "$CSS_FILE" <<EOF
/* Auto-généré par update-bluetooth-state.sh, ne pas éditer à la main */
.widget-buttons-grid flowboxchild:nth-child(5) > button {
  background-color: #$ACCENT;
  color: #$BG0;
}
EOF
else
    printf '/* Auto-généré par update-bluetooth-state.sh, ne pas éditer à la main */\n' > "$CSS_FILE"
fi

swaync-client -rs >/dev/null 2>&1 || true
