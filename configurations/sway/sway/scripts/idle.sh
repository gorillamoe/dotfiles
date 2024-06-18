#!/usr/bin/env bash

pkill swayidle

swayidle \
    timeout 300 'swaymsg "output * dpms off"' \
    resume 'swaymsg "output * dpms on"' \
    timeout 600 './suspend.sh' \
    before-sleep './lock.sh' &
