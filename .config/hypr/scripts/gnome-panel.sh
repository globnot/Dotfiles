#!/bin/bash
# Ouvre un panneau de GNOME Réglages (wifi, bluetooth...) en fenêtre
# flottante (voir la règle de fenêtre "float-gnome-control-center" dans
# hyprland.lua). Usage : gnome-panel.sh <panel>, ex: gnome-panel.sh wifi
#
# gnome-control-center est mono-instance : le rappeler avec un autre
# panneau alors qu'il tourne déjà bascule dessus au lieu d'en ouvrir un
# second, donc pas de logique toggle/ferme ici — sinon rouvrir sur un
# autre panneau fermerait la fenêtre au lieu de changer de page.
#
# Il refuse de démarrer si XDG_CURRENT_DESKTOP n'est pas GNOME, d'où le
# spoof ci-dessous (limité à ce process, ne change rien au reste de la
# session).
env XDG_CURRENT_DESKTOP=GNOME gnome-control-center "$1" &
