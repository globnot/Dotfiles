#!/bin/bash
# Sélecteur de couleur d'accent (rofi) : change ACCENT dans theme/palette.sh,
# relance theme/generate.sh pour tout propager, puis recharge les apps
# concernées. Les préréglages sont des teintes Gruvbox déjà présentes
# ailleurs dans le repo (ANSI kitty, couleurs fzf), pour rester cohérent.
set -euo pipefail

# readlink -f résout le symlink ~/.config/hypr -> Dotfiles/.config/hypr
# d'abord : sans ça, quand ce script est lancé via ce chemin lié (le cas
# réel, le bind SUPER+T l'appelle via $HOME/.config/hypr/...), cd ../../..
# remonte dans l'arborescence de ~/.config au lieu de celle du repo.
REPO="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../../.." && pwd)"

PRESETS=(
    "Fuchsia (actuel):e91e8c"
    "Rouge:cc241d"
    "Bleu:076678"
    "Vert:427b58"
    "Orange:d65d0e"
    "Violet:8f3f71"
)
CUSTOM_LABEL="Personnalisé (hex)..."

preset_line() {
    printf '<span foreground="#%s">████</span>  %s' "$2" "$1"
}

menu=""
for p in "${PRESETS[@]}"; do
    name="${p%%:*}"
    hex="${p##*:}"
    menu+="$(preset_line "$name" "$hex")"$'\n'
done
menu+="$CUSTOM_LABEL"

chosen=$(printf '%s\n' "$menu" | rofi -dmenu -i -p "Accent" -markup-rows -theme-str 'listview {lines: 7;}')
[ -z "$chosen" ] && exit 0

hex=""
if [ "$chosen" = "$CUSTOM_LABEL" ]; then
    input=$(rofi -dmenu -i -p "Hex (sans #)" -mesg "Ex : 1e90ff")
    hex="${input#\#}"
else
    for p in "${PRESETS[@]}"; do
        name="${p%%:*}"
        h="${p##*:}"
        if [ "$chosen" = "$(preset_line "$name" "$h")" ]; then
            hex="$h"
            break
        fi
    done
fi

hex="${hex,,}"
if ! [[ "$hex" =~ ^[0-9a-f]{6}$ ]]; then
    [ -n "$hex" ] && notify-send "Thème" "Couleur invalide : $hex"
    exit 1
fi

sed -i -E "s/^(ACCENT=).*/\1${hex}/" "$REPO/theme/palette.sh"
bash "$REPO/theme/generate.sh" >/dev/null

hyprctl reload >/dev/null 2>&1 || true
pkill -SIGUSR2 waybar 2>/dev/null || true
swaync-client -rs >/dev/null 2>&1 || true

# Pousse les nouvelles couleurs aux fenêtres kitty déjà ouvertes via son
# contrôle à distance (voir kitty.conf : auto_reload_config est désactivé
# exprès, un reload complet aurait remis leur taille de police par défaut,
# annulant un zoom fait avec ctrl+shift+plus/minus).
for pid in $(pgrep -x kitty); do
    kitty @ --to "unix:@mykitty-$pid" set-colors --all --configured "$REPO/.config/kitty/theme-colors.conf" >/dev/null 2>&1 || true
done

# Les indicateurs d'état actif de swaync (bluetooth/avion/profils d'énergie)
# écrivent leur propre couleur figée à l'exécution (voir ces scripts) :
# il faut les relancer pour qu'ils reprennent le nouvel accent.
bash "$HOME/.config/swaync/scripts/update-bluetooth-state.sh" >/dev/null 2>&1 || true
bash "$HOME/.config/swaync/scripts/update-airplane-state.sh" >/dev/null 2>&1 || true
bash "$HOME/.config/swaync/scripts/update-powerprofile-state.sh" >/dev/null 2>&1 || true

notify-send "Thème" "Accent changé : #$hex"
