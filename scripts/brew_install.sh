#!/usr/bin/env sh

brew install \
	llvm \
	gcc \
	lld \
	go \
	fzf \
	opa \
	regal \
	rust \
	bat \
	taplo \
	tombi \
	git \
	python \
	gh \
	zig \
	zls \
	ghostty \
	tree \
	docker \
	markdown-oxide \
	gh \
	btop \
	zsh-autosuggestions \
	shellcheck \
	awscli \
	terraform-ls \
	bash-language-server \
	yaml-language-server \
	sqlite \
	postgresql@18 \
	ruff \
	k9s \
	kubectl

brew tap hashicorp/tap
brew install hashicorp/tap/terraform
