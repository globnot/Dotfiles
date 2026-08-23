#!/bin/bash
# Bascule le mode avion on/off (bouton du buttons-grid swaync). Voir
# toggle-bluetooth.sh pour le pourquoi (bug de parsing swaync sur les
# guillemets doubles imbriqués dans une commande inline).
if rfkill list wifi | grep -q "Soft blocked: yes"; then
    rfkill unblock all
else
    rfkill block all
fi
"$HOME/.config/swaync/scripts/update-airplane-state.sh"
