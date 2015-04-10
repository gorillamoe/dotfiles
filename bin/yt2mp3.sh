#!/bin/bash 
# Script for grabbing the audio of youtube videos as mp3. 
address=$1
bitrate=$2
default_bitrate=256
title=$(youtube-dl --get-title $address)
filename=$(youtube-dl --get-filename $address)
youtube-dl $address
if [[ $? -ge 0 ]]; then
  ffmpeg -i "$filename" "$filename".wav 
  if [[ -z $bitrate ]]; then 
    bitrate=$default_bitrate
  fi 
  lame -b $bitrate "$filename".wav "$title".mp3 
  rm "$filename" "$filename".wav 
else
  echo Fehler: Es konnte keine mp3-Datei erstellt werden.
fi
