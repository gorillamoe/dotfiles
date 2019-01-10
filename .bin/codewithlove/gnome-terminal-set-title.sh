#!/bin/bash

if [ "x$TITLE" = "x" ]; then
  echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"
else
  echo -ne "\033]0;${TITLE}\007"
fi
