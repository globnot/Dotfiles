#!/bin/bash
# Pousse ~/Proton Drive vers /my-files/Thinkpad sur Proton Drive (voir
# proton-drive-sync.timer). Pas une vraie synchro bidirectionnelle : la
# CLI officielle (proton-drive-cli-bin) n'en a pas, seulement de
# l'upload/download à la demande. C'est donc une sauvegarde à sens unique
# (local -> distant), régulière :
# - seuls les dossiers modifiés depuis le dernier passage (date de
#   modification locale comparée à $state_file) sont examinés — comparer
#   tout l'arbre à chaque fois prenait plus de 10 minutes sur ce vault,
#   bien trop pour un timer horaire ;
# - prune.py met d'abord à la corbeille distante ce qui n'existe plus en
#   local dans ces dossiers (sans ça, un renommage laisse un orphelin) ;
# - push.py envoie ensuite les fichiers nouveaux/modifiés dedans.
# ".obsidian" (config/plugins Obsidian, régénérable, propre à cette
# machine) est systématiquement ignoré.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
local_dir="$HOME/Proton Drive"
remote_dir="/my-files/Thinkpad"
state_file="$HOME/.local/state/proton-drive-sync/last-run"

mkdir -p "$(dirname "$state_file")"

if [ -f "$state_file" ]; then
    find_args=(-newer "$state_file")
else
    find_args=()
fi

# Un dossier modifié (entrée ajoutée/renommée/supprimée dedans) OU un
# fichier modifié (contenu édité) compte : éditer un fichier existant ne
# change pas la date du dossier qui le contient, seulement celle du
# fichier lui-même.
changed_dirs=$(
    find "$local_dir" \( -type f -o -type d \) ! -path "*/.obsidian*" "${find_args[@]}" |
    while read -r path; do
        if [ -d "$path" ]; then echo "$path"; else dirname "$path"; fi
    done | sort -u
)

if [ -n "$changed_dirs" ]; then
    echo "$changed_dirs" | python3 "$SCRIPT_DIR/prune.py" "$local_dir" "$remote_dir"
    echo "$changed_dirs" | python3 "$SCRIPT_DIR/push.py" "$local_dir" "$remote_dir"
fi

touch "$state_file"
