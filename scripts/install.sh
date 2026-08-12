#!/bin/sh

set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
source_root=$script_dir/..
prefix=${1:-${HOME:?HOME is required when no prefix is supplied}/.local}

if [ -z "$prefix" ] || [ "$prefix" = / ]; then
  printf 'error: refusing unsafe install prefix: %s\n' "$prefix" >&2
  exit 2
fi

bin_dir=$prefix/bin
bundle_dir=$prefix/share/ai-project-continuity

if [ -e "$bin_dir/apc" ] && ! grep -q 'ai-project-continuity' "$bin_dir/apc" 2>/dev/null; then
  printf 'error: refusing to overwrite an unrelated file: %s\n' "$bin_dir/apc" >&2
  exit 2
fi

mkdir -p "$bin_dir" "$bundle_dir/scripts" "$bundle_dir/template"
cp "$source_root/apc" "$bin_dir/apc"
cp "$source_root/scripts/init.sh" "$bundle_dir/scripts/init.sh"
cp "$source_root/scripts/check.sh" "$bundle_dir/scripts/check.sh"
cp -R "$source_root/template/." "$bundle_dir/template/"
chmod 755 "$bin_dir/apc" "$bundle_dir/scripts/init.sh" "$bundle_dir/scripts/check.sh"

printf 'installed ai-project-continuity in %s\n' "$prefix"
printf 'next: add %s to PATH, then run apc help\n' "$bin_dir"
