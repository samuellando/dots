###########
# STARTUP #
###########
# Add user scripts to the PATH.
if [[ $OSTYPE == "darwin"* ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
export PATH="$HOME/bin:/usr/local/bin:$PATH"

HISTFILE=~/.zhistory
HISTSIZE=SAVEHIST=10000
export EDITOR=nvim
export VISUAL=nvim

# If not running interactively, don't do anything
[[ $- != *i* ]] && return
alias ls="ls --color=auto"
alias neofetch="echo""; neofetch"
alias clear="clear; neofetch"
neofetch

###########
# ALIASES #
###########
# Built in

###########
# PROMPTS #
###########

# Default PS1='[\u@\h \W]\$ '

# Custom
setopt PROMPT_SUBST
autoload -U colors && colors

if [[ $OSTYPE == "darwin"* ]]; then
    basecolor="%b%{$fg[blue]%}"
else
    basecolor="%b%{$fg[magenta]%}"
fi

passcolor="%{$fg[green]%}"
failcolor="%{$fg[red]%}"

directory="$basecolor%1~"
result="%(?.$passcolor ^_^.$failcolor O_O)"
git=$(git branch)
prmpt="$basecolor$%b"

PS1=" $directory$result $prmpt "

# Load aliases and shortcuts if existent.

autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit

# Include hidden files in autocomplete:
_comp_options+=(globdots)

# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v

export KEYTIMEOUT=1

# Change cursor shape for different vi modes.
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
    [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'

  elif [[ ${KEYMAP} == main ]] ||
    [[ ${KEYMAP} == viins ]] ||
    [[ ${KEYMAP} = '' ]] ||
    [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'
  fi
}

zle -N zle-keymap-select

zle-line-init() {
  zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
  echo -ne "\e[5 q"
}

zle -N zle-line-init

# Use beam shape cursor on startup.
echo -ne '\e[5 q'

# Use beam shape cursor for each new prompt.
preexec() { echo -ne '\e[5 q' ;}

alias gti=git

alias vim=nvim
alias cvim='docker run -ti  --rm --name nvim --mount source=jeppesen-migration-work,target=/migration-work --mount source=jeppesen-work,target=/work --mount type=bind,source=/Users/samuel.lando/Documents,target=/root/Documents mydevzsh'
alias tmux='tmux -u'
