#!/bin/sh

set -eu

target=${1:-.}
failed=0
staleness_threshold=${APC_STALENESS_THRESHOLD:-}

say_error() {
  printf 'error: %b\n' "$1" >&2
  failed=1
}

say_warning() {
  printf 'warning: %b\n' "$1" >&2
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
    -not -path '*/.ai/prompts/_template.md' \
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

decisions_file=$target/.ai/decisions.md
if [ -f "$decisions_file" ]; then
  if ! grep -Eiq '^##[[:space:]]+Active([[:space:]]+decision)?[[:space:]]+(index|decisions?)[[:space:]]*$' "$decisions_file"; then
    say_warning '.ai/decisions.md has no active decision index; separate current constraints from historical records'
  fi

  missing_decision_status=$(awk '
    /^##[[:space:]]+ADR-[0-9]+:/ {
      if (in_record && !has_status) print record
      record=$0
      in_record=1
      has_status=0
      next
    }
    in_record && /^-[[:space:]]*Status:[[:space:]]*/ { has_status=1 }
    END { if (in_record && !has_status) print record }
  ' "$decisions_file")
  if [ -n "$missing_decision_status" ]; then
    say_warning "decision records missing a Status field:\n$missing_decision_status"
  fi

  inactive_index_entries=$(awk '
    BEGIN { in_active=0; current="" }
    /^##[[:space:]]+Active([[:space:]]+decision)?[[:space:]]+(index|decisions?)[[:space:]]*$/ {
      in_active=1
      next
    }
    in_active && /^##[[:space:]]+/ { in_active=0 }
    in_active && /^[[:space:]]*-[[:space:]]/ && match($0, /ADR-[0-9]+/) {
      active[substr($0, RSTART, RLENGTH)]=1
    }
    /^##[[:space:]]+ADR-[0-9]+:/ {
      match($0, /ADR-[0-9]+/)
      current=substr($0, RSTART, RLENGTH)
      next
    }
    current != "" && /^-[[:space:]]*Status:[[:space:]]*/ {
      value=$0
      sub(/^-[[:space:]]*Status:[[:space:]]*/, "", value)
      status[current]=tolower(value)
    }
    END {
      for (id in active) {
        if (status[id] != "" && status[id] != "accepted") print id " (" status[id] ")"
      }
    }
  ' "$decisions_file")
  if [ -n "$inactive_index_entries" ]; then
    say_warning "active decision index contains records that are not accepted:\n$inactive_index_entries"
  fi
fi

prompts_dir=$target/.ai/prompts
prompts_index=$prompts_dir/README.md
if [ -f "$prompts_index" ]; then
  if ! grep -Eiq '(When to use|Situation)' "$prompts_index" || \
     ! grep -Eiq 'Inputs?' "$prompts_index" || \
     ! grep -Eiq 'Expected output' "$prompts_index"; then
    say_warning '.ai/prompts/README.md does not index prompts by situation, inputs, and expected output'
  fi

  find "$prompts_dir" -type f -name '*.md' \
    ! -name 'README.md' ! -name '_template.md' -print | while IFS= read -r prompt_file
  do
    prompt_name=$(basename "$prompt_file")
    if ! grep -Fq "$prompt_name" "$prompts_index"; then
      say_warning ".ai/prompts/README.md does not reference $prompt_name"
    fi
    if ! grep -Eiq '^##[[:space:]]+(When to use|Situation)[[:space:]]*$' "$prompt_file" || \
       ! grep -Eiq '^##[[:space:]]+Inputs?[[:space:]]*$' "$prompt_file" || \
       ! grep -Eiq '^##[[:space:]]+Expected output[[:space:]]*$' "$prompt_file"; then
      say_warning "$prompt_file is missing a situation, inputs, or expected output heading"
    fi
  done
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

if [ -n "$staleness_threshold" ]; then
  case $staleness_threshold in
    *[!0-9]*|0)
      printf 'error: APC_STALENESS_THRESHOLD must be a positive integer\n' >&2
      exit 2
      ;;
  esac

  if git -C "$target" rev-parse --verify HEAD >/dev/null 2>&1; then
    tasks_revision=$(git -C "$target" log -1 --format=%H -- .ai/tasks.md 2>/dev/null || true)
    if [ -n "$tasks_revision" ]; then
      commits_since_tasks=$(git -C "$target" rev-list --count "$tasks_revision..HEAD")
      if [ "$commits_since_tasks" -gt "$staleness_threshold" ]; then
        printf 'warning: .ai/tasks.md has not changed in %s commits (threshold: %s); review whether the handoff is stale\n' \
          "$commits_since_tasks" "$staleness_threshold" >&2
      fi
    fi
  fi
fi

printf 'continuity check passed: %s\n' "$target"
