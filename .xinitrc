#!/bin/sh
#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)

xrdb -merge ~/.Xdefaults
eval `ssh-agent -s`
volnoti &
feh --bg-fill ~/Pictures/wallpaper.jpg

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

exec i3
