#!/bin/bash
# Vitesse du ventilateur ThinkPad (fan1, via lm_sensors) pour le module
# custom/fan de Waybar. Seuils calqués sur le repo de l'ami (voir Dotfiles).
rpm=$(sensors 2>/dev/null | awk '/fan1/{print $2; exit}')
[[ "$rpm" =~ ^[0-9]+$ ]] || rpm=0

if [ "$rpm" -ge 4000 ]; then
    class="critical"
elif [ "$rpm" -ge 3000 ]; then
    class="high"
elif [ "$rpm" -ge 2200 ]; then
    class="warm"
else
    class="normal"
fi

printf "{\"text\": \"<span foreground='#928374'>FAN</span> %srpm\", \"class\": \"%s\"}\n" "$rpm" "$class"
