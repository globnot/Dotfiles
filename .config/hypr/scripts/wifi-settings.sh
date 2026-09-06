#!/bin/bash
# Panneau wifi (SUPER+W) : le vrai panneau GNOME Réglages plutôt qu'un menu
# rofi/nmcli maison — scan live, dialogues de mot de passe, portails
# captifs, tout ce que GNOME gère déjà nativement.
#
# gnome-control-center refuse de démarrer si XDG_CURRENT_DESKTOP n'est pas
# GNOME, d'où le spoof ci-dessous (limité à ce process, ne change rien au
# reste de la session). Idée et calibrage venus de Cartoone9/dotfiles.
if pgrep -x gnome-control-c > /dev/null; then
    pkill -x gnome-control-c
    exit 0
fi

env XDG_CURRENT_DESKTOP=GNOME gnome-control-center wifi &
