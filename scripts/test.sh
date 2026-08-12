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

sh "$script_dir/install.sh" "$tmp/prefix" >/dev/null
if [ "$("$tmp/prefix/bin/apc" version)" != 'ai-project-continuity 0.2.0' ]; then
  printf 'test failed: installed command returned the wrong version\n' >&2
  exit 1
fi

"$tmp/prefix/bin/apc" check "$root/examples/sample-project" >/dev/null
mkdir -p "$tmp/installed-project"
printf '# Installed command fixture\n' > "$tmp/installed-project/README.md"
"$tmp/prefix/bin/apc" init "$tmp/installed-project" > "$tmp/init-output.txt"
if [ "$(cat "$tmp/installed-project/README.md")" != '# Installed command fixture' ]; then
  printf 'test failed: installed initializer overwrote an existing file\n' >&2
  exit 1
fi
if ! grep -q '^next: replace placeholders, then run: apc check ' "$tmp/init-output.txt"; then
  printf 'test failed: installed initializer did not print the CLI next step\n' >&2
  exit 1
fi

"$tmp/prefix/bin/apc" report "$root/examples/sample-project" > "$tmp/report.md"
if ! grep -q '^- Status: pass$' "$tmp/report.md"; then
  printf 'test failed: conformance report did not pass\n' >&2
  exit 1
fi
if grep -Eq '(/Users/[^/[:space:]]+|/home/[^/[:space:]]+)' "$tmp/report.md"; then
  printf 'test failed: conformance report exposed a personal path\n' >&2
  exit 1
fi

if sh "$script_dir/install.sh" / >/dev/null 2>&1; then
  printf 'test failed: installer accepted the filesystem root\n' >&2
  exit 1
fi

mkdir -p "$tmp/foreign/bin"
printf '#!/bin/sh\nprintf unrelated\n' > "$tmp/foreign/bin/apc"
if sh "$script_dir/install.sh" "$tmp/foreign" >/dev/null 2>&1; then
  printf 'test failed: installer overwrote an unrelated command\n' >&2
  exit 1
fi

cp -R "$root/examples/sample-project/." "$tmp/unsafe"
printf '%s\n' 'API_TOKEN=sk-abcdefghijklmnopqrstuvwxyz123456' >> "$tmp/unsafe/.ai/context.md"
if sh "$script_dir/check.sh" "$tmp/unsafe" >/dev/null 2>&1; then
  printf 'test failed: validator accepted secret-shaped content\n' >&2
  exit 1
fi

printf 'all tests passed\n'
