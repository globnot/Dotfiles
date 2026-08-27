#!/bin/bash
# Bascule entre le workspace 6 et le workspace 1 (voir hyprland.lua : bindée
# sur la touche Menu, elle-même Caps Lock remappée, qui ne fait donc plus
# Echap).
#
# hyprctl eval + hl.dispatch(hl.dsp...) plutôt que "hyprctl dispatch
# workspace N" : sur ce build, "dispatch <args>" est lui-même sucré en
# hl.dispatch(<args>) et évalué comme du Lua, donc un argument numérique nu
# ("workspace 6") casse le parseur. Passer par hl.dsp.focus({...}), la même
# API que le reste de la config, est la forme qui marche réellement.
current=$(hyprctl activeworkspace -j | python3 -c "import json,sys; print(json.load(sys.stdin)['id'])")

if [ "$current" = "6" ]; then
    target=1
else
    target=6
fi

hyprctl eval "hl.dispatch(hl.dsp.focus({ workspace = $target }))" >/dev/null
