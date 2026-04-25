if grep -qi microsoft /proc/version 2>/dev/null; then
    # On WSL, point SSH clients at the Unix socket served by the
    # systemd-managed npiperelay/socat bridge.
    export SSH_AUTH_SOCK="${SSH_AUTH_SOCK:-$HOME/.ssh/agent.sock}"
fi
