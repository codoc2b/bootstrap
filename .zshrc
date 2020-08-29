# Zinit
source "$HOME/.zinit/bin/zinit.zsh"

# Enable completions for Zinit
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load useful plugins
zinit light Aloxaf/fzf-tab
zinit light zdharma/fast-syntax-highlighting
zinit light zdharma/history-search-multi-word
zinit wait lucid atload"zicompinit; zicdreplay" blockf for zsh-users/zsh-completions

# Case insensitive completions
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
# Disable entering Tab
zstyle ':completion:*' insert-tab false

# Search history with up or down key
bindkey '^[[A' up-line-or-search
bindkey '^[[B' down-line-or-search

# Find ghq repos with Ctrl+f
find_repo() {
  declare -r repo="$(ghq list > /dev/null | fzf-tmux --reverse +m)"
  [[ -n "$repo" ]] && cd "$(ghq root)/$repo" && zle accept-line
  zle redisplay
}
zle -N find_repo && bindkey '^f' find_repo

export FZF_DEFAULT_OPTS='
--ansi
--border
--color hl:108
--cycle
--height 75%
--layout=reverse
--multi
'
export XDG_CONFIG_HOME=$HOME/.config
export PATH="/usr/local/opt/curl/bin:$PATH"

eval "$(starship init zsh)"
