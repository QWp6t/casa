alias ..='cd ..'

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alias 755d='find . -type d -exec chmod 755 {} \;'
alias 644f='find . -type f -exec chmod 644 {} \;'

alias octal='stat -c "%a %n"'
alias diff='diff --color -u'
alias follow='namei -om'

# git
alias gl='git log --oneline --all --graph --decorate'
alias nah='git reset --hard; git clean -df;'

# laravel
alias artisan='ps aux | grep -q "[s]ail" && sail artisan || php artisan'
alias sail='test -f sail && sh sail || vendor/bin/sail'

# memes
alias :wq='echo "oopsie friend, this isn''t vim 🙃"'

# misc
alias myip='curl -s https://icanhazip.com'

if command -v dircolors >/dev/null 2>&1; then
    if [[ -r ~/.dircolors ]]; then
        eval "$(dircolors -b ~/.dircolors)"
    else
        eval "$(dircolors -b)"
    fi

    alias ls="ls --color=auto"
    alias grep="grep --color=auto"
    alias fgrep="fgrep --color=auto"
    alias egrep="egrep --color=auto"
fi

if command -v eza >/dev/null 2>&1; then
    alias ls="eza -h --git"
fi

if command -v fzf >/dev/null 2>&1; then
    alias pf="fzf --preview='less {}' --bind shift-up:preview-page-up,shift-down:preview-page-down"
fi

if command -v bat >/dev/null 2>&1; then
    alias cat='bat -pp --theme "Visual Studio Dark+"'
fi

if command -v procs >/dev/null 2>&1; then
    alias ps="procs"
fi

if command -v shellharden >/dev/null 2>&1; then
    alias shellcheck="shellharden"
fi

if command -v xh >/dev/null 2>&1; then
    alias httpie="xh"
fi

if command -v dust >/dev/null 2>&1; then
    alias du="dust"
fi

if command -v fastfetch >/dev/null 2>&1; then
    alias neofetch="fastfetch"
fi

if command -v quien >/dev/null 2>&1; then
    alias whois="quien"
fi

if command -v docker >/dev/null 2>&1; then
    alias dc='docker compose'
    alias dce='docker compose exec'
    alias dcr='docker compose run --rm'
    alias dcrn='docker compose run --no-deps --rm'
    alias dcu='docker compose up --detach'
fi

if command -v ssh >/dev/null 2>&1; then
    alias sshp='ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no'
fi

if command -v cursor >/dev/null 2>&1; then
    alias code=$(command -v cursor)
fi

if command -v pwgen >/dev/null 2>&1; then
    function pw() {
        local copy="cat"

        if command -v pbcopy >/dev/null 2>&1; then
            copy="pbcopy"
        elif command -v xclip >/dev/null 2>&1; then
            copy="xclip"
        fi

        local length="${1:-48}"
        pwgen -sync "$length" -1 | $copy
    }
fi

function distro() {
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        echo "$PRETTY_NAME"
    elif [[ "$(uname -s)" == "Darwin" ]]; then
        echo "$(sw_vers -productName) $(sw_vers -productVersion)"
    else
        uname -s
    fi
}

function weather() {
    local location="${(j::)@}"
    local url="https://wttr.in/${location}?format=2"
    curl "$url"
}

if ! command -v networkQuality >/dev/null 2>&1; then
    function networkQuality() {
        echo "Sir, this is $(distro)"
    }
fi
