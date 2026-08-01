#!/bin/bash
# Lance wlogout avec des boutons carrés sur une seule ligne, centrés à l'écran
# (même principe que le repo de l'ami, sans dépendance à jq).

if pgrep -x "wlogout" > /dev/null; then
    pkill -x "wlogout"
    exit 0
fi

read -r width height <<< "$(hyprctl -j monitors | python3 -c '
import json, sys
mons = json.load(sys.stdin)
m = next(mon for mon in mons if mon["focused"])
print(int(m["width"] / m["scale"]), int(m["height"] / m["scale"]))
')"

N=6

size=$(( height / 4 ))
(( size < 120 )) && size=120
(( size > 200 )) && size=200

T=$(( (height - size) / 2 ))
B=$T
L=$(( (width - N * size) / 2 ))
R=$L

if (( L < 0 )); then
    L=20; R=20
    size=$(( (width - 40) / N ))
    T=$(( (height - size) / 2 ))
    B=$T
fi

wlogout --protocol layer-shell -b "$N" -T "$T" -B "$B" -L "$L" -R "$R" &
