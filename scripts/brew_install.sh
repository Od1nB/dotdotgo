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
	k9s \
	kubectl

brew tap hashicorp/tap
brew install hashicorp/tap/terraform
