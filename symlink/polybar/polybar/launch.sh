#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar

# Launch i3 polybar
echo "---" | tee -a /tmp/polybar-i3.log
polybar -c "$HOME/.config/polybar/i3.ini" i3 2>&1 | tee -a /tmp/polybar-i3.log & disown

echo "Bars launched..."
