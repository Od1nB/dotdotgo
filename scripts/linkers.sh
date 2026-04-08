#!/usr/bin/env sh

REPO_ROOT=$(pwd)

ln -sf "$REPO_ROOT/🏡/.gitconfig" ~/.gitconfig
ln -sf "$REPO_ROOT/🏡/.gitconfig_github" ~/.gitconfig_github
ln -sf "$REPO_ROOT/🏡/.gitconfig_gitlab" ~/.gitconfig_gitlab

ln -sf "$PWD/🏡/.zshrc" ~/.zshrc

mkdir -p "$HOME/.config"
DIRS="$REPO_ROOT/🏡/.config"

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
done
