#!/usr/bin/env sh
set -e

has_cargo() {
	if ! command -v cargo >/dev/null 2>&1; then
		echo "cargo is not installed. cant install helix"
		return 1
	fi
}

readonly HELIX_DIR="$HOME/github/helix"

has_repo() {
	if [ -d "$HELIX_DIR" ]; then
		return 0
	fi
	echo "missing helix repo locally"
	return 1
}

install_cmd() {
	cargo install \
		--profile opt \
		--config 'build.rustflags="-C target-cpu=native"' \
		--path helix-term \
		--locked
}

has_cargo
has_repo
(
	cd "$HELIX_DIR" || exit
	install_cmd
	cp -r ./runtime ~/.config/helix/runtime
)

echo "helix installed and runtime copied"
