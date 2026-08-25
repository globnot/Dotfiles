#!/bin/bash
# Bootstrap complet : d'un Arch fraîchement installé à ce bureau exact.
# Installe les paquets (pacman + AUR via yay), clone oh-my-zsh/powerlevel10k,
# active les services système, crée les liens symboliques (install.sh) et
# déploie le thème SDDM.
#
# Idempotent : relançable sans risque (pacman/yay --needed n'installent que
# ce qui manque, install.sh écrase juste ses propres liens).
#
# Suppose un Arch de base déjà là (linux, base, pacman, sudo configuré) :
# ce script ne touche pas au matériel/noyau/bootloader, seulement à ce que
# CE repo utilise.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ----------------------------------------------------------------------
# 1. yay (helper AUR), si absent
# ----------------------------------------------------------------------
if ! command -v yay >/dev/null; then
    echo "== Installation de yay (AUR) =="
    sudo pacman -S --needed base-devel git
    tmp=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$tmp/yay"
    (cd "$tmp/yay" && makepkg -si)
    rm -rf "$tmp"
fi

# ----------------------------------------------------------------------
# 2. Paquets — dépôts officiels
# ----------------------------------------------------------------------
# Coeur du bureau : tout ce que les configs de ce repo appellent réellement
# (hyprland.lua, waybar, rofi, swaync, wlogout, sddm, .zshrc...).
PACMAN_CORE=(
    base-devel
    hyprland hyprlock hypridle hyprsunset awww
    waybar kitty rofi swaync sddm nautilus btop fastfetch
    networkmanager-dmenu polkit-kde-agent xdg-desktop-portal-hyprland uwsm
    qt5-wayland qt6-wayland qt5ct qt6ct gnome-keyring
    zsh git neovim atuin zoxide eza fd fzf python
    grim slurp swappy libnotify brightnessctl trash-cli playerctl
    ttf-jetbrains-mono-nerd power-profiles-daemon
    pipewire-alsa pipewire-jack pipewire-pulse wireplumber
    blueman bluez bluez-utils networkmanager wpa_supplicant xdg-utils
    lm_sensors desktop-file-utils
)

# Installés sur la machine actuelle mais pas appelés par une config trackée
# ici : apps perso (discord, gimp, spotify, brave) ou outils CLI génériques.
# rofi-emoji et network-manager-applet sont installés mais actuellement
# reliés à aucun raccourci/autostart (pas de bind dessus dans hyprland.lua).
# Retire ce qui ne t'intéresse pas.
PACMAN_EXTRAS=(
    discord gimp spotify-launcher pavucontrol htop nano vim wev
    lazygit unzip wget smartmontools fprintd python-pipx
    rofi-emoji network-manager-applet
)

echo "== Paquets officiels (coeur) =="
sudo pacman -S --needed "${PACMAN_CORE[@]}"

echo "== Paquets officiels (extras, perso) =="
sudo pacman -S --needed "${PACMAN_EXTRAS[@]}"

# ----------------------------------------------------------------------
# 3. Paquets — AUR
# ----------------------------------------------------------------------
AUR_CORE=(wlogout)
# visual-studio-code-bin (build officiel Microsoft), pas le paquet officiel
# "code" (OSS) : ce dernier n'a aucun module natif keytar/libsecret, donc
# aucun moyen de stocker les identifiants (ex. connexion GitHub) dans un
# vrai trousseau — vérifié en observant qu'il ne contacte jamais le
# service D-Bus org.freedesktop.secrets. Voir .config/Code/argv.json.
AUR_EXTRAS=(brave-bin topgrade visual-studio-code-bin proton-vpn-gtk-app)

echo "== Paquets AUR (coeur) =="
yay -S --needed "${AUR_CORE[@]}"

echo "== Paquets AUR (extras, perso) =="
yay -S --needed "${AUR_EXTRAS[@]}"

# ----------------------------------------------------------------------
# 4. Shell : oh-my-zsh + powerlevel10k, zsh par défaut
# ----------------------------------------------------------------------
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "== Installation d'oh-my-zsh =="
    git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
fi

P10K_DIR="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
    echo "== Installation de powerlevel10k =="
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
fi

if [ "$(getent passwd "$USER" | cut -d: -f7)" != "$(command -v zsh)" ]; then
    echo "== zsh comme shell par défaut =="
    chsh -s "$(command -v zsh)"
fi

# ----------------------------------------------------------------------
# 5. Services système + locale française (pour Brave, voir son .desktop)
# ----------------------------------------------------------------------
echo "== Activation des services =="
sudo systemctl enable --now NetworkManager bluetooth sddm

if ! locale -a | grep -qi '^fr_FR.utf8$'; then
    echo "== Génération de la locale fr_FR.UTF-8 (système reste en_US.UTF-8) =="
    sudo sed -i -E 's/^#(fr_FR\.UTF-8 UTF-8)/\1/' /etc/locale.gen
    sudo locale-gen
fi

# ----------------------------------------------------------------------
# 6. Liens symboliques + thème SDDM + règles udev + surcharge fprintd
# ----------------------------------------------------------------------
"$REPO_DIR/install.sh"
sudo "$REPO_DIR/.config/hypr/scripts/setup-sddm-theme.sh"
sudo "$REPO_DIR/.config/hypr/scripts/setup-udev-rules.sh"
sudo "$REPO_DIR/.config/hypr/scripts/setup-fprintd.sh"

echo
echo "Terminé. Redémarre (ou lance une session Hyprland) pour tout voir en place."
echo
echo "Reste manuel (pas automatisable sans identifiants/matériel) :"
echo "  - norminette : pipx install depuis l'intra 42"
echo "  - connexion Discord/Spotify/Brave"
echo "  - empreinte digitale : fprintd-enroll"
echo "  - neovim installe ses plugins/LSP (Mason, clangd...) tout seul au"
echo "    premier lancement, il faut juste une connexion internet"
