#!/bin/bash

# Bash Arguments Parsing
# Use > 1 to consume two arguments per pass in the loop (e.g. each
# argument has a corresponding value to go with it).
# Use > 0 to consume one or more arguments per pass in the loop (e.g.
# some arguments don't have a corresponding value to go with it such
# as in the --default example).
# note: if this is set to > 0 the /etc/hosts part is not recognized ( may be a bug )
# See: http://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash#answer-14203146

# Default values
DEVICE="enp3s0"
INTERVAL=10

# Overrides
while [[ $# > 1 ]]; do
  key="$1"

  case $key in
    -d|--device)
    DEVICE="$2"
    shift
    ;;
    -i|--interval)
    INTERVAL="$2"
    shift
    ;;
    --default)
    DEFAULT=YES
    ;;
    *)
      # unknown option
    ;;
  esac
  shift
done

echo -e "\nStarting check for \e[1m$DEVICE\e[0m.\nChecking every \e[1m$INTERVAL\e[0m seconds if internet is up."

while ( true ); do

  wget -q --spider "https://www.google.com/"

  if [ $? -ne 0 ]; then

    echo -e "\n\e[1m" $(date) "\e[0mInternet \e[31mis down\e[39m. Resetting $DEVICE now...\n"
    sudo ip link set $DEVICE down && sudo ip link set $DEVICE up

  fi

  sleep $INTERVAL

done
