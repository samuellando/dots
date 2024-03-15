###########
# STARTUP #
###########
# Add user scripts to the PATH.
if [[ $OSTYPE == "darwin"* ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
export PATH="~/bin:$PATH:/usr/local/bin:$PATH"

HISTFILE=~/.zhistory
HISTSIZE=SAVEHIST=10000

# If not running interactively, don't do anything
[[ $- != *i* ]] && return
alias ls="ls --color=auto"

###########
# ALIASES #
###########
# Built in

###########
# PROMPTS #
###########

# Default PS1='[\u@\h \W]\$ '

# Custom
autoload -U colors && colors
if [[ $OSTYPE == "darwin"* ]]; then
    PS1="%B%{$fg[blue]%}%1~" # Display the directory
else
    PS1="%B%{$fg[magenta]%}%1~" # Display the directory
fi
PS1="$PS1%(?.%{$fg[green]%} ^_^.$fg[red]%} O_O) " # Display smiley face if all is good
if [[ $OSTYPE == "darwin"* ]]; then
    PS1="$PS1%{$fg[blue]%}$%b "   # Display the prompt symbol
else
    PS1="$PS1%{$fg[magenta]%}$%b "   # Display the prompt symbol
fi

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
bindkey -v '^?' backward-delete-char

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
export EDITOR=nvim
alias cvim='docker run -ti  --rm --name nvim --mount source=jeppesen-migration-work,target=/migration-work --mount source=jeppesen-work,target=/work --mount type=bind,source=/Users/samuel.lando/Documents,target=/root/Documents mydevzsh'
alias tmux='tmux -u'
