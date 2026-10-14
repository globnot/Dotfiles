#!/bin/bash
# Bascule l'affichage du dock (SUPER+D). nwg-dock-hyprland tourne en
# permanence en résident (-r, voir hyprland.lua), invisible par défaut ;
# ce signal temps réel (SIGRTMIN+1) lui fait montrer/cacher sa fenêtre.
# `pgrep -x`/`pkill -x` tronquent le nom à 15 caractères (celui-ci en fait
# 16), d'où le pattern ancré en -f pour cibler le bon process sans
# matcher ce script lui-même.
pid=$(pgrep -f "^nwg-dock-hyprland")
[ -n "$pid" ] && kill -s RTMIN+1 "$pid"
