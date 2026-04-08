#!/usr/bin/env zsh

has_brew() {
  which brew >/dev/null
  if [ $? -ne 0 ]; then
    print "missing brew"
    return 1
  fi
}

has_brew
if [ $? -ne 0 ]; then
  echo "installing brew"
  ./scripts/brew_boot.sh
fi

./scripts/brew_install.sh
