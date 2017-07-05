#!/bin/bash
set -euo pipefail

# Script for grabbing the audio of youtube videos as mp3.
# -------------------------------------------------------
#
# Example:
# 
# yt2mp3.sh https://www.youtube.com/watch?v=KdV5J6WzFJQ

main() {
  address="$1"
  filename=$(youtube-dl --get-filename "$address")

  if youtube-dl "$address"; then
    ffmpeg -i "$filename" "$filename".mp3
  else
    echo Fehler: Es konnte keine mp3-Datei erstellt werden.
  fi
}

main "$1"

