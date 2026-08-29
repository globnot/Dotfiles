#!/bin/bash
# Réécrit bluetooth-state.css selon l'état réel du bluetooth (bouton 5 du buttons-grid).
source "$(dirname "${BASH_SOURCE[0]}")/state-css.sh"

n=0
bluetoothctl show 2>/dev/null | grep -q "Powered: yes" && n=5
write_state_css "bluetooth" "$n"
