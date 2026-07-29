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

# Zoxide (cd intelligent) + zi (sélecteur interactif fzf avec preview eza)
_cached_init zoxide
export _ZO_FZF_OPTS='
--border=rounded
--border-label=zi
--height=100%
--layout=default
--info=inline
--delimiter=[[:space:]]+
--preview=eza\ --icons\ --group-directories-first\ --color=always\ --tree\ --level=2\ {2..}
--preview-window=right:50%:wrap
--color=fg:#3c3836,hl:#e91e8c
--color=fg+:#282828,hl+:#e91e8c
--color=border:#928374,prompt:#076678,pointer:#076678
--color=marker:#e91e8c,spinner:#e91e8c,info:#8f3f71
'

# Atuin (historique de commandes en base SQLite, recherche floue)
_cached_init atuin

# === Header 42 ===
export MAIL="aborda@student.42.fr"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
