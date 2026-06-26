#!/usr/bin/env bash

print_color() {
  if [ "$#" -lt 2 ]; then
    echo "Error: print_color requires at least two arguments (text... color)" >&2
    return 1
  fi

  local color="${!#}"
  local color_code=""
  local reset="\033[0m"

  case "${color,,}" in
    black)   color_code="\033[0;30m" ;;
    red)     color_code="\033[0;31m" ;;
    green)   color_code="\033[0;32m" ;;
    yellow)  color_code="\033[0;33m" ;;
    blue)    color_code="\033[0;34m" ;;
    magenta) color_code="\033[0;35m" ;;
    cyan)    color_code="\033[0;36m" ;;
    white)   color_code="\033[0;37m" ;;
    *)       color_code="" ;;
  esac


  if [ -n "$color_code" ]; then
    printf "${color_code}%s${reset}\n" "${@:1:$#-1}"
  else
    printf "%s\n" "${@:1:$#-1}"
  fi
}
