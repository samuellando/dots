# Dots

This Project contains dot file configurations for my development environment 
and my linux user environment.

the development environment uses nix, so that it can be deployed across different
OSes, and the user environment is currently just a set of dotfiles, so many things
still need to be installed with the OS. Currently this is setup on ARCH linux.


## Development environment

Install all the required packages locally using NIX.
```
nix profile add github:samuellando/dots
```

Finally install the dotfiles into your home directory with the bootstrap script:
```
bootstrap_dots
```

### Container build

If this needs to be instal a container:
```
docker build --build-arg USR=[username] --build-arg USR_PASSWD=[passwd] .
```

And then run the container
```
docker run -dt -p 2222:22 -t devbox devbox:latest 
```

You should then be able to ssh into the container with 
```
ssh 127.0.0.1 -p 2222
```

## User environment

There is still some additional manual setup required for certain things like 
backups and gpg keys, but this is enough to get up and running quickly.

### Additional stuff (optional)
1. Install the crontab from .crontab, this will enable automated backups

