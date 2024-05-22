###########
# STARTUP #
###########
# Add user scripts to the PATH.
if [[ $OSTYPE == "darwin"* ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
  if [[ "$(tty)" == "/dev/tty1" ]]; then
    Hyprland
  fi
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
gitcolor="%{$fg[blue]%}"

directory="$basecolor%1~"
result="%(?.$passcolor ^_^.$failcolor O_O)"
prmpt="$basecolor$"

gitinfo() {
    branch=$(git symbolic-ref HEAD 2> /dev/null | cut -c 12-)
    if [ "$branch" = "" ]; then
        return ""
    else
        ahead=$(git rev-list --left-right origin/$branch..HEAD | grep "^>" | wc -l)
        behind=$(git rev-list --left-right origin/$branch..HEAD | grep "^<" | wc -l)
        echo " $gitcolor($branch $ahead/$behind)"
    fi
}

PROMPT=" %B$directory\$(gitinfo)$result $prmpt%b "
function preexec() {
  DATE=`date +"%H:%M:%S"`
  C=$(($COLUMNS-10))
  echo -e "\033[1A\033[${C}C ${DATE} "
}

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

alias gti=git

alias vim=nvim
alias cvim='docker run -ti  --rm --name nvim --mount source=jeppesen-migration-work,target=/migration-work --mount source=jeppesen-work,target=/work --mount type=bind,source=/Users/samuel.lando/Documents,target=/root/Documents mydevzsh'
alias tmux='tmux -u'
