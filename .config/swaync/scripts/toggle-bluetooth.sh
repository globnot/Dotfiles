#!/bin/bash
# Bascule le bluetooth on/off (bouton du buttons-grid swaync). Sorti du
# "command" inline de config.json car swaync tronque mal les commandes
# contenant des guillemets doubles imbriqués dans un sh -c '...' (vérifié
# via journalctl --user : "-c: line 1: unexpected EOF while looking for
# matching `''"), un vrai bug de parsing chez swaync.
if bluetoothctl show | grep -q "Powered: yes"; then
    bluetoothctl power off
else
    bluetoothctl power on
fi
"$HOME/.config/swaync/scripts/update-bluetooth-state.sh"
