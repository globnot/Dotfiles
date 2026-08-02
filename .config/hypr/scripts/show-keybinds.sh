#!/bin/bash
# Affiche un pense-bête des raccourcis clavier via rofi (liste en lecture
# seule : cliquer/valider une ligne ne fait rien, Echap ferme).
#
# Pourquoi une liste écrite à la main plutôt que générée depuis
# `hyprctl binds` : sur ce build Hyprland (config Lua), `hyprctl binds -j`
# renvoie un JSON mal formé (champs décalés) et les binds Lua n'ont de toute
# façon aucune description exploitable côté compositeur (dispatcher toujours
# "__lua", pas de texte). Voir hyprland.lua pour la liste réelle des binds.

if pgrep -x rofi > /dev/null; then
    pkill -x rofi
    exit 0
fi

cat <<'EOF' | rofi -dmenu -i -p "Raccourcis" -mesg "Lecture seule : Échap pour fermer" \
    -theme-str 'window {height: 90%;} listview {lines: 20; fixed-height: false;}'
── Applications ──
SUPER + Q — Terminal
SUPER + E — Gestionnaire de fichiers
SUPER + R — Lanceur d'applications (rofi)
SUPER + W — Menu wifi
SUPER + N — Panneau de notifications
SUPER + M — Menu extinction/verrouillage
SUPER + L — Verrouiller l'écran
── Fenêtres ──
SUPER + C — Fermer la fenêtre active
SUPER + V — Basculer flottant/tuilé
SUPER + P — Pseudo-tile
SUPER + J — Alterner le sens du split (dwindle)
SUPER + flèches — Déplacer le focus
SUPER + SHIFT + flèches — Échanger la fenêtre avec sa voisine
SUPER + CTRL + flèches — Redimensionner (maintenir pour continuer)
SUPER + clic gauche + glisser — Déplacer la fenêtre
SUPER + clic droit + glisser — Redimensionner la fenêtre
── Workspaces ──
SUPER + 1..9 — Aller au workspace
SUPER + SHIFT + 1..9 — Déplacer la fenêtre vers le workspace
SUPER + molette souris — Workspace suivant/précédent
SUPER + S — Scratchpad (workspace spécial)
SUPER + SHIFT + S — Déplacer la fenêtre vers le scratchpad
── Écran & confort ──
SUPER + [ — Écran plus chaud (moins de lumière bleue)
SUPER + ] — Écran plus froid
SUPER + CTRL + D — Réorganiser les écrans (arrange-monitor.py)
Impr écran — Capture d'une zone (annotation swappy)
SHIFT + Impr écran — Capture plein écran
── Divers ──
Touches multimédia — Volume, luminosité, lecture (gérées nativement)
── Terminal ──
cdf — Sélecteur flou de dossier (Code/.config), classé par fréquence d'usage
cdw — Comme cdf, puis ouvre nvim
cdd — Sélecteur flou parmi les dossiers déjà visités (zoxide)
cdfa — Sélecteur flou dans tout $HOME
zi — Sélecteur interactif zoxide (cd intelligent)
btop — Moniteur de ressources (CPU/RAM/réseau/process)
Ctrl+R — Historique de commandes (atuin, recherche floue)
n / nn — Norminette (dossier courant / srcs + includes)
EOF
