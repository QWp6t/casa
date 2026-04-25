# Enable interactive menu selection
zstyle ':completion:*' menu select

# Case-insensitive matching
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Use ls-style colors for matches
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Fuzzy matching for completion
zstyle ':completion:*' matcher-list '' \
  'm:{a-zA-Z}={A-Za-z}' \
  'r:|[._-]=* r:|=*' \
  'l:|=* r:|=*'

# Allow completion in the middle of a word
setopt COMPLETE_IN_WORD
