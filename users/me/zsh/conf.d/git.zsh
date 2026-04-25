if ! grep -qi microsoft /proc/version 2>/dev/null; then
    if command -v ssh-agent-op >/dev/null 2>&1; then
        eval "$(ssh-agent-op shell-init)"
    fi
fi

export GH_TELEMETRY=false
export DO_NOT_TRACK=true
