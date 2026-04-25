set dotenv-load

op_account := env_var("OP_ACCOUNT")
op_key_uri := env_var("OP_KEY_URI")
op_bin := env_var_or_default("OP_BIN", 'op.exe')

default:
    @{{just_executable()}} --list

switch system='':
    #!/usr/bin/env bash
    set -euo pipefail

    target="{{system}}"

    if [ -z "$target" ]; then
        if [ "$(uname -s)" = "Darwin" ]; then
            target="mac"
        elif grep -qi microsoft /proc/version 2>/dev/null; then
            target="wsl"
        else
            echo "Could not detect system. Use: just switch <system>" >&2
            exit 1
        fi
    fi

    case "$target" in
        wsl) {{just_executable()}} _switch-wsl ;;
        mac) {{just_executable()}} _switch-mac ;;
        *)
            echo "Unknown system: $target" >&2
            echo "Valid systems: wsl, mac" >&2
            exit 1
            ;;
    esac

_switch-wsl:
    #!/usr/bin/env bash
    set -euo pipefail
    log="$(mktemp)"
    trap 'rm -f "$log"; {{just_executable()}} lock' EXIT
    {{just_executable()}} unlock
    set +e
    sudo nixos-rebuild switch --flake .#wsl 2>&1 | tee "$log"
    rc=${PIPESTATUS[0]}
    set -e

    if [ "$rc" -eq 0 ]; then
        exit 0
    fi

    if [ "$rc" -eq 4 ] \
        && grep -Fq 'reloading user units for nixos...' "$log" \
        && grep -Fq 'warning: user activation for nixos failed' "$log" \
        && (
            grep -Fq '/run/user/1000/bus' "$log" \
            || grep -Fq 'Unable to autolaunch a dbus-daemon without a $DISPLAY for X11' "$log" \
            || grep -Fq 'Failed to open dbus connection' "$log"
        ); then
        echo 'warning: ignoring WSL user-session activation failure; system switch completed but the per-user systemd bus is unavailable' >&2
        exit 0
    fi

    exit "$rc"

_switch-mac:
    sudo darwin-rebuild switch --flake .#mac

unlock:
    #!/usr/bin/env bash
    set -euo pipefail
    tmp="$(mktemp)"
    trap 'rm -f "$tmp"' EXIT
    sudo mkdir -p /run/age
    cd /mnt/c
    "{{op_bin}}" --account "{{op_account}}" read "{{op_key_uri}}" \
      | tr -d '\r' > "$tmp"
    test -s "$tmp"
    sudo tee /run/age/keys.txt < "$tmp" > /dev/null
    sudo chmod 600 /run/age/keys.txt

lock:
    sudo shred -u /run/age/keys.txt 2>/dev/null || true

update input='':
    #!/usr/bin/env bash
    set -euo pipefail

    if [ -n "{{input}}" ]; then
        nix flake update --update-input "{{input}}"
    else
        nix flake update
    fi

check:
    nix flake check --accept-flake-config

fmt:
    nix fmt

build-all:
    nix build .#nixosConfigurations.wsl.config.system.build.toplevel --no-link
    nix build .#darwinConfigurations.mac.system --no-link
