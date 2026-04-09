export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin
export GOPRIVATE="gitlab.tech.dnb.no/*"

PATH=$PATH:~/.cargo/bin/
PATH=$PATH:$GOBIN

setopt PROMPT_SUBST
PROMPT='$(prompter)'

autoload -U compinit
compinit

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
