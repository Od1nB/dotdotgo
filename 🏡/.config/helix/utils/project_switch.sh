#!/usr/bin/env bash
set -euo pipefail

# DOTFILES_DIR="$HOME/.dotfiles"
PROJECT_ROOTS=("$HOME/gitlab" "$HOME/github")
FD_EXCLUDES=("go")

TMP="${XDG_RUNTIME_DIR:-/tmp}/helix-selected-project"

FD_ARGS=()
for ex in "${FD_EXCLUDES[@]}"; do
	FD_ARGS+=(--exclude "$ex")
done

if [ -f "$TMP" ]; then
	cat "$TMP"
	rm -f "$TMP"
	exit 0
fi

if [ "${1-}" = "show-picker" ]; then
	dir="$({
		# printf '%s\n' "$DOTFILES_DIR"
		fd --type d --max-depth 1 "${FD_ARGS[@]}" . "${PROJECT_ROOTS[@]}"
	} | fzf)" || exit 1

	printf '%s' "$dir" >"$TMP"
	printf '%s' "$dir"
fi
