#!/bin/bash
# Icône VPN pour le module custom/vpn de Waybar. Cherche une connexion
# NetworkManager active de type wireguard (backend de ProtonVPN) plutôt que
# de se fier à un nom d'interface fixe (proton0), qui peut changer.
conn=$(nmcli -t -f TYPE,NAME con show --active | awk -F: '$1=="wireguard"{print $2; exit}')

if [ -n "$conn" ]; then
    printf '{"text": "", "tooltip": "VPN connecté : %s", "class": "connected"}\n' "$conn"
else
    printf '{"text": "", "tooltip": "VPN déconnecté", "class": "disconnected"}\n'
fi
