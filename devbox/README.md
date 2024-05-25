# DevBox

Devbox is a preconfigured tmux+nvim development environment in a box.

It automatically pulls in, and links to the dot files from the host system.

## Starting

Start up the box as follows
```sh
./build
./run [Additional mount points for docker]
```

## Connecting

Simply run
```sh
ssh sam@localhost -p 2222 -t tmux
```

## Box specific tmixer projects

The tmixer script reads projects from the `~/.tmixer-projects.json` file in
additon to `~/.config/projects.json` and any folder in `~/Projects`.

At a box level, you can add a `~/.tmixer-projects.json` file and add any project
specific to the work station.

Refer to the `~/.config/tmixer` file for format.
