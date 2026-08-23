#!/bin/bash
# Icône bluetooth pour le module custom/bluetooth de Waybar. Remplace le
# module natif "bluetooth" : ses format-disabled/format/format-connected
# utilisaient tous le même glyphe, donc rien ne changeait jamais
# visuellement selon l'état (même défaut que le module network avec
# ProtonVPN, voir config.jsonc).
if bluetoothctl show | grep -q "Powered: yes"; then
    devices=$(bluetoothctl devices Connected | cut -d' ' -f3-)
    if [ -n "$devices" ]; then
        printf '{"text": "", "tooltip": "Bluetooth : %s", "class": "connected"}\n' "$devices"
    else
        printf '{"text": "", "tooltip": "Bluetooth activé", "class": "connected"}\n'
    fi
else
    printf '{"text": "", "tooltip": "Bluetooth désactivé", "class": "disabled"}\n'
fi
