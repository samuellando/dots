from ubuntu:24.04

ARG USR=sam
ARG USR_PASSWD=abcd123

RUN apt update && apt install -y curl xz-utils sudo ssh zsh

RUN useradd -m -s /bin/zsh -G sudo $USR
RUN echo "$USR:$USR_PASSWD" | chpasswd

RUN mkdir /nix
RUN chown $USR /nix

USER $USR
RUN curl -sL https://nixos.org/nix/install | sh -s -- --no-daemon
RUN echo "export PATH=/home/$USR/.nix-profile/bin:$PATH" > /home/$USR/.zshrc

RUN mkdir -p "/home/$USR/.config/nix"
RUN echo "experimental-features = nix-command flakes" > /home/$USR/.config/nix/nix.conf

USER root
ENTRYPOINT service ssh start && bash
