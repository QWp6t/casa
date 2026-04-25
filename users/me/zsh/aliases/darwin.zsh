alias ls="ls -G"
alias grep="grep -G"
alias fgrep="fgrep -G"
alias egrep="egrep -G"

alias code='open -a "/Applications/Visual Studio Code.app" "$(pwd)"'
alias phpstorm='open -a /Applications/PhpStorm.app "$(pwd)"'

alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'
alias emptytrash='sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv ~/.Trash; sudo rm -rfv /private/var/log/asl/*.asl'

alias afk='osascript -e "tell application \"System Events\" to keystroke \"q\" using {command down,control down}"'

function rebuild() {
    ( cd ~/casa && just switch mac "$@" )
}
