export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin
export GOPRIVATE=gitlab.tech.dnb.no/*

PATH=$PATH:~/.cargo/bin/
PATH=$PATH:$GOBIN

setopt PROMPT_SUBST
PROMPT='$(prompter)'

