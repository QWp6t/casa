#!/usr/bin/env bash
set -euo pipefail

managed="$1"
target="$2"

mkdir -p "$(dirname "$target")"

# Replace legacy symlinks with a writable settings file.
[ -L "$target" ] && rm -f "$target"

work="$(mktemp -d)"
staged="$(dirname "$target")/.settings.json.staged.$$"
trap 'rm -rf "$work"; rm -f "$staged"' EXIT

existing="$work/existing.json"
if [ -e "$target" ]; then
  if jq -e . "$target" > /dev/null 2>&1; then
    cp "$target" "$existing"
  else
    backup="$target.broken-$(date +%Y%m%d-%H%M%S)"
    mv "$target" "$backup"
    echo "{}" > "$existing"
    echo "install-settings: backed up malformed settings to $backup" >&2
  fi
else
  echo "{}" > "$existing"
fi

# Repo values win conflicts. Objects merge recursively; arrays replace.
jq -s '.[0] * .[1]' "$existing" "$managed" > "$staged"
chmod 644 "$staged"
mv "$staged" "$target"
