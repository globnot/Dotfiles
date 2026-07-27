#!/bin/bash
# Ajuste la température de couleur de l'écran (hyprsunset) par paliers de 300K.
# warmer = plus chaud/jaune (K plus bas), cooler = plus froid/neutre (K plus haut).
STEP=300
MIN=3000
MAX=6500

current=$(hyprctl hyprsunset temperature)

if [ "$1" = "warmer" ]; then
    new=$((current - STEP))
else
    new=$((current + STEP))
fi

[ "$new" -lt "$MIN" ] && new=$MIN
[ "$new" -gt "$MAX" ] && new=$MAX

hyprctl hyprsunset temperature "$new" >/dev/null
notify-send -t 1500 "Température écran" "${new}K"
