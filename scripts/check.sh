#!/bin/sh

set -eu

target=${1:-.}
failed=0

say_error() {
  printf 'error: %b\n' "$1" >&2
  failed=1
}

if [ ! -d "$target" ]; then
  printf 'error: target is not a directory: %s\n' "$target" >&2
  exit 2
fi

for path in \
  README.md \
  AGENTS.md \
  .gitignore \
  .env.example \
  .ai/context.md \
  .ai/decisions.md \
  .ai/tasks.md \
  .ai/prompts/README.md \
  .ai/sessions/README.md
do
  if [ ! -f "$target/$path" ]; then
    say_error "missing $path"
  fi
done

if [ -f "$target/.gitignore" ]; then
  if ! grep -Eq '^\.env$|^\.env\.\*$' "$target/.gitignore"; then
    say_error '.gitignore does not ignore .env files'
  fi
  if ! grep -Eq '^\.ai/private/$' "$target/.gitignore"; then
    say_error '.gitignore does not ignore .ai/private/'
  fi
fi

docs=$(find "$target" -type f \( -name '*.md' -o -name '.env.example' \) -not -path '*/.git/*' -print)
if [ -n "$docs" ]; then
  placeholders=$(find "$target" -type f \( -name '*.md' -o -name '.env.example' \) \
    -not -path '*/.git/*' \
    -not -path '*/.ai/sessions/README.md' \
    -not -path '*/.ai/sessions/_template.md' \
    -exec grep -IlE 'YYYY-MM-DD|Highest-priority active task|Describe what this project does' {} + 2>/dev/null || true)
  if [ -n "$placeholders" ] && [ "$(basename "$target")" != "template" ]; then
    say_error "unfinished placeholders found:\n$placeholders"
  fi

  personal_paths=$(find "$target" -type f \( -name '*.md' -o -name '.env.example' \) -not -path '*/.git/*' -exec grep -IlE '(/Users/[^/[:space:]]+|/home/[^/[:space:]]+|[A-Za-z]:\\\\Users\\\\[^\\[:space:]]+)' {} + 2>/dev/null || true)
  if [ -n "$personal_paths" ]; then
    say_error "absolute personal paths found:\n$personal_paths"
  fi

  secret_content=$(find "$target" -type f \( -name '*.md' -o -name '.env.example' \) -not -path '*/.git/*' -exec grep -IlE '(BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY|AKIA[0-9A-Z]{16}|gh[pousr]_[A-Za-z0-9]{30,}|sk-[A-Za-z0-9_-]{20,})' {} + 2>/dev/null || true)
  if [ -n "$secret_content" ]; then
    say_error "secret-shaped content found:\n$secret_content"
  fi
fi

if git -C "$target" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  tracked=$(git -C "$target" ls-files)
  dangerous=$(printf '%s\n' "$tracked" \
    | grep -Ev '(^|/)\.env\.example$' \
    | grep -E '(^|/)\.env($|\.)|\.(pem|key|p12|pfx)$|(^|/)(id_rsa|id_ed25519|\.DS_Store)$' \
    || true)
  if [ -n "$dangerous" ]; then
    say_error "potentially sensitive or machine-specific files are tracked:\n$dangerous"
  fi
fi

if [ "$failed" -ne 0 ]; then
  exit 1
fi

printf 'continuity check passed: %s\n' "$target"
