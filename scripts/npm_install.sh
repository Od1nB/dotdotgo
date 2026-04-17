#!/usr/bin/env sh
set -e

has_npm() {
	if ! command -v npm >/dev/null 2>&1; then
		echo "npm is not installed. Please install node"
		return 1
	fi
}

has_npm
npm install -g \
	vscode-langservers-extracted
