# Dotfiles

Config de bureau Hyprland (Wayland), style **neobrutalism** sur base
**Gruvbox Light + fuchsia** : bordures épaisses en faux noir, ombres dures
décalées (pas de flou), coins peu arrondis, fonds opaques.

## Stack

- **Compositeur** : [Hyprland](https://hyprland.org/) (config Lua native, pas l'ancien `hyprland.conf`), `hyprlock`, `hypridle`, `hyprsunset`
- **Barre** : [waybar](https://github.com/Alexays/Waybar)
- **Lanceur / menu wifi** : [rofi](https://github.com/davatorium/rofi) + [networkmanager-dmenu](https://github.com/firecat53/networkmanager-dmenu)
- **Notifications** : [SwayNotificationCenter](https://github.com/ErikReider/SwayNotificationCenter)
- **Extinction/verrouillage** : [wlogout](https://github.com/ArtsyMacaw/wlogout)
- **Login** : SDDM, thème `gruvbrutal` écrit à la main (QML, voir `.config/hypr/sddm-theme/`)
- **Terminal** : [kitty](https://sw.kovidgoyal.net/kitty/) + zsh (oh-my-zsh, [powerlevel10k](https://github.com/romkatv/powerlevel10k))
- **Fichiers** : Nautilus (GTK, thémé via `gtk-3.0`/`gtk-4.0`)
- **Monitoring** : [btop](https://github.com/aristocratos/btop)
- **Éditeur** : Neovim sur base [NvChad](https://github.com/NvChad/NvChad)
- **Historique/nav** : [atuin](https://atuin.sh/), [zoxide](https://github.com/ajeetdsouza/zoxide), [eza](https://github.com/eza-community/eza), [fzf](https://github.com/junegunn/fzf), [fd](https://github.com/sharkdp/fd)

## Installation

**Sur un Arch tout neuf**, une seule commande installe les paquets (pacman +
AUR via `yay`), clone oh-my-zsh/powerlevel10k, active les services système,
crée les liens symboliques et déploie le thème SDDM :

```sh
git clone git@github.com:globnot/Dotfiles.git ~/Dotfiles
cd ~/Dotfiles
./bootstrap.sh
```

**Si les paquets sont déjà installés** (ou pour relier après une modif),
`install.sh` fait juste les liens symboliques :

```sh
./install.sh
```

Les deux scripts sont idempotents (relançables sans risque). Voir les
commentaires en tête de chaque fichier pour le détail.

## Structure

```
.config/hypr/            hyprland.lua, scripts (screenshot, wlogout, etc.),
                         thème SDDM gruvbrutal (.config/hypr/sddm-theme/)
.config/waybar/          barre de status
.config/rofi/            lanceur (config.rasi) + menu wifi (config-wifi.rasi)
.config/swaync/          centre de notifications + scripts d'état
.config/wlogout/          menu extinction/verrouillage
.config/kitty/           terminal
.config/btop/            moniteur de ressources
.config/gtk-3.0/, gtk-4.0/  thème GTK (Nautilus et apps GTK)
.config/nvim/            config Neovim (base NvChad)
.config/networkmanager-dmenu/  menu wifi (backend)
.config/atuin/           historique shell
theme/                   palette centralisée de la DA (voir plus bas)
.zshrc, .p10k.zsh        shell
install.sh               liens symboliques uniquement
bootstrap.sh             installation complète (paquets + liens + services)
```

## Raccourcis

`SUPER + /` ouvre un pense-bête complet et à jour de tous les raccourcis
(liste statique maintenue à la main dans
`.config/hypr/scripts/show-keybinds.sh` — `hyprctl binds` ne permet pas de
la générer automatiquement sur ce build, voir les commentaires du script).

Les essentiels :

| Raccourci | Action |
|---|---|
| `SUPER + Q` | Terminal |
| `SUPER + E` | Gestionnaire de fichiers (Nautilus) |
| `SUPER + R` | Lanceur d'applications |
| `SUPER + W` | Menu wifi |
| `SUPER + N` | Notifications |
| `SUPER + M` | Extinction/verrouillage |
| `SUPER + L` | Verrouiller l'écran |
| `SUPER + T` | Changer la couleur d'accent |
| `SUPER + /` | Pense-bête des raccourcis |

## Personnaliser la couleur d'accent

`SUPER + T` ouvre un sélecteur rofi (préréglages + hex personnalisé) qui met
à jour la DA en direct.

En ligne de commande : éditer `theme/palette.sh` (7 couleurs, une seule
source pour tout le bureau) puis lancer `theme/generate.sh`, qui propage le
changement dans rofi, GTK, waybar, swaync, Hyprland, hyprlock, kitty,
wlogout, btop et zsh. Voir les commentaires de ces deux fichiers pour le
détail du mécanisme (certains fichiers sont régénérés en entier, d'autres
— ceux qui mélangent couleurs et vraie logique — ne voient réécrire que
les lignes de déclaration).

## Crédits

- [Cartoone9/dotfiles](https://github.com/Cartoone9/dotfiles) — même
  laptop, référence piochée pour plusieurs morceaux : la structure des
  fonctions `cdf`/`cdw`/`cdd`/`cdfa`, l'approche GNOME/Nautilus plutôt que
  KDE, l'idée du menu wifi rofi, la disposition en grille de `wlogout`.
- [NvChad](https://github.com/NvChad/NvChad) — base de la config Neovim
  (`.config/nvim/`), qui crédite elle-même
  [LazyVim starter](https://github.com/LazyVim/starter).
- Tous les projets listés dans **Stack** ci-dessus, et les
  [Nerd Fonts](https://www.nerdfonts.com/) pour les icônes utilisées
  partout (waybar, rofi, wlogout, SDDM...).
