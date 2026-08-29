#!/bin/bash
# Bibliothèque commune aux scripts update-*-state.sh : ils réécrivent un CSS
# pour surligner le bouton actif du buttons-grid, car le mécanisme "active"
# natif de swaync ne fonctionne pas de façon fiable (voir issue amont
# ErikReider/SwayNotificationCenter#739).
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "$REPO_DIR/theme/palette.sh"

# write_state_css <name> <n> : écrit ~/.config/swaync/<name>-state.css.
# <n> est l'index (1-based) du flowboxchild à surligner, ou 0 pour aucun.
write_state_css() {
    local name="$1" n="$2"
    local css_file="$HOME/.config/swaync/${name}-state.css"
    {
        printf '/* Auto-généré par update-%s-state.sh, ne pas éditer à la main */\n' "$name"
        if [ "$n" -gt 0 ]; then
            cat <<EOF
.widget-buttons-grid flowboxchild:nth-child($n) > button {
  background-color: #$ACCENT;
  color: #$BG0;
}
EOF
        fi
    } > "$css_file"
    swaync-client -rs >/dev/null 2>&1 || true
}
