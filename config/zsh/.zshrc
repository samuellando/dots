###########
# STARTUP #
###########
export PATH="$HOME/.nix-profile/bin:$HOME/bin:/usr/local/bin:$HOME/go/bin:$PATH"

if [[ $OSTYPE == "darwin"* ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  if [[ $(tty) = "/dev/tty1" ]]; then
    exec sway
    exit
  fi
fi

export EDITOR=nvim
export VISUAL=nvim

HISTFILE=~/.zhistory
HISTSIZE=SAVEHIST=10000

# If not running interactively, don't do anything
[[ $- != *i* ]] && return
if [[ $(command -v tmux) && -z $TMUX ]]; then
    exec tmixer start
elif command -v fish >/dev/null 2>&1; then
    exec fish
fi
