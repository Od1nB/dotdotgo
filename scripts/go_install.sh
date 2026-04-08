#!/usr/bin/env sh
set -euo

DEPS="
mvdan.cc/sh/v3/cmd/shfmt@latest  
github.com/golangci/golangci-lint/v2/cmd/golangci-lint@v2.11.4
golang.org/x/tools/gopls@latest
"

for pkg in $DEPS; do
	if ! go install "$pkg"; then
		echo "failed to install $pkg"
		exit 1
	fi
done

echo "installed go deps"
