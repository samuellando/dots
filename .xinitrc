# Depending on if the laptop is docked or not.
if  [[ ! -z $(xrandr --listactivemonitors | grep 'DP-3') ]]; then
  xrandr --output eDP-1 --off 
  xrandr --output DP-3 --auto --pos 0x0 --primary
  xrandr --output DP-1 --auto --pos 1920x0
else
  xrandr --output eDP-1 --auto --primary
  xrandr --output DP-3 --off
  xrandr --output DP-1 --off
fi

export AWT_TOOLKIT=MToolkit
wmname compiz

sxhkd &
udiskie &
dunst &
picom &

systemd-run --user --on-active=60 ~/bin/battery

bspwm
