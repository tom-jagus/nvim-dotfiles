#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ./install.sh [--backup]

Create ~/.config/nvim (or $XDG_CONFIG_HOME/nvim) as a symlink to this
repository's nvim/ directory.

Options:
  --backup  Move an existing config directory or different symlink to a
            timestamped sibling backup before creating the symlink.
EOF
}

backup=false
case "${1:-}" in
  '') ;;
  --backup) backup=true ;;
  -h|--help) usage; exit 0 ;;
  *) usage >&2; exit 2 ;;
esac

repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
source_dir="$repo_root/nvim"
config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
target="$config_home/nvim"

if [[ ! -d "$source_dir" ]]; then
  printf 'Configuration directory not found: %s\n' "$source_dir" >&2
  exit 1
fi

source_real=$(readlink -f -- "$source_dir")

if [[ -L "$target" ]]; then
  target_real=$(readlink -f -- "$target" 2>/dev/null || true)
  if [[ "$target_real" == "$source_real" ]]; then
    printf 'Already installed: %s -> %s\n' "$target" "$source_real"
    exit 0
  fi
fi

if [[ -e "$target" || -L "$target" ]]; then
  if ! "$backup"; then
    printf 'Refusing to replace existing config: %s\n' "$target" >&2
    printf 'Re-run with --backup to move it aside first.\n' >&2
    exit 1
  fi

  backup_path="$target.backup.$(date +%Y%m%d%H%M%S)"
  mv -- "$target" "$backup_path"
  printf 'Backed up existing config to: %s\n' "$backup_path"
fi

mkdir -p -- "$config_home"
ln -s -- "$source_real" "$target"
printf 'Installed: %s -> %s\n' "$target" "$source_real"
