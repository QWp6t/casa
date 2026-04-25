export EDITOR=vim
export VISUAL=vim
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep"

export GEM_HOME="$HOME/.config/ruby"
export PATH="$PATH:$GEM_HOME/bin"

export PATH="$PATH:$HOME/.npm-global/bin"

if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then
    . $HOME/.nix-profile/etc/profile.d/nix.sh
fi
