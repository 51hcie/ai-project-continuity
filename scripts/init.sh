#!/bin/sh

set -eu

if [ "$#" -ne 1 ]; then
  printf 'usage: %s TARGET_DIRECTORY\n' "$0" >&2
  exit 2
fi

target=$1
script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
source_dir=$script_dir/../template

if [ ! -d "$target" ]; then
  printf 'error: target is not a directory: %s\n' "$target" >&2
  exit 2
fi

find "$source_dir" -type f | while IFS= read -r source; do
  relative=${source#"$source_dir"/}
  destination=$target/$relative
  if [ -e "$destination" ]; then
    printf 'skip:   %s already exists\n' "$relative"
    continue
  fi
  mkdir -p "$(dirname -- "$destination")"
  cp "$source" "$destination"
  printf 'create: %s\n' "$relative"
done

printf 'continuity files initialized in %s\n' "$target"
printf 'next: replace placeholders, then run: apc check %s\n' "$target"
