#!/bin/bash
# Lance wlogout en grille (COLS x ROWS) de carrés centrés à l'écran
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

COLS=3
ROWS=2
N=$(( COLS * ROWS ))

# Taille de carré qui tient sur les deux dimensions, clampée à une plage lisible
size_w=$(( width / COLS ))
size_h=$(( height / ROWS ))
size=$(( size_w < size_h ? size_w : size_h ))
(( size < 120 )) && size=120
(( size > 200 )) && size=200

T=$(( (height - ROWS * size) / 2 ))
B=$T
L=$(( (width - COLS * size) / 2 ))
R=$L

(( L < 0 )) && L=20 R=20
(( T < 0 )) && T=20 B=20

wlogout --protocol layer-shell -b "$COLS" -T "$T" -B "$B" -L "$L" -R "$R" &
