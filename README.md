# Dots

This Project contains dot file configurations for my development environment 
and my linux user environment.

the development environment uses nix, so that it can be deployed across different
OSes, and the user environment is currently just a set of dotfiles, so many things
still need to be installed with the OS. Currently this is setup on ARCH linux.


## Development environment

Install all the required packages locally using NIX.
```
nix profile install
```

Finally install the dotfiles into your home directory with the bootstrap script:
```
bootstrap_dots
```

## User environment

There is still some additional manual setup required for certain things like 
backups and gpg keys, but this is enough to get up and running quickly.

1. Install the crontab from .crontab, this will enable automated backups

