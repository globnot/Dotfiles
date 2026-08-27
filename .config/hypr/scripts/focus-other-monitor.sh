#!/bin/bash
# Bascule le focus clavier vers l'autre écran (voir hyprland.lua : bindé
# sur SUPER + Menu, Caps Lock remappée). Cible dynamiquement "l'autre"
# moniteur plutôt qu'un nom fixe, pour vraiment basculer dans les deux
# sens entre les 2 écrans.
other=$(hyprctl monitors -j | python3 -c "
import json, sys
mons = json.load(sys.stdin)
current = next(m for m in mons if m['focused'])
other = next(m for m in mons if m['name'] != current['name'])
print(other['name'])
")

# "hyprctl dispatch <args>" est sucré en hl.dispatch(<args>) et évalué
# comme du Lua sur ce build (voir toggle-workspace-6.sh) : "eval" + l'API
# structurée hl.dsp.focus est la forme qui marche réellement ici.
hyprctl eval "hl.dispatch(hl.dsp.focus({ monitor = \"$other\" }))" >/dev/null
