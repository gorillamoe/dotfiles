#!/bin/sh
for file in *.mp3;
   do ffmpeg -i "${file}" -acodec libvorbis "${file/%mp3/ogg}"; 
done
