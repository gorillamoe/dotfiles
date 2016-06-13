#!/bin/bash
IFACE="enp3s0"

if [ ! -z $1 ]; then
  IFACE=$1
fi

echo "Starting check for $IFACE"

while ( true ); do
  wget -q --spider http://google.com

  if [ $? -ne 0 ]; then
    echo ""
    echo "Internet is down. Resetting iface now..."
    sudo ip link set $IFACE down && sudo ip link set enp3s0 up
    echo ""
  else
    echo -ne "."
  fi
  sleep 5
done
