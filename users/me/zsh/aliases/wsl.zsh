alias e.="explorer.exe . || true"
alias t.='wt.exe -d "$(pwd)"'

if command -v op.exe > /dev/null 2>&1; then
    alias op='op.exe'
fi

function drop_cache() {
    sudo sh -c 'sync; echo 3 >"/proc/sys/vm/drop_caches"; swapoff -a; swapon -a'
    echo "Memory freed"
}

if ! command -v xdg-open >/dev/null 2>&1; then
    function xdg-open() {
        local target win

        [ $# -ne 1 ] && return 2
        target=$1

        case $target in
            *://* )
                powershell.exe -NoProfile -Command Start-Process "$target"
            ;;
            * )
                win=$(wslpath -w -- "$target") || return
                powershell.exe -NoProfile -Command Start-Process "$win"
            ;;
        esac
    }
fi

if ! command -v open >/dev/null 2>&1; then
    alias open=xdg-open
fi

function rebuild() {
    ( cd ~/casa && just switch wsl "$@" )
}
