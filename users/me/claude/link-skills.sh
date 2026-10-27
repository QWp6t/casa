#!/usr/bin/env bash
set -euo pipefail

source_root="$1"
target_root="$2"

if [ ! -d "$source_root" ]; then
  echo "link-skills: checkout skills directory is missing: $source_root" >&2
  exit 1
fi

mkdir -p "$target_root"
for source in "$source_root"/*; do
  [ -f "$source/SKILL.md" ] || continue
  target="$target_root/$(basename "$source")"

  if [ -L "$target" ]; then
    [ "$(readlink "$target")" = "$source" ] && continue
    rm "$target"
  elif [ -e "$target" ]; then
    echo "link-skills: move the existing skill aside first: $target" >&2
    exit 1
  fi

  ln -s "$source" "$target"
done
