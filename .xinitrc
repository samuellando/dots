# Depending on if the laptop is docked or not.
undock

export AWT_TOOLKIT=MToolkit
wmname compiz

source ~/.env

sxhkd &
udiskie &
dunst &
picom &

bspwm
