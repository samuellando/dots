###########
# STARTUP #
###########
# Add user scripts to the PATH.
export PATH=~/bin:$PATH

HISTFILE=~/.zhistory
HISTSIZE=SAVEHIST=10000
setopt sharehistory
setopt extendedhistory

#Startx Automatically
if [[ -z "$DISPLAY" ]] && [[ $(tty) = /dev/tty1 ]]; then
	 startx
 logout
fi

if [[ -z "$DISPLAY" ]] && [[ $(tty) = /dev/tty2 ]]; then
startx /home/sam/.xinitrc2
logout
fi

# If not running interactively, don't do anything
[[ $- != *i* ]] && return
alias ls="ls --color=auto"
alias pfetch='echo ""; pfetch'
pfetch

###########
# ALIASES #
###########

# Built in
alias clear='clear; pfetch'

# Command shortcuts.
alias trans_start='transmission-daemon -x /tmp/trans_pid --auth --username arch --password linux --port 1024 --allowed "127.0.0.1"; echo "localhost:1024"'
alias trans_stop='kill $(cat /tmp/trans_pid)'
alias red='redshift -O 2500k -P'
alias blue='redshift -x'
alias nexus="ssh sam@samuellando.com"
alias stc="curl -k --data 'fw_username=STC219&fw_password=pehylvirg&fw_domain=Firebox-DB&submit=Login&action=fw_logon&fw_logon_type=logon&redirect=https%3A%2F%2Fstcathys.com%2F&lang=en-US' 'https://10.0.1.1:4100/wgcgi.cgi'"
alias pingloop="ping www.samuellando.com"         

###########
# PROMPTS #
###########

# Default PS1='[\u@\h \W]\$ '

# Custom
autoload -U colors && colors
PS1="%B%{$fg[magenta]%}%1~" # Display the directory
PS1="$PS1%(?.%{$fg[green]%} ^_^.$fg[red]%} O_O) " # Display smiley face if all is good
PS1="$PS1%{$fg[magenta]%}$%b "   # Display the prompt symbol

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
