#!/bin/bash

run(){
  local RED='\033[0;31m'
  local GREEN='\033[0;32m'
  local NC='\033[0m' # No Color
  local CHECKSUM=`md5sum $1 | awk '{print $1}'`
  if [ $CHECKSUM == $2 ]; then
    printf "${GREEN}[ OK ]${NC}\n"
  else
    printf "${RED}[ NOK ]${NC}\n"
  fi
}
run $1 $2
