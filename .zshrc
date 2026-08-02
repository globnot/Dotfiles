# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/funcheck/host:$PATH"

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(git)

source $ZSH/oh-my-zsh.sh

# ---- Aliases & functions ----

# Git
alias gs='git status'
alias gf='git fetch'
alias gpl='git pull'
alias gc='git commit -m'
alias gp='git push'

# Makefile
alias m='make'
alias mm='make && ./push_swap'

# Display
alias al='alias | grep'

# Clear et navigation
alias cl='clear'
alias ..='cd ..'

# Résumé système au lancement (voir .config/fastfetch/, thémé via theme/generate.sh)
alias ff='cl && fastfetch'

# Éditeur et code
alias v='nvim'
alias coco='cd && cd Code/42/git42/common-core/'
alias co='cd && cd Code/'
alias go='coco && cd m5/'
alias gh='42 && cd github/'
alias 42='cd && cd Code/42/'
alias train='42 && cd training/'
alias exam='train && cd 42_examshell/'

# Norminette
alias n='norminette'
alias nn='norminette srcs includes'
alias wn='watch norminette'
alias wnn='watch norminette srcs includes'

# clangd (regénère la config globale après un nouveau clone dans ~/Code)
alias clangd-refresh='"$HOME/Dotfiles/clangd/gen-config.sh"'

# Listing fichiers (eza)
alias ll='eza -l --icons --group-directories-first'
alias la='eza -la --icons --group-directories-first'
alias lt='eza --icons --tree --level=2'
alias lc='ll *c'

# Affichage
alias ec='echo $?'
alias ce='cat -e'

# Tar
alias mtar='tar -cf'
alias untar='tar -xf'

# Compiler C
alias ccc='cc -Wall -Wextra -Werror'
alias ccg='cc -Wall -Wextra -Werror -g'

# Trash CLI
alias del='trash'

# Verrouillage écran (Hyprland)
alias lock='hyprlock'

# Tout mettre à jour d'un coup (système, AUR, oh-my-zsh, plugins nvim...)
# via topgrade (AUR), inspiré de Cartoone
alias update='topgrade'

# ======================================================================================
# Cached `<tool> init zsh` (atuin, zoxide)
# ======================================================================================
# Évite de relancer l'outil à chaque ouverture de terminal ; régénère le cache
# seulement si le binaire de l'outil est plus récent (donc après une mise à jour).
_cached_init() {
	local bin=${commands[$1]} cache=$HOME/.cache/zsh/init-$1.zsh
	[[ -n $bin ]] || return 1
	if [[ ! -r $cache || $bin -nt $cache ]]; then
		command mkdir -p ${cache:h}
		"$bin" init zsh > $cache 2>/dev/null || { command rm -f $cache; return 1 }
	fi
	source $cache
}

# Palette DA : ces deux lignes sont gérées par theme/generate.sh (voir
# theme/palette.sh) — ne pas éditer directement, ce serait écrasé.
THEME_FG="#3c3836"
THEME_ACCENT="#e91e8c"

# Zoxide (cd intelligent) + zi (sélecteur interactif fzf avec preview eza)
_cached_init zoxide
export _ZO_FZF_OPTS="
--border=rounded
--border-label=zi
--height=100%
--layout=default
--info=inline
--delimiter=[[:space:]]+
--preview=eza\ --icons\ --group-directories-first\ --color=always\ --tree\ --level=2\ {2..}
--preview-window=right:50%:wrap
--color=fg:${THEME_FG},hl:${THEME_ACCENT}
--color=fg+:#282828,hl+:${THEME_ACCENT}
--color=border:#928374,prompt:#076678,pointer:#076678
--color=marker:${THEME_ACCENT},spinner:${THEME_ACCENT},info:#8f3f71
"

# ======================================================================================
# cdf/cdw/cdd/cdfa : sélecteur de dossier flou (fd + fzf + zoxide + eza)
# ======================================================================================
# Inspiré du repo de Cartoone (même machine). cdf liste les dossiers utiles
# (~/Code, ~/.config) classés par fréquence d'usage (zoxide) ; cdw fait pareil
# puis ouvre nvim ; cdd ne propose que les dossiers déjà visités (zoxide) ;
# cdfa cherche partout dans $HOME sans restriction.
DIR_FZF_OPTS=(
	--border=rounded
	--height=100%
	--layout=default
	--info=inline
	--color=fg:${THEME_FG},hl:${THEME_ACCENT}
	--color=fg+:#282828,hl+:${THEME_ACCENT}
	--color=border:#928374,prompt:#076678,pointer:#076678
	--color=marker:${THEME_ACCENT},spinner:${THEME_ACCENT},info:#8f3f71
)

# Dossiers/arbres bruyants ignorés par cdf/cdw/cdfa
FD_EXCLUDES=(
	--exclude '.cache'
	--exclude 'node_modules'
	--exclude '.git'
	--exclude '.cargo'
	--exclude '.local'
	--exclude '.npm'
)

# Racines de recherche pour cdf/cdw (cdfa ignore ceci et cherche tout $HOME)
setopt EXTENDED_GLOB
BASES=(
	$HOME/Code(N/)
	$HOME/.config(N/)
)

# Candidats de recherche normale : les bases elles-mêmes + leurs sous-dossiers
_cdf_candidates() {
	{
		print -rl -- "${BASES[@]}"
		fd --type d --hidden --no-ignore "${FD_EXCLUDES[@]}" . "${BASES[@]}" 2>/dev/null
	} | sed 's|/$||; /^$/d' | sort -u
}

# Réordonne l'entrée : dossiers déjà visités (zoxide) en premier, les autres
# ensuite du moins profond au plus profond
_cdf_frecency_rank() {
	awk -v zlist=<(zoxide query -l 2>/dev/null) '
		BEGIN { while ((getline line < zlist) > 0) rank[line] = ++n }
		$0 in rank { printf "0\t%08d\t%s\n", rank[$0], $0; next }
		           { printf "1\t%08d\t%s\n", gsub("/", "/"), $0 }
	' | sort -t$'\t' -k1,1 -k2,2 -k3,3 | cut -f3-
}

cdf() {
	local dir
	dir=$(
		_cdf_candidates \
			| _cdf_frecency_rank \
			| sed "s|^$HOME|~|" \
			| fzf "${DIR_FZF_OPTS[@]}" \
				--border-label=cdf \
				--scheme=history \
				--tiebreak=index \
				--bind 'esc:abort' \
				--query "${*:-}" \
				--preview 'eza --icons --group-directories-first --color=always --tree --level=2 "$(echo {} | sed "s|^~|$HOME|")"' \
				--preview-window=right:50%:wrap
	)
	[[ -n "$dir" ]] && cd "${dir/#\~/$HOME}"
}

cdw() {
	local dir
	dir=$(
		_cdf_candidates \
			| _cdf_frecency_rank \
			| sed "s|^$HOME|~|" \
			| fzf "${DIR_FZF_OPTS[@]}" \
				--border-label=cdw \
				--scheme=history \
				--tiebreak=index \
				--bind 'esc:abort' \
				--query "${*:-}" \
				--preview 'eza --icons --group-directories-first --color=always --tree --level=2 "$(echo {} | sed "s|^~|$HOME|")"' \
				--preview-window=right:50%:wrap
	)
	[[ -n "$dir" ]] && cd "${dir/#\~/$HOME}" && nvim
}

cdd() {
	local dir
	dir=$(
		zoxide query -l 2>/dev/null \
			| sed "s|^$HOME|~|" \
			| fzf "${DIR_FZF_OPTS[@]}" \
				--border-label=cdd \
				--scheme=history \
				--tiebreak=index \
				--bind 'esc:abort' \
				--query "${*:-}" \
				--preview 'eza --icons --group-directories-first --color=always --tree --level=2 "$(echo {} | sed "s|^~|$HOME|")"' \
				--preview-window=right:50%:wrap
	)
	[[ -n "$dir" ]] && cd "${dir/#\~/$HOME}"
}

cdfa() {
	local dir
	dir=$(
		fd . ~ --type d --hidden --no-ignore "${FD_EXCLUDES[@]}" \
			| sed "s|^$HOME|~|" \
			| fzf "${DIR_FZF_OPTS[@]}" \
				--border-label=cdfa \
				--bind 'esc:abort' \
				--query "${*:-}" \
				--preview 'eza --icons --group-directories-first --color=always --tree --level=2 "$(echo {} | sed "s|^~|$HOME|")"' \
				--preview-window=right:50%:wrap
	)
	[[ -n "$dir" ]] && cd "${dir/#\~/$HOME}"
}

# Atuin (historique de commandes en base SQLite, recherche floue)
_cached_init atuin

# === Header 42 ===
export MAIL="aborda@student.42.fr"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
