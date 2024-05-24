FROM archlinux

ENV TERM=xterm
ENV USER=sam
ENV ZDOTDIR=/home/$USER/.config/zsh

RUN useradd -m $USER

WORKDIR /devbox
COPY dots ./dots

RUN dots/devbox/bootstrap $USER

WORKDIR /home/$USER
CMD ["tmux"]
