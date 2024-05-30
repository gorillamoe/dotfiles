#!/usr/bin/env bash

# Get the current layout
layout=$(setxkbmap -query | grep layout | awk '{print $2}')

# Add more layouts if you need
if [ "$layout" = "us,de" ]; then
  setxkbmap -layout de,us
  setxkbmap -option 'grp:alt_shift_toggle'
elif [ "$layout" = "de,us" ]; then
  setxkbmap -layout us,de
  setxkbmap -option 'grp:alt_shift_toggle'
else
    echo "The script does not support the layout: $layout"
fi
