dots=${1:-./.}
# Symlink all the config files
mkdir -p ~/.config
for d in $(ls ${dots}/config); do
    [ -e ~/.config/$d ] || ln -s ${dots}/config/$d ~/.config/$d
done
# Symlink all the user scripts
[ -e ~/bin ] || ln -s ${dots}/bin ~/bin
# Symlink .zshenv to use ~/.config/zsh
[ -e ~/.zshenv ] || ln -s ${dots}/.zshenv ~/.zshenv
# Create a local user .fishrc 
[ -e ~/.fishrc.fish ] || cp ${dots}/.fishrc.fish ~/.fishrc.fish
