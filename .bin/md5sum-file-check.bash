#!/bin/bash

usage(){
  echo "Usage: ./md5sum-file-check.bash [FILENAME] [MD5SUM]"
  exit $1
}
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
  exit 0
}
if [ -z $1 ]; then
  usage 1
fi
if [ -z $2 ]; then
  usage 2
fi
run $1 $2
