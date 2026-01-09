# Dots

This Project contains dot file configurations for my development environment.

- The user environment
    - Arch Linux based Wayland configuration.

## Development environment

This is designed to work on Arch Linux with with nix installed

Run the bootstrapping script to setup the user home directory.
```
sh bootstrap.sh
```

Install all the required packages locally using NIX.
```
nix profile install
```

There is still some additional manual setup required for certain things like 
backuops and gpg keys, but this is enough to get up and running quickly.

## New setup checklist

TODO
