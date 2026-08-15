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

cp -R "$root/examples/sample-project" "$tmp/decision-warning-project"
sed '/^## Active decision index$/d; /^- Status: proposed$/d' \
  "$tmp/decision-warning-project/.ai/decisions.md" > "$tmp/decisions-without-status.md"
mv "$tmp/decisions-without-status.md" "$tmp/decision-warning-project/.ai/decisions.md"
sh "$script_dir/check.sh" "$tmp/decision-warning-project" \
  > "$tmp/decision-warning-output.txt" 2> "$tmp/decision-warning.txt"
if ! grep -q 'warning: .ai/decisions.md has no active decision index' "$tmp/decision-warning.txt" || \
   ! grep -q 'warning: decision records missing a Status field' "$tmp/decision-warning.txt"; then
  printf 'test failed: malformed decision records did not emit structural warnings\n' >&2
  exit 1
fi
if ! grep -q '^continuity check passed:' "$tmp/decision-warning-output.txt"; then
  printf 'test failed: a decision structure warning incorrectly failed validation\n' >&2
  exit 1
fi

cp -R "$root/examples/sample-project" "$tmp/inactive-index-project"
awk '
  !changed && $0 == "- Status: accepted" { print "- Status: superseded"; changed=1; next }
  { print }
' "$tmp/inactive-index-project/.ai/decisions.md" > "$tmp/inactive-index-decisions.md"
mv "$tmp/inactive-index-decisions.md" "$tmp/inactive-index-project/.ai/decisions.md"
sh "$script_dir/check.sh" "$tmp/inactive-index-project" \
  > "$tmp/inactive-index-output.txt" 2> "$tmp/inactive-index-warning.txt"
if ! grep -q 'warning: active decision index contains records that are not accepted' "$tmp/inactive-index-warning.txt" || \
   ! grep -q 'ADR-001 (superseded)' "$tmp/inactive-index-warning.txt"; then
  printf 'test failed: a superseded active decision did not emit a warning\n' >&2
  exit 1
fi

cp -R "$root/examples/sample-project" "$tmp/prompt-warning-project"
printf '%s\n' \
  '# Summarize release' \
  '' \
  'Summarize the current release.' \
  > "$tmp/prompt-warning-project/.ai/prompts/summarize-release.md"
sh "$script_dir/check.sh" "$tmp/prompt-warning-project" \
  > "$tmp/prompt-warning-output.txt" 2> "$tmp/prompt-warning.txt"
if ! grep -q 'warning: .ai/prompts/README.md does not reference summarize-release.md' "$tmp/prompt-warning.txt" || \
   ! grep -q 'warning: .*summarize-release.md is missing a situation, inputs, or expected output heading' "$tmp/prompt-warning.txt"; then
  printf 'test failed: an undiscoverable malformed prompt did not emit structural warnings\n' >&2
  exit 1
fi
if ! grep -q '^continuity check passed:' "$tmp/prompt-warning-output.txt"; then
  printf 'test failed: a prompt structure warning incorrectly failed validation\n' >&2
  exit 1
fi

if ! grep -q '^  using: composite$' "$root/action.yml" || \
   ! grep -Fq 'APC_TARGET: ${{ inputs.target }}' "$root/action.yml" || \
   ! grep -Fq 'sh "$GITHUB_ACTION_PATH/scripts/check.sh" "$APC_TARGET"' "$root/action.yml"; then
  printf 'test failed: composite action is not wired to the repository validator\n' >&2
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
