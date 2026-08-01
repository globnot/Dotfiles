#!/bin/bash
# Réécrit powerprofile-state.css pour surligner le bouton (1=power-saver, 2=balanced,
# 3=performance) qui correspond au profil actuellement actif. Même contournement que
# update-bluetooth-state.sh (le mécanisme "active" natif de swaync ne marche pas
# de façon fiable ici, voir issue amont ErikReider/SwayNotificationCenter#739).
CSS_FILE="$HOME/.config/swaync/powerprofile-state.css"

current=$(powerprofilesctl get 2>/dev/null)

case "$current" in
    power-saver) n=1 ;;
    balanced) n=2 ;;
    performance) n=3 ;;
    *) n=0 ;;
esac

if [ "$n" -gt 0 ]; then
    cat > "$CSS_FILE" <<EOF
/* Auto-généré par update-powerprofile-state.sh, ne pas éditer à la main */
.widget-buttons-grid flowboxchild:nth-child($n) > button {
  background-color: #e91e8c;
  color: #fbf1c7;
}
EOF
else
    printf '/* Auto-généré par update-powerprofile-state.sh, ne pas éditer à la main */\n' > "$CSS_FILE"
fi

swaync-client -rs >/dev/null 2>&1 || true
