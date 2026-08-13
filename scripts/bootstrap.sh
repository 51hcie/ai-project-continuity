#!/bin/sh

set -eu

usage() {
  cat <<'EOF'
Usage: bootstrap.sh init TARGET
       bootstrap.sh install [PREFIX]

Downloads a temporary ai-project-continuity source archive, performs the
requested non-destructive action, and removes the archive.
EOF
}

command_name=${1:-}
if [ "$#" -gt 0 ]; then
  shift
fi

case $command_name in
  init)
    if [ "$#" -ne 1 ]; then
      usage >&2
      exit 2
    fi
    ;;
  install)
    if [ "$#" -gt 1 ]; then
      usage >&2
      exit 2
    fi
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac

tmp=$(mktemp -d "${TMPDIR:-/tmp}/ai-project-continuity-bootstrap.XXXXXX")
archive=$tmp/source.tar.gz
source_dir=$tmp/source
trap 'rm -rf "$tmp"' EXIT HUP INT TERM
mkdir -p "$source_dir"

if [ -n "${APC_ARCHIVE_FILE:-}" ]; then
  cp "$APC_ARCHIVE_FILE" "$archive"
else
  if ! command -v curl >/dev/null 2>&1; then
    printf 'error: curl is required for remote bootstrap\n' >&2
    exit 2
  fi
  ref=${APC_REF:-main}
  ref_type=${APC_REF_TYPE:-heads}
  case $ref_type in
    heads|tags) ;;
    *)
      printf 'error: APC_REF_TYPE must be heads or tags\n' >&2
      exit 2
      ;;
  esac
  case $ref in
    ''|*[!A-Za-z0-9._/-]*)
      printf 'error: APC_REF contains unsupported characters\n' >&2
      exit 2
      ;;
  esac
  url=https://github.com/51hcie/ai-project-continuity/archive/refs/$ref_type/$ref.tar.gz
  curl -fsSL "$url" -o "$archive"
fi

if ! command -v tar >/dev/null 2>&1; then
  printf 'error: tar is required for remote bootstrap\n' >&2
  exit 2
fi
tar -xzf "$archive" -C "$source_dir"

source_root=
for candidate in "$source_dir"/*; do
  if [ ! -d "$candidate" ]; then
    continue
  fi
  if [ -n "$source_root" ]; then
    printf 'error: source archive contains multiple root directories\n' >&2
    exit 1
  fi
  source_root=$candidate
done
if [ -z "$source_root" ] || [ ! -f "$source_root/scripts/init.sh" ] || [ ! -d "$source_root/template" ]; then
  printf 'error: downloaded archive is not an ai-project-continuity source bundle\n' >&2
  exit 1
fi

case $command_name in
  init)
    sh "$source_root/scripts/init.sh" "$1"
    ;;
  install)
    if [ "$#" -eq 1 ]; then
      sh "$source_root/scripts/install.sh" "$1"
    else
      sh "$source_root/scripts/install.sh"
    fi
    ;;
esac
