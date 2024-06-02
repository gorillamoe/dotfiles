#!/usr/bin/env bash

# if you don't want to lock the screen when the screen turns off,
# set DISABLE_LOCK_SCREEN to any value
# Example: DISABLE_LOCK_SCREEN=1 screenoff.sh

DISABLE_LOCK_SCREEN=${DISABLE_LOCK_SCREEN:-}

main() {
  # If no sound is playing, turn off the screen
  if [ "$(grep -r 'RUNNING' /proc/asound | wc -l)" -eq 0 ]; then
    if [ -z "$DISABLE_LOCK_SCREEN" ]; then
      betterlockscreen --lock | xset dpms force off
    else
      xset dpms force off
    fi
  fi
}

main "$@"
