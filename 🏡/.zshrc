export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin
export GOPRIVATE="gitlab.tech.dnb.no/*,dnb.ghe.com/*"

PATH=$PATH:~/.cargo/bin/
PATH=$PATH:$GOBIN
PATH=$PATH:~/.local/bin

setopt PROMPT_SUBST
PROMPT='$(prompter)'

autoload -U compinit
compinit
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'l:|=* r:|=*'

setopt APPEND_HISTORY
setopt SHARE_HISTORY
HISTFILE=$HOME/.zsh_history
SAVEHIST=10000
HISTSIZE=10000
setopt HIST_EXPIRE_DUPS_FIRST
setopt EXTENDED_HISTORY

source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
source <(fzf --zsh)

bindkey '\e[A' history-search-backward
bindkey '\e[B' history-search-forward
bindkey '^[[1;3D' backward-word # Alt+Left
bindkey '^[[1;3C' forward-word  # Alt+Right

alias week="date +%V"
alias ls="ls -G"
export WELL_KNOWN=".well-known/openid-configuration"

has_gum() {
	if ! gum --version >/dev/null; then
		print "missing ${PINK}Gum${RESET}!!? run: \
		\n${ITALICS}\`go install github.com/charmbracelet/gum@latest\`${NORMAL} or\
		\n${ITALICS}\`brew install gum\`${NORMAL}\n" >&2
		return 1
	fi
}

alias python=python3
