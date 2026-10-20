#!/bin/bash
# Pousse ~/Proton Drive vers /my-files/Thinkpad sur Proton Drive (voir
# proton-drive-sync.timer). Pas une vraie synchro bidirectionnelle : la
# CLI officielle (proton-drive-cli-bin) n'en a pas, seulement de
# l'upload/download à la demande. C'est donc une sauvegarde à sens unique
# (local -> distant), régulière :
# - prune.py met d'abord à la corbeille distante tout ce qui n'existe plus
#   en local (sans ça, un renommage/suppression local laisse un doublon ou
#   un orphelin distant pour toujours) ;
# - push.py envoie ensuite les fichiers nouveaux/modifiés (nouvelle révision,
#   dossiers fusionnés, jamais d'écrasement complet).
# Les deux ignorent tout ".obsidian" (config/plugins Obsidian : régénérable,
# propre à cette machine, et potentiellement plein de petits fichiers qui
# ralentissent tout pour rien).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
local_dir="$HOME/Proton Drive"
remote_dir="/my-files/Thinkpad"

python3 "$SCRIPT_DIR/prune.py" "$local_dir" "$remote_dir"
python3 "$SCRIPT_DIR/push.py" "$local_dir" "$remote_dir"
