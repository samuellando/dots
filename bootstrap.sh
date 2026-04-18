dots=${1:-./.}
home=${2:-~}
# Symlink all the config files
mkdir -p ${home}/.config
for d in $(ls ${dots}/config); do
    [ -e ${home}/.config/$d ] || ln -s ${dots}/config/$d ${home}/.config/$d
done
# Symlink all the user scripts
[ -e ${home}/bin ] || ln -s ${dots}/bin ${home}/bin
# Symlink home dir dot files
[ -e ${home}/.zshenv ] || ln -s ${dots}/.zshenv ${home}/.zshenv
[ -e ${home}/.fishrc.fish ] || cp ${dots}/.fishrc.fish ${home}/.fishrc.fish
[ -e ${home}/.anacrontab ] || cp ${dots}/.anacrontab ${home}/.anacrontab
