#!/bin/bash
# Bascule la fenêtre active entre maximisée et sa taille normale (SUPER+G),
# en restant flottante/déplaçable — différent du vrai plein écran (SUPER+F
# ne fait que flottant/tuilé, voir plus haut). hl.dsp.window.fullscreen_state
# avec internal=1 est ce que Hyprland appelle "maximize" en interne :
# agrandit sans passer en vrai fullscreen (pas de masquage de la barre).
current=$(hyprctl activewindow -j | python3 -c "import json,sys; print(json.load(sys.stdin).get('fullscreen', 0))")

if [ "$current" = "1" ]; then
    target=0
else
    target=1
fi

hyprctl eval "hl.dispatch(hl.dsp.window.fullscreen_state({ internal = $target, client = 0 }))" >/dev/null
