#!/bin/bash
set -euo pipefail

# Script for grabbing the audio of youtube videos as mp3.
# -------------------------------------------------------
#
# Example:
# 
# yt2mp3.sh https://www.youtube.com/watch?v=KdV5J6WzFJQ

command_exists() {
        if [[ $(command -v "$1" >/dev/null 2>&1) ]]; then
                echo 1
        else
                echo 0
        fi
}

main() {
        if [[ $(command_exists "youtube-dl") == 1 ]]; then
                youtube-dl --extract-audio --audio-format mp3 "$1"
        else
                echo "youtube-dl is not installed, but required."
        fi
}

main "$1"

