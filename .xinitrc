#!/bin/bash

case $1 in
    i3)
        xbindkeys
        volnoti
        xmodmap -e 'clear Lock' -e 'keycode 0x42 = Escape'
        sh ~/.fehbg &
        exec i3
        ;;
    *)
        xbindkeys
        xmodmap -e 'clear Lock' -e 'keycode 0x42 = Escape'
        exec $1
        ;;
esac
