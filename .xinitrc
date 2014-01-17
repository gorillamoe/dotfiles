#!/bin/bash

DEFAULT_SESSION="gnome"

case $1 in
    gnome)
        xbindkeys
        volnoti
        setxkbmap -option caps:escape
        exec gnome-session
        ;;
    i3)
        xbindkeys
        volnoti
        setxkbmap -option caps:escape
        sh ~/.fehbg &
        exec i3
        ;;
    *)
        xbindkeys
        exec $1
        ;;
esac
