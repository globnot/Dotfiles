# Dotfiles

*Configuration de bureau Hyprland — style neobrutalism sur base Gruvbox
Light + fuchsia, pensée pour un ThinkPad P14s Gen 5 AMD sous Arch Linux.*

---

## Description

Bordures épaisses en faux noir, ombres dures décalées (pas de flou), coins
peu arrondis, fonds opaques. Le compositeur est Hyprland (config Lua
native), avec waybar, rofi, SwayNotificationCenter, wlogout, un thème SDDM
écrit à la main, et Nautilus/GTK plutôt que Dolphin/KDE.

Testé sur Arch Linux uniquement — `bootstrap.sh` installe les paquets via
`pacman`/`yay`, donc rien de tout ça ne s'installera tel quel sur une autre
distribution. Certaines valeurs sont aussi propres à cette machine
(résolutions d'écran dans `hyprland.lua`, capteur `fan1` lu par le module
fan de waybar) et à adapter ailleurs.

Le stockage sécurisé de secrets (VS Code, identifiants git...) et l'agent
SSH passent par `gnome-keyring`, démarré et déverrouillé automatiquement à
la connexion via PAM (`/etc/pam.d/sddm`, déjà prêt sur une install SDDM
standard — il suffit d'installer le paquet).

## Contenu

| Dossier/fichier | Rôle |
|---|---|
| `.config/hypr/` | `hyprland.lua`, scripts (screenshots, wlogout...), thème SDDM `gruvbrutal` (`sddm-theme/`), règles udev (`udev-rules/`) |
| `.config/waybar/` | Barre de status |
| `.config/rofi/` | Lanceur (`config.rasi`) et menu wifi (`config-wifi.rasi`) |
| `.config/swaync/` | Centre de notifications + scripts d'état |
| `.config/wlogout/` | Menu extinction/verrouillage |
| `.config/kitty/` | Terminal |
| `.config/btop/` | Moniteur de ressources |
| `.config/gtk-3.0/`, `gtk-4.0/` | Thème GTK (Nautilus, apps GTK) |
| `.config/nvim/` | Config Neovim (base NvChad) |
| `.config/networkmanager-dmenu/` | Backend du menu wifi |
| `.config/atuin/` | Historique shell |
| `.config/fastfetch/` | Résumé système au lancement (alias `ff`) |
| `.config/qt5ct/`, `qt6ct/` | Thème des rares apps Qt (surtout `polkit-kde-agent`) |
| `.config/environment.d/` | Variables d'env session-wide (thème Qt, agent SSH gnome-keyring) |
| `.config/Code/` | `argv.json`, `User/settings.json` (+ profil `42`) — voir plus bas |
| `.local/share/applications/` | Surcharge `code.desktop` (VS Code + `--no-sandbox`, voir plus bas) |
| `theme/` | Palette centralisée de la DA (`palette.sh` + `generate.sh`) |
| `.zshrc`, `.p10k.zsh` | Shell |
| `install.sh` | Liens symboliques uniquement |
| `bootstrap.sh` | Installation complète (paquets + liens + services) |

## Installation

Sur un Arch tout neuf, une seule commande installe les paquets (pacman +
AUR via `yay`), clone oh-my-zsh/powerlevel10k, active les services
système, crée les liens symboliques et déploie le thème SDDM :

```sh
git clone git@github.com:globnot/Dotfiles.git ~/Dotfiles
cd ~/Dotfiles
./bootstrap.sh
```

Si les paquets sont déjà installés (ou juste pour relier après une modif),
`install.sh` fait uniquement les liens symboliques :

```sh
./install.sh
```

Les deux scripts sont idempotents, relançables sans risque. Voir les
commentaires en tête de chaque fichier pour le détail.

## Personnaliser la couleur d'accent

`SUPER + T` ouvre un sélecteur rofi (préréglages + hex personnalisé) qui
met à jour la DA en direct.

En ligne de commande : éditer `theme/palette.sh` (7 couleurs, une seule
source pour tout le bureau) puis lancer `theme/generate.sh`, qui propage
le changement dans rofi, GTK, waybar, swaync, Hyprland, hyprlock, kitty,
wlogout, btop, fastfetch, qt5ct/qt6ct et zsh.

## VS Code : trousseau et sandbox

VS Code (`visual-studio-code-bin`, le build officiel Microsoft — le paquet
"code" d'Arch est un build OSS sans module keytar/libsecret, donc
incapable d'utiliser un trousseau quel qu'il soit) refusait toujours
d'utiliser gnome-keyring ("An OS keyring couldn't be identified"), même
trousseau fonctionnel, `argv.json` correct et flag forcé en ligne de
commande. Cause réelle, trouvée en testant `--no-sandbox` : le sandbox
Chromium isole le process d'une façon qui bloque l'accès à D-Bus sur ce
système. `"disable-chromium-sandbox": true` dans `argv.json` fait planter
le lancement (`launch-failed`) ; passer `--no-sandbox` en argument direct
via une surcharge de `code.desktop` (`.local/share/applications/`) est la
seule méthode qui fonctionne.

`User/settings.json` (police `JetBrainsMono Nerd Font Mono` assortie au
reste du bureau, thème, réglages git...) est suivi, ainsi que le profil
`42` (`User/profiles/-77ad35b/settings.json`). Le nom du dossier de ce
profil est un hash généré par VS Code propre à cette machine : sur une
install neuve, recréer le profil dans VS Code puis recopier les réglages
à la main depuis ce fichier.

## Empreinte digitale peu fiable après un moment

Symptôme : le déverrouillage par empreinte marche parfaitement juste après
le boot, puis devient capricieux après avoir utilisé la machine un
moment. Cause : le capteur (Synaptics, `06cb:00f9`) a l'autosuspend USB
activé avec un délai de seulement 2s (`power/autosuspend_delay_ms`) — il
se fait suspendre en permanence, et son réveil n'est pas fiable. Réglé
via une règle udev (`.config/hypr/udev-rules/`, déployée par
`setup-udev-rules.sh`) qui force `power/control=on` pour ce périphérique
précis (pas d'impact sur l'autosuspend des autres périphériques USB).

## Raccourcis

`SUPER + /` ouvre un pense-bête complet et à jour de tous les raccourcis
(liste maintenue à la main dans `.config/hypr/scripts/show-keybinds.sh` —
`hyprctl binds` ne permet pas de la générer automatiquement sur ce build).

| Raccourci | Action |
|---|---|
| `SUPER + Q` | Terminal |
| `SUPER + E` | Gestionnaire de fichiers |
| `SUPER + R` | Lanceur d'applications |
| `SUPER + W` | Menu wifi |
| `SUPER + N` | Notifications |
| `SUPER + M` | Extinction/verrouillage |
| `SUPER + L` | Verrouiller l'écran |
| `SUPER + T` | Changer la couleur d'accent |
| `SUPER + /` | Pense-bête des raccourcis |

## Crédits

- [Cartoone9/dotfiles](https://github.com/Cartoone9/dotfiles) — même
  laptop, référence piochée pour plusieurs morceaux : la structure des
  fonctions `cdf`/`cdw`/`cdd`/`cdfa`, l'approche GNOME/Nautilus plutôt que
  KDE, l'idée du menu wifi rofi, la disposition en grille de `wlogout`,
  fastfetch au lancement du terminal, `topgrade` pour tout mettre à jour
  d'un coup, et le thème Qt (qt5ct/qt6ct) pour les apps Qt isolées.
- [NvChad](https://github.com/NvChad/NvChad) — base de la config Neovim,
  qui crédite elle-même [LazyVim starter](https://github.com/LazyVim/starter).
- [Hyprland](https://hyprland.org/), [waybar](https://github.com/Alexays/Waybar),
  [rofi](https://github.com/davatorium/rofi),
  [networkmanager-dmenu](https://github.com/firecat53/networkmanager-dmenu),
  [SwayNotificationCenter](https://github.com/ErikReider/SwayNotificationCenter),
  [wlogout](https://github.com/ArtsyMacaw/wlogout),
  [kitty](https://sw.kovidgoyal.net/kitty/), [btop](https://github.com/aristocratos/btop),
  [powerlevel10k](https://github.com/romkatv/powerlevel10k), [atuin](https://atuin.sh/),
  [zoxide](https://github.com/ajeetdsouza/zoxide), [eza](https://github.com/eza-community/eza),
  [fzf](https://github.com/junegunn/fzf), [fd](https://github.com/sharkdp/fd),
  [fastfetch](https://github.com/fastfetch-cli/fastfetch),
  [topgrade](https://github.com/topgrade-rs/topgrade),
  [qt5ct](https://github.com/trialuser02/qt5ct)/[qt6ct](https://github.com/trialuser02/qt6ct),
  [gnome-keyring](https://gitlab.gnome.org/GNOME/gnome-keyring)
- [Nerd Fonts](https://www.nerdfonts.com/) pour les icônes utilisées
  partout (waybar, rofi, wlogout, SDDM...)

## Auteur

[@globnot](https://github.com/globnot)
