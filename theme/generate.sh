#!/bin/bash
# Propage theme/palette.sh dans toutes les configs qui utilisent la DA.
#
# Deux mécanismes selon le fichier :
# - Fichiers 100% données (rofi/colors.rasi, gtk-4.0/gtk.css, kitty
#   theme-colors.conf, btop theme, fastfetch, qt5ct/qt6ct) : réécrits en
#   entier à chaque run.
# - Fichiers avec de la vraie logique (hyprland.lua, hyprlock.conf, le QML
#   SDDM, waybar/swaync/wlogout CSS, .zshrc) : seule la ligne qui déclare
#   chaque couleur est réécrite (repérée par sa clé, jamais par sa position
#   dans le fichier), le reste n'est jamais touché.
#
# Les teintes Gruvbox fixes qui ne font pas partie de la palette DA
# (gris neutres, nuances warning/hover...) ne sont jamais générées : elles
# restent des littéraux, comme avant.
#
# Idempotent : relançable sans risque, y compris avec la même palette.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=palette.sh
source "$REPO_DIR/theme/palette.sh"

hex_to_rgb() { # "fbf1c7" -> "251, 241, 199"
    local h="$1"
    printf "%d, %d, %d" "0x${h:0:2}" "0x${h:2:2}" "0x${h:4:2}"
}

hex_to_ansi_rgb() { # "fbf1c7" -> "38;2;251;241;199" (couleur vraie ANSI fg)
    local h="$1"
    printf "38;2;%d;%d;%d" "0x${h:0:2}" "0x${h:2:2}" "0x${h:4:2}"
}

# "key: value;" / "key = value" — remplace en préservant indentation/préfixe.
replace_value() {
    local file="$1" key="$2" value="$3" suffix="${4:-}"
    sed -i -E "s|^([[:space:]]*${key}[[:space:]]*[:=][[:space:]]*).*|\1${value}${suffix}|" "$file"
}

# "@define-color name value;" (syntaxe GTK, espace au lieu de ':')
replace_define_color() {
    local file="$1" name="$2" value="$3"
    sed -i -E "s|^([[:space:]]*@define-color[[:space:]]+${name}[[:space:]]+).*|\1${value};|" "$file"
}

echo "== Fichiers 100% générés =="

cat > "$REPO_DIR/.config/rofi/colors.rasi" <<EOF
/* Généré par theme/generate.sh à partir de theme/palette.sh, ne pas éditer
   à la main : ce fichier serait écrasé au prochain run. */
* {
    bg0:      #$BG0;
    bg1:      #$BG1;
    fg0:      #$FG0;
    fg1:      #$FG1;
    accent:   #$ACCENT;
    fauxnoir: #$FAUXNOIR;
    urgent:   #$URGENT;
}
EOF

cat > "$REPO_DIR/.config/gtk-4.0/gtk.css" <<EOF
/* Généré par theme/generate.sh à partir de theme/palette.sh, ne pas éditer
   à la main. Recolorie les jetons sémantiques GTK4/libadwaita (pas de
   thème complet à installer). gtk-3.0/gtk.css importe ce fichier. */
@define-color accent_bg_color #$ACCENT;
@define-color accent_color #$ACCENT;
@define-color accent_fg_color #$BG0;
@define-color selected_bg_color #$ACCENT;
@define-color selected_fg_color #$BG0;
@define-color window_bg_color #$BG0;
@define-color window_fg_color #$FG0;
@define-color view_bg_color #$BG0;
@define-color view_fg_color #$FG0;
@define-color headerbar_bg_color #$BG1;
@define-color headerbar_fg_color #$FG0;
@define-color card_bg_color #$BG1;
@define-color card_fg_color #$FG0;
@define-color popover_bg_color #$BG0;
@define-color popover_fg_color #$FG0;
@define-color sidebar_bg_color #$BG1;
@define-color sidebar_fg_color #$FG0;
@define-color destructive_bg_color #$URGENT;
@define-color destructive_color #$URGENT;
@define-color destructive_fg_color #$BG0;
EOF

cat > "$REPO_DIR/.config/kitty/theme-colors.conf" <<EOF
# Généré par theme/generate.sh à partir de theme/palette.sh, ne pas éditer
# à la main. Inclus par kitty.conf (include theme-colors.conf).
background            #$BG0
foreground             #$FG0
selection_background   #$FG0
selection_foreground   #$BG0
url_color              #$ACCENT
cursor                 #$FG0
color0  #$BG0
color9  #$URGENT
color15 #$FG0
tab_bar_background        #$BG1
active_tab_background      #$ACCENT
active_tab_foreground      #$BG0
inactive_tab_background    #$BG1
EOF

ACCENT_ANSI="$(hex_to_ansi_rgb "$ACCENT")"
FAUXNOIR_ANSI="$(hex_to_ansi_rgb "$FAUXNOIR")"

cat > "$REPO_DIR/.config/fastfetch/config.jsonc" <<EOF
// Généré par theme/generate.sh à partir de theme/palette.sh, ne pas éditer
// à la main. Lancé via l'alias \`ff\` (voir .zshrc).
{
    "\$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
    "logo": {
        "type": "small",
        "color": { "1": "$ACCENT_ANSI", "2": "$ACCENT_ANSI" },
        "padding": { "top": 2, "left": 1 }
    },
    "modules": [
        "break",
        { "type": "custom", "format": "\u001b[${FAUXNOIR_ANSI}m── Matériel ──" },
        { "type": "host",      "key": " PC",  "keyColor": "$ACCENT_ANSI" },
        { "type": "cpu",       "key": " CPU", "keyColor": "$ACCENT_ANSI" },
        { "type": "gpu",       "key": "󰍛 GPU", "keyColor": "$ACCENT_ANSI" },
        { "type": "memory",    "key": " RAM", "keyColor": "$ACCENT_ANSI" },
        { "type": "disk",      "key": " Disque", "keyColor": "$ACCENT_ANSI" },
        "break",
        { "type": "custom", "format": "\u001b[${FAUXNOIR_ANSI}m── Logiciel ──" },
        { "type": "os",        "key": " OS",      "keyColor": "$ACCENT_ANSI" },
        { "type": "kernel",    "key": " Kernel",  "keyColor": "$ACCENT_ANSI" },
        { "type": "uptime",    "key": " Uptime",  "keyColor": "$ACCENT_ANSI" },
        { "type": "packages",  "key": "󰏖 Paquets", "keyColor": "$ACCENT_ANSI" },
        { "type": "shell",     "key": " Shell",   "keyColor": "$ACCENT_ANSI" },
        { "type": "wm",        "key": " WM",      "keyColor": "$ACCENT_ANSI" },
        { "type": "terminal",  "key": " Terminal","keyColor": "$ACCENT_ANSI" },
        "break",
        { "type": "colors", "paddingLeft": 2 }
    ]
}
EOF

cat > "$REPO_DIR/.config/btop/themes/gruvbrutal.theme" <<EOF
# Theme: Gruvbrutal — généré par theme/generate.sh à partir de
# theme/palette.sh, ne pas éditer à la main.
# Gruvbox Light + accent, assorti au reste du bureau (waybar/swaync/hyprland).
# Rampe de dégradé : gris-tan neutre au repos -> accent -> rouge en charge.

theme[main_bg]="#$BG0"
theme[main_fg]="#$FG0"
theme[title]="#$FAUXNOIR"
theme[hi_fg]="#$ACCENT"
theme[selected_bg]="#$BG1"
theme[selected_fg]="#$FAUXNOIR"
theme[inactive_fg]="#a89984"
theme[graph_text]="#$FG1"
theme[proc_misc]="#$ACCENT"
theme[cpu_box]="#$FAUXNOIR"
theme[mem_box]="#$FAUXNOIR"
theme[net_box]="#$FAUXNOIR"
theme[proc_box]="#$FAUXNOIR"
theme[div_line]="#a89984"

theme[temp_start]="#a89984"
theme[temp_mid]="#$ACCENT"
theme[temp_end]="#$URGENT"

theme[cpu_start]="#$BG1"
theme[cpu_mid]="#$ACCENT"
theme[cpu_end]="#$URGENT"

theme[process_start]="#$FG0"
theme[process_mid]="#$ACCENT"
theme[process_end]="#$URGENT"

theme[free_start]="#a89984"
theme[free_mid]="#$ACCENT"
theme[free_end]="#$URGENT"

theme[cached_start]="#a89984"
theme[cached_mid]="#$ACCENT"
theme[cached_end]="#$URGENT"

theme[available_start]="#a89984"
theme[available_mid]="#$ACCENT"
theme[available_end]="#$URGENT"

theme[used_start]="#a89984"
theme[used_mid]="#$ACCENT"
theme[used_end]="#$URGENT"

theme[download_start]="#a89984"
theme[download_mid]="#$ACCENT"
theme[download_end]="#$URGENT"

theme[upload_start]="#a89984"
theme[upload_mid]="#$ACCENT"
theme[upload_end]="#$URGENT"
EOF

# Palette Qt (qt5ct/qt6ct), 21 rôles QPalette dans l'ordre attendu par ces
# apps (WindowText, Button, Light, Midlight, Dark, Mid, Text, BrightText,
# ButtonText, Base, Window, Shadow, Highlight, HighlightedText, Link,
# LinkVisited, AlternateBase, NoRole, ToolTipBase, ToolTipText,
# PlaceholderText). Neutres fixes (a89984) hors palette, comme ailleurs.
QT_COLORS="#ff$FG0, #ff$BG1, #ff$BG0, #ff$BG1, #ffa89984, #ffa89984, #ff$FG0, #ff$FG0, #ff$FG0, #ff$BG0, #ff$BG0, #ff$FAUXNOIR, #ff$ACCENT, #ff$BG0, #ff076678, #ff8f3f71, #ff$BG1, #ff$FG0, #ff$BG1, #ff$FG0, #80$FG1"

for ctdir in qt5ct qt6ct; do
    mkdir -p "$REPO_DIR/.config/$ctdir/colors"
    cat > "$REPO_DIR/.config/$ctdir/colors/Gruvbrutal.conf" <<EOF
[ColorScheme]
active_colors=$QT_COLORS
disabled_colors=$QT_COLORS
inactive_colors=$QT_COLORS
EOF
done

echo "== Fichiers avec logique : remplacement ciblé par clé =="

# --- swaync : :root (CSS custom properties) + @define-color (fallback) ---
# Les teintes qui ne sont PAS dans la palette (d5c4a1, 928374...) restent
# des littéraux, non touchées ici.
f="$REPO_DIR/.config/swaync/style.css"
replace_value "$f" "--cc-bg" "rgb($(hex_to_rgb "$BG0"))" ";"
replace_value "$f" "--noti-border-color" "#$FAUXNOIR" ";"
replace_value "$f" "--noti-bg" "$(hex_to_rgb "$BG1")" ";"
replace_value "$f" "--noti-bg-focus" "rgba($(hex_to_rgb "$ACCENT"), 0.15)" ";"
replace_value "$f" "--noti-close-bg-hover" "rgb($(hex_to_rgb "$URGENT"))" ";"
replace_value "$f" "--text-color" "rgb($(hex_to_rgb "$FG0"))" ";"
replace_value "$f" "--bg-selected" "rgb($(hex_to_rgb "$ACCENT"))" ";"
replace_value "$f" "--notification-shadow" "5px 5px 0 0 #$FAUXNOIR" ";"
replace_value "$f" "--hard-shadow-sm" "3px 3px 0 0 #$FAUXNOIR" ";"

replace_define_color "$f" "cc-bg" "rgb($(hex_to_rgb "$BG0"))"
replace_define_color "$f" "noti-border-color" "#$FAUXNOIR"
replace_define_color "$f" "noti-bg" "rgba($(hex_to_rgb "$BG1"), 1)"
replace_define_color "$f" "noti-bg-opaque" "rgb($(hex_to_rgb "$BG1"))"
replace_define_color "$f" "noti-bg-focus" "rgba($(hex_to_rgb "$ACCENT"), 0.15)"
replace_define_color "$f" "noti-close-bg" "rgba($(hex_to_rgb "$FG0"), 0.1)"
replace_define_color "$f" "noti-close-bg-hover" "rgba($(hex_to_rgb "$URGENT"), 0.15)"
replace_define_color "$f" "text-color" "rgb($(hex_to_rgb "$FG0"))"
replace_define_color "$f" "bg-selected" "rgb($(hex_to_rgb "$ACCENT"))"

# --- waybar / wlogout : @define-color en tête de fichier ---
for f in "$REPO_DIR/.config/waybar/style.css" "$REPO_DIR/.config/wlogout/style.css"; do
    replace_define_color "$f" "bg0" "#$BG0"
    replace_define_color "$f" "bg1" "#$BG1"
    replace_define_color "$f" "fg0" "#$FG0"
    replace_define_color "$f" "fauxnoir" "#$FAUXNOIR"
    replace_define_color "$f" "accent" "#$ACCENT"
done
replace_define_color "$REPO_DIR/.config/waybar/style.css" "urgent" "#$URGENT"

# --- hyprland.lua : locals en tête de fichier ---
f="$REPO_DIR/.config/hypr/hyprland.lua"
replace_value "$f" 'local themeAccent' "\"$ACCENT\"" ""
replace_value "$f" 'local themeFauxnoir' "\"$FAUXNOIR\"" ""

# --- hyprlock.conf : $variables en tête de fichier ---
f="$REPO_DIR/.config/hypr/hyprlock.conf"
replace_value "$f" '\$bg0' "$BG0" ""
replace_value "$f" '\$bg1' "$BG1" ""
replace_value "$f" '\$fg0' "$FG0" ""
replace_value "$f" '\$fg1' "$FG1" ""
replace_value "$f" '\$accent' "$ACCENT" ""
replace_value "$f" '\$fauxnoir' "$FAUXNOIR" ""

# --- QML SDDM : property color en tête de fichier ---
f="$REPO_DIR/.config/hypr/sddm-theme/gruvbrutal/Main.qml"
replace_value "$f" 'property color cBg0' "\"#$BG0\"" ""
replace_value "$f" 'property color cFg0' "\"#$FG0\"" ""
replace_value "$f" 'property color cAccent' "\"#$ACCENT\"" ""
replace_value "$f" 'property color cFauxnoir' "\"#$FAUXNOIR\"" ""
replace_value "$f" 'property color cUrgent' "\"#$URGENT\"" ""

# --- .zshrc : variables THEME_* en tête du bloc fzf ---
f="$REPO_DIR/.zshrc"
replace_value "$f" 'THEME_FG' "\"#$FG0\"" ""
replace_value "$f" 'THEME_ACCENT' "\"#$ACCENT\"" ""

echo
echo "Terminé. Recharge les apps concernées pour voir le résultat :"
echo "  hyprctl reload ; pkill -SIGUSR2 waybar ; swaync-client -rs"
