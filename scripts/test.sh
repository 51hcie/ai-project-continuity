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

for path in AGENTS.md .ai/context.md .ai/decisions.md .ai/tasks.md .ai/resources.md .env.example; do
  if [ ! -f "$tmp/project/$path" ]; then
    printf 'test failed: initializer did not create %s\n' "$path" >&2
    exit 1
  fi
done

sh "$script_dir/check.sh" "$root/template" >/dev/null
sh "$script_dir/check.sh" "$root/examples/sample-project" >/dev/null

cp -R "$root/examples/sample-project" "$tmp/session-template-project"
cp "$root/template/.ai/sessions/README.md" "$tmp/session-template-project/.ai/sessions/README.md"
cp "$root/template/.ai/sessions/_template.md" "$tmp/session-template-project/.ai/sessions/_template.md"
sh "$script_dir/check.sh" "$tmp/session-template-project" >/dev/null

sh "$script_dir/install.sh" "$tmp/prefix" >/dev/null
if [ "$("$tmp/prefix/bin/apc" version)" != 'ai-project-continuity 0.5.0' ]; then
  printf 'test failed: installed command returned the wrong version\n' >&2
  exit 1
fi

mkdir -p "$tmp/archive/ai-project-continuity-main/scripts"
cp "$root/apc" "$tmp/archive/ai-project-continuity-main/apc"
cp "$root/scripts/init.sh" "$tmp/archive/ai-project-continuity-main/scripts/init.sh"
cp "$root/scripts/check.sh" "$tmp/archive/ai-project-continuity-main/scripts/check.sh"
cp "$root/scripts/install.sh" "$tmp/archive/ai-project-continuity-main/scripts/install.sh"
cp -R "$root/template" "$tmp/archive/ai-project-continuity-main/template"
tar -czf "$tmp/source.tar.gz" -C "$tmp/archive" ai-project-continuity-main
mkdir -p "$tmp/bootstrap-project"
printf '# Bootstrap fixture\n' > "$tmp/bootstrap-project/README.md"
mkdir -p "$tmp/bootstrap-tmp"
TMPDIR=$tmp/bootstrap-tmp APC_ARCHIVE_FILE=$tmp/source.tar.gz sh "$script_dir/bootstrap.sh" init "$tmp/bootstrap-project" >/dev/null
if [ ! -f "$tmp/bootstrap-project/.ai/context.md" ]; then
  printf 'test failed: bootstrap initializer did not create continuity files\n' >&2
  exit 1
fi
if [ "$(cat "$tmp/bootstrap-project/README.md")" != '# Bootstrap fixture' ]; then
  printf 'test failed: bootstrap initializer overwrote an existing file\n' >&2
  exit 1
fi
if find "$tmp/bootstrap-tmp" -mindepth 1 -print -quit | grep -q .; then
  printf 'test failed: bootstrap did not clean up its temporary source archive\n' >&2
  exit 1
fi
TMPDIR=$tmp/bootstrap-tmp APC_ARCHIVE_FILE=$tmp/source.tar.gz sh "$script_dir/bootstrap.sh" install "$tmp/bootstrap-prefix" >/dev/null
if [ "$("$tmp/bootstrap-prefix/bin/apc" version)" != 'ai-project-continuity 0.5.0' ]; then
  printf 'test failed: bootstrap installer returned the wrong version\n' >&2
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

"$tmp/prefix/bin/apc" bundle "$root/examples/sample-project" > "$tmp/bundle.md" 2> "$tmp/bundle-warning.txt"
for path in AGENTS.md .ai/context.md .ai/decisions.md .ai/tasks.md; do
  if ! grep -Fq "## \`$path\`" "$tmp/bundle.md"; then
    printf 'test failed: context bundle omitted %s\n' "$path" >&2
    exit 1
  fi
done
if ! grep -q '^warning: automated checks cannot detect every private detail' "$tmp/bundle-warning.txt"; then
  printf 'test failed: context bundle omitted the manual privacy warning\n' >&2
  exit 1
fi
if grep -q 'Review constraints' "$tmp/bundle.md" || grep -q 'APP_MODE=' "$tmp/bundle.md"; then
  printf 'test failed: context bundle included a prompt or environment contract\n' >&2
  exit 1
fi
if grep -q 'Resource availability' "$tmp/bundle.md"; then
  printf 'test failed: default context bundle included resource metadata\n' >&2
  exit 1
fi
"$tmp/prefix/bin/apc" bundle --resources "$root/examples/sample-project" > "$tmp/resource-bundle.md" 2> "$tmp/resource-warning.txt"
if ! grep -q 'resources.md' "$tmp/resource-bundle.md" || \
   ! grep -q 'resource locators may reveal internal names' "$tmp/resource-warning.txt"; then
  printf 'test failed: opt-in resource bundle did not include its warning and section\n' >&2
  exit 1
fi
"$tmp/prefix/bin/apc" bundle --minimal "$root/examples/sample-project" > "$tmp/minimal-bundle.md" 2> "$tmp/minimal-warning.txt"
for marker in '## Durable constraints' '## Current task' '## Next entry point' '## Latest session'; do
  if ! grep -Fq "$marker" "$tmp/minimal-bundle.md"; then
    printf 'test failed: minimal context bundle omitted %s\n' "$marker" >&2
    exit 1
  fi
done
if grep -q '## Decision records' "$tmp/minimal-bundle.md" || \
   grep -q 'Review constraints' "$tmp/minimal-bundle.md" || \
   grep -q 'Resource availability' "$tmp/minimal-bundle.md"; then
  printf 'test failed: minimal context bundle included history, prompts, or resources\n' >&2
  exit 1
fi
"$tmp/prefix/bin/apc" bundle --minimal --resources "$root/examples/sample-project" > "$tmp/minimal-resource-bundle.md" 2> "$tmp/minimal-resource-warning.txt"
if ! grep -q 'resources.md' "$tmp/minimal-resource-bundle.md" || \
   ! grep -q 'resource locators may reveal internal names' "$tmp/minimal-resource-warning.txt"; then
  printf 'test failed: minimal resource bundle did not include its opt-in warning and section\n' >&2
  exit 1
fi

mkdir -p "$tmp/hook-repo/.git/hooks"
printf 'existing hook content\n' > "$tmp/hook-repo/.git/hooks/pre-commit"
(CDPATH= cd -- "$tmp/hook-repo" && "$tmp/prefix/bin/apc" hook > "$tmp/generated-hook")
sh -n "$tmp/generated-hook"
if [ "$(cat "$tmp/hook-repo/.git/hooks/pre-commit")" != 'existing hook content' ]; then
  printf 'test failed: hook generator changed an existing hook\n' >&2
  exit 1
fi
if ! grep -Fq 'exec apc check "$repo_root"' "$tmp/generated-hook"; then
  printf 'test failed: generated hook did not run the continuity check\n' >&2
  exit 1
fi
"$tmp/prefix/bin/apc" hook --shell powershell > "$tmp/generated-hook.ps1"
if ! grep -Fq 'Get-Command' "$tmp/generated-hook.ps1" || \
   ! grep -Fq 'PATH used by Git' "$tmp/generated-hook.ps1"; then
  printf 'test failed: PowerShell hook did not include PATH-aware command discovery\n' >&2
  exit 1
fi
if "$tmp/prefix/bin/apc" hook --shell fish >/dev/null 2>&1; then
  printf 'test failed: hook generator accepted an unsupported shell\n' >&2
  exit 1
fi

cp -R "$root/examples/sample-project" "$tmp/stale-project"
git -C "$tmp/stale-project" init -q
git -C "$tmp/stale-project" config user.name 'APC tests'
git -C "$tmp/stale-project" config user.email 'apc-tests@example.invalid'
git -C "$tmp/stale-project" add .
git -C "$tmp/stale-project" commit -qm 'Record continuity baseline'
git -C "$tmp/stale-project" commit -qm 'First code-only change' --allow-empty
git -C "$tmp/stale-project" commit -qm 'Second code-only change' --allow-empty
"$tmp/prefix/bin/apc" check --staleness 1 "$tmp/stale-project" > "$tmp/stale-output.txt" 2> "$tmp/stale-warning.txt"
if ! grep -q 'warning: .ai/tasks.md has not changed in 2 commits' "$tmp/stale-warning.txt"; then
  printf 'test failed: stale task state did not emit the expected warning\n' >&2
  exit 1
fi
if ! grep -q '^continuity check passed:' "$tmp/stale-output.txt"; then
  printf 'test failed: a staleness warning incorrectly failed validation\n' >&2
  exit 1
fi
if "$tmp/prefix/bin/apc" check --staleness 0 "$tmp/stale-project" >/dev/null 2>&1; then
  printf 'test failed: staleness check accepted a zero threshold\n' >&2
  exit 1
fi

mkdir -p "$tmp/time-stale"
cp -R "$root/examples/sample-project/." "$tmp/time-stale/"
git -C "$tmp/time-stale" init -q
git -C "$tmp/time-stale" config user.name 'APC tests'
git -C "$tmp/time-stale" config user.email 'apc-tests@example.invalid'
git -C "$tmp/time-stale" add .
GIT_AUTHOR_DATE='2020-01-01T00:00:00Z' GIT_COMMITTER_DATE='2020-01-01T00:00:00Z' \
  git -C "$tmp/time-stale" commit -qm 'Record an old continuity baseline'
if ! "$tmp/prefix/bin/apc" check --staleness 3d "$tmp/time-stale" > "$tmp/time-stale-output.txt" 2> "$tmp/time-stale-warning.txt"; then
  printf 'test failed: time-based staleness check failed validation\n' >&2
  exit 1
fi
if ! grep -q 'has not changed in days (threshold: 3d)' "$tmp/time-stale-warning.txt"; then
  printf 'test failed: time-based staleness check did not warn\n' >&2
  exit 1
fi
if "$tmp/prefix/bin/apc" check --staleness 0d "$tmp/time-stale" >/dev/null 2>&1; then
  printf 'test failed: time-based staleness check accepted a zero threshold\n' >&2
  exit 1
fi
if "$tmp/prefix/bin/apc" check --staleness 2x "$tmp/time-stale" >/dev/null 2>&1; then
  printf 'test failed: staleness check accepted an unknown time suffix\n' >&2
  exit 1
fi

if ! grep -q '^  using: composite$' "$root/action.yml" || \
   ! grep -Fq 'APC_TARGET: ${{ inputs.target }}' "$root/action.yml" || \
   ! grep -Fq 'sh "$GITHUB_ACTION_PATH/scripts/check.sh" "$APC_TARGET"' "$root/action.yml"; then
  printf 'test failed: composite action is not wired to the repository validator\n' >&2
  exit 1
fi

if ! grep -Fq '## Active claims' "$root/template/.ai/tasks.md" || \
   ! grep -Fq 'No shared-branch claims are active.' "$root/examples/sample-project/.ai/tasks.md"; then
  printf 'test failed: concurrent task claim guidance is missing from the template or example\n' >&2
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
if "$tmp/prefix/bin/apc" bundle "$tmp/unsafe" >/dev/null 2>&1; then
  printf 'test failed: context bundle accepted secret-shaped content\n' >&2
  exit 1
fi
cp -R "$root/examples/sample-project/." "$tmp/unsafe-resource"
printf '%s\n' 'GITHUB_TOKEN=ghp_abcdefghijklmnopqrstuvwxyz1234567890' >> "$tmp/unsafe-resource/.ai/resources.md"
if sh "$script_dir/check.sh" "$tmp/unsafe-resource" >/dev/null 2>&1; then
  printf 'test failed: validator accepted secret-shaped resource metadata\n' >&2
  exit 1
fi

printf 'all tests passed\n'
