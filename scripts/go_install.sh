#!/usr/bin/env sh
set -eu

DEPS="
golang.org/x/tools/gopls@latest
mvdan.cc/sh/v3/cmd/shfmt@latest 
honnef.co/go/tools/cmd/staticcheck@latest
github.com/golangci/golangci-lint/v2/cmd/golangci-lint@v2.11.4
golang.org/x/tools/cmd/goimports@latest
github.com/go-delve/delve/cmd/dlv@latest
github.com/google/yamlfmt/cmd/yamlfmt@latest
"

for pkg in $DEPS; do
	if ! go install "$pkg"; then
		echo "failed to install $pkg"
		exit 1
	fi
done

echo "installed go deps"
