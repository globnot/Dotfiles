#!/bin/bash
# Réécrit airplane-state.css selon l'état réel du wifi (bouton 4 du buttons-grid),
# même contournement que update-bluetooth-state.sh (voir ce fichier pour le pourquoi).
CSS_FILE="$HOME/.config/swaync/airplane-state.css"

if rfkill list wifi 2>/dev/null | grep -q "Soft blocked: yes"; then
    cat > "$CSS_FILE" <<'EOF'
/* Auto-généré par update-airplane-state.sh, ne pas éditer à la main */
.widget-buttons-grid flowboxchild:nth-child(4) > button {
  background-color: #e91e8c;
  color: #fbf1c7;
}
EOF
else
    printf '/* Auto-généré par update-airplane-state.sh, ne pas éditer à la main */\n' > "$CSS_FILE"
fi

swaync-client -rs >/dev/null 2>&1 || true
