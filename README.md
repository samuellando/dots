# Dots

This Project contains dot file configurations for my development environment.

I like to split my configuration into two parts, each with a different approach

- The development environment
    - Terminal based, TMUX + NVIM.
    - Reproducible builds using NIX.
    - Docker container as the runtime for portability.

- The user environment
    - Arch Linux based Wayland configuration.
    - Does not need the rigor and reproducibility of the development environment.

## Development environment

### Local installation

This is designed to work on Arch Linux with with nix installed

Install all the required packages locally using NIX.
```
nix-env -f env.nix -iA DevEnv
```

Run the bootstrapping script to setup the user home directory.
```
sh bootstrap.sh
```

### Devbox

Devbox packages the development environment into a docker container, which
makes it a lot easier to deploy it on other systems. Such as a work computer 
for example.

- Build the docker image
```
docker load < $(nix-build devbox.nix)
```
- Run the docker image however you want
```
docker run -it devbox:[Generated-Tag]
```
