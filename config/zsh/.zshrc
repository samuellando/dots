###########
# STARTUP #
###########
# Add user scripts to the PATH.
if [[ $OSTYPE == "darwin"* ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
  if [[ $(tty) = "/dev/tty1" ]]; then
    Hyprland
    exit
  fi
fi
export PATH="$HOME/bin:/usr/local/bin:$PATH"
export EDITOR=nvim
export VISUAL=nvim

HISTFILE=~/.zhistory
HISTSIZE=SAVEHIST=10000

# If not running interactively, don't do anything
[[ $- != *i* ]] && return
# Default to the nix shell if not already in one
if [[ $(command -v tmux) && -z $TMUX ]]; then
  exec tmux
elif command -v fish >/dev/null 2>&1; then
  exec fish
fi
