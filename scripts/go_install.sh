#!/usr/bin/env sh
set -eu

DEPS="
golang.org/x/tools/gopls@latest
mvdan.cc/sh/v3/cmd/shfmt@latest 
honnef.co/go/tools/cmd/staticcheck@latest
github.com/golangci/golangci-lint/v2/cmd/golangci-lint@v2.11.4
"

for pkg in $DEPS; do
	if ! go install "$pkg"; then
		echo "failed to install $pkg"
		exit 1
	fi
done

echo "installed go deps"
