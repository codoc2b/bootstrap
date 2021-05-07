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

# Share history with other terminals
setopt share_history
# Don't show duplicated history
setopt hist_ignore_dups
setopt hist_ignore_all_dups
# Don't show commands starting with space
setopt hist_ignore_space
# Don't show history command itself
setopt hist_no_store
# Reduce extra spaces
setopt hist_reduce_blanks

# Case insensitive completions
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
# Disable entering Tab
zstyle ':completion:*' insert-tab false

# Search history with up or down key
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search

# Remove duplicates in PATH
typeset -U PATH

# Colorize ls command
alias ls='exa -al'
# Colorize cat command
alias cat='bat -P --style plain'
# Avoid brew doctor warning due to pyenv
alias brew="env PATH=${PATH//$(pyenv root)\/shims:/} brew"

# Find ghq repos with Ctrl+f
find_repo() {
  declare -r repo="$(ghq list > /dev/null | fzf-tmux --reverse +m)"
  [[ -n "$repo" ]] && cd "$(ghq root)/$repo" && zle accept-line
  zle redisplay
}
zle -N find_repo && bindkey '^f' find_repo

eval "$(anyenv init -)"
eval "$(direnv hook zsh)"
eval "$(starship init zsh)"
