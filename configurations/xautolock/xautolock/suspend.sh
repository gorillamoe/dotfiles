#!/usr/bin/env bash

# if you don't want to lock the screen when the suspend script is called,
# set DISABLE_LOCK_SCREEN to any value
# Example: DISABLE_LOCK_SCREEN=1 suspend.sh

DISABLE_LOCK_SCREEN=${DISABLE_LOCK_SCREEN:-}

main() {
  # If no sound is playing, suspend the system
  if [ "$(grep -r 'RUNNING' /proc/asound | wc -l)" -eq 0 ]; then
    if [ -z "$DISABLE_LOCK_SCREEN" ]; then
      betterlockscreen --lock | systemctl suspend
    else
      systemctl suspend
    fi
  fi
}

main "$@"
