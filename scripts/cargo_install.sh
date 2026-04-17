#!/usr/bin/env sh
set -e

has_cargo() {
	if ! command -v cargo >/dev/null 2>&1; then
		echo "cargo is not installed. Please install Rust first."
		return 1
	fi
}

has_cargo
cargo install \
	rumdl
