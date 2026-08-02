#!/bin/bash
# Crée les liens symboliques de ~/.config/* vers ce repo.
# Un vrai fichier/dossier déjà présent est déplacé en *.bak avant de créer le lien.
# Un lien symbolique déjà présent est simplement écrasé (on suppose qu'il vient
# d'un run précédent de ce script).

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link() {
    local target="$1"   # chemin dans le repo
    local link_path="$2" # chemin final, ex: ~/.config/hypr

    if [ -L "$link_path" ]; then
        rm "$link_path"
    elif [ -e "$link_path" ]; then
        echo "Sauvegarde de $link_path -> $link_path.bak"
        mv "$link_path" "$link_path.bak"
    fi

    mkdir -p "$(dirname "$link_path")"
    ln -s "$target" "$link_path"
    echo "Lié : $link_path -> $target"
}

link "$REPO_DIR/.config/hypr"   "$HOME/.config/hypr"
link "$REPO_DIR/.config/waybar" "$HOME/.config/waybar"
link "$REPO_DIR/.config/kitty"  "$HOME/.config/kitty"
link "$REPO_DIR/.config/rofi"   "$HOME/.config/rofi"
link "$REPO_DIR/.config/nvim"   "$HOME/.config/nvim"
link "$REPO_DIR/.config/swaync" "$HOME/.config/swaync"
link "$REPO_DIR/.config/swappy" "$HOME/.config/swappy"
link "$REPO_DIR/.config/wlogout" "$HOME/.config/wlogout"
link "$REPO_DIR/.config/btop"    "$HOME/.config/btop"
link "$REPO_DIR/.config/atuin"  "$HOME/.config/atuin"
link "$REPO_DIR/.config/networkmanager-dmenu" "$HOME/.config/networkmanager-dmenu"

link "$REPO_DIR/.zshrc"    "$HOME/.zshrc"
link "$REPO_DIR/.p10k.zsh" "$HOME/.p10k.zsh"

# Dépendances requises pour ce qui précède (zsh + Oh My Zsh + Powerlevel10k,
# neovim + Mason/clangd, norminette). Ne les installe pas ici : à faire une
# fois manuellement (voir README), ce script ne fait que les liens.

echo "Terminé."
