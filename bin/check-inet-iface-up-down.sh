#!/bin/bash
IFACE="enp3s0"
INTERVAL=10

if [ ! -z $1 ]; then IFACE=$1; fi
if [ ! -z $2 ]; then INTERVAL=$2; fi

echo "Starting check for $IFACE; checking every $INTERVAL seconds if internet is up."

while ( true ); do
  wget -q --spider http://google.com

  if [ $? -ne 0 ]; then
    echo ""
    echo -e "Internet \e[31mis down.\e[39m Resetting iface now..."
    sudo ip link set $IFACE down && sudo ip link set enp3s0 up
    echo ""
  else
    echo -ne "."
  fi
  sleep $INTERVAL
done
