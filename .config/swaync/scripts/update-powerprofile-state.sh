#!/bin/bash
# Réécrit powerprofile-state.css pour surligner le bouton (1=power-saver, 2=balanced,
# 3=performance) qui correspond au profil actuellement actif.
source "$(dirname "${BASH_SOURCE[0]}")/state-css.sh"

current=$(powerprofilesctl get 2>/dev/null)
case "$current" in
    power-saver) n=1 ;;
    balanced) n=2 ;;
    performance) n=3 ;;
    *) n=0 ;;
esac
write_state_css "powerprofile" "$n"
