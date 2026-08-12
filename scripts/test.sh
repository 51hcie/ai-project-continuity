#!/bin/sh

set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
root=$script_dir/..
tmp=${TMPDIR:-/tmp}/ai-project-continuity-test-$$
trap 'rm -rf "$tmp"' EXIT HUP INT TERM

mkdir -p "$tmp/project"
printf '# Existing project\n' > "$tmp/project/README.md"

sh "$script_dir/init.sh" "$tmp/project" >/dev/null

if [ "$(cat "$tmp/project/README.md")" != '# Existing project' ]; then
  printf 'test failed: initializer overwrote an existing file\n' >&2
  exit 1
fi

for path in AGENTS.md .ai/context.md .ai/decisions.md .ai/tasks.md .env.example; do
  if [ ! -f "$tmp/project/$path" ]; then
    printf 'test failed: initializer did not create %s\n' "$path" >&2
    exit 1
  fi
done

sh "$script_dir/check.sh" "$root/template" >/dev/null
sh "$script_dir/check.sh" "$root/examples/sample-project" >/dev/null

cp -R "$root/examples/sample-project/." "$tmp/unsafe"
printf '%s\n' 'API_TOKEN=sk-abcdefghijklmnopqrstuvwxyz123456' >> "$tmp/unsafe/.ai/context.md"
if sh "$script_dir/check.sh" "$tmp/unsafe" >/dev/null 2>&1; then
  printf 'test failed: validator accepted secret-shaped content\n' >&2
  exit 1
fi

printf 'all tests passed\n'
