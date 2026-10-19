#!/bin/bash
# Pousse ~/Proton Drive vers /my-files/Thinkpad sur Proton Drive (voir
# proton-drive-sync.timer). Pas une vraie synchro bidirectionnelle : la
# CLI officielle (proton-drive-cli-bin) n'en a pas, seulement de
# l'upload/download à la demande. C'est donc une sauvegarde à sens unique
# (local -> distant), régulière, qui crée une nouvelle révision des
# fichiers modifiés et fusionne le contenu des dossiers (jamais
# d'écrasement complet grâce à -f create-new-revision -d merge).
set -euo pipefail
shopt -s nullglob dotglob

local_dir="$HOME/Proton Drive"
remote_dir="/my-files/Thinkpad"

items=("$local_dir"/*)
if [ ${#items[@]} -eq 0 ]; then
    exit 0
fi

proton-drive filesystem upload -f create-new-revision -d merge "${items[@]}" "$remote_dir"
