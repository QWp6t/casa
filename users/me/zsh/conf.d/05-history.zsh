# History configuration
HISTFILE=~/.config/zsh/.zsh_history
HISTSIZE=676767
SAVEHIST=$HISTSIZE

setopt APPENDHISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS

# Bind up/down and ^p/^n to navigate history using current line as a prefix
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
