FROM ubuntu

ENV USR=sam

RUN useradd -m $USR -G sudo -s /bin/zsh

WORKDIR /devbox
COPY dots ./dots

RUN dots/devbox/bootstrap $USR

RUN echo "sam:abcd123" | chpasswd
RUN sudo -u $USR echo "export ZDOTDIR=/home/$USR/Projects/dots/config/zsh" >> /home/$USR/.zshenv
RUN sudo -u $USR echo "export PATH=/home/$USR/bin:$PATH" >> /home/$USR/.zshenv

EXPOSE 22
ENTRYPOINT service ssh start && bash
