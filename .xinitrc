#!/bin/sh
eval `ssh-agent -s`

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

xrdb -merge .Xresources
exec i3
feh --bg-scale /home/walialu/Pictures/Wallpapers/14858510932_782881249f_o.jpg /usr/share/slim/themes/default/background.jpg
