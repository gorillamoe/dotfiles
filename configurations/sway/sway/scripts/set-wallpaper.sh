#!/usr/bin/env bash

pkill swaybg

swaybg \
    -c "#000000" \
    -i "$HOME/.config/sway/images/wallpaper.jpg" \
    -m fit \
    -o "*" &
