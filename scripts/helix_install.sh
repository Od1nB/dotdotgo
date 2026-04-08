#!/usr/bin/env sh

readonly HELIX_DIR="$HOME/github/helix"

has_repo() {
  if [ -d "$HELIX_DIR" ]; then
    return 0
  fi
  return 1
}

if ! has_repo
then
   echo "missing helix repo locally"
   exit 1
fi

install_cmd() {
    cargo install \
   --profile opt \
   --config 'build.rustflags="-C target-cpu=native"' \
   --path helix-term \
   --locked
}
(
  cd "$HELIX_DIR" || exit

  if ! install_cmd
  then
    exit 1
  fi

  cp -r ./runtime ~/.config/helix/runtime
)

echo "helix installed and runtime copied"
