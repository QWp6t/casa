# Defines the `wt` shell function so `wt switch`/`remove` can cd the shell.
# Completions come from the packaged _wt in fpath, picked up by compinit.
eval "$(wt config shell init zsh)"
