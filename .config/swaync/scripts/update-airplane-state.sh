#!/bin/bash
# Réécrit airplane-state.css selon l'état réel du wifi (bouton 4 du buttons-grid).
source "$(dirname "${BASH_SOURCE[0]}")/state-css.sh"

n=0
rfkill list wifi 2>/dev/null | grep -q "Soft blocked: yes" && n=4
write_state_css "airplane" "$n"
