#!/usr/bin/env sh

REPO_ROOT=$(pwd)

ln -sf "$REPO_ROOT/🏡/.gitconfig" ~/.gitconfig
ln -sf "$REPO_ROOT/🏡/.gitconfig_github" ~/.gitconfig_github
ln -sf "$REPO_ROOT/🏡/.gitconfig_gitlab" ~/.gitconfig_gitlab
ln -sf "$REPO_ROOT/🏡/.gitconfig_ghe" ~/.gitconfig_ghe

ln -sf "$PWD/🏡/.zshrc" ~/.zshrc

mkdir -p "$HOME/.config"
DIRS="$REPO_ROOT/🏡/.config"
OS=$(uname | tr '[:upper:]' '[:lower:]')

for dir in "$DIRS/"*; do
	[ -e "$dir" ] || continue

	name=$(basename "$dir")
	target="$HOME/.config/$name"

	rm -rf "$target"

	# -s: symbolic link
	# -f: overwrite other syms
	# -n: prevents nesting
	ln -sfn "$dir" "$target"
	echo "symlinked: $name"

	# Per-OS variants: any `<file>.$OS` gets a `<file>` symlink beside it.
	# ghostty's config.darwin becomes config etc.
	for variant in "$dir"/*."${OS}"; do
		[ -e "$variant" ] || continue

		base=$(basename "${variant%".${OS}"}")
		ln -sfn "$variant" "$target/$base"
		echo "  os variant: $base -> $(basename "$variant")"
	done
done
