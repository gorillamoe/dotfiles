#!/usr/bin/env bash

# Randomizer
# Generates a random string of specified length using /dev/urandom
# and sha512 hashing.
# If the second argument is supplied the generated string will be
# copied to the clipboard using either pbcopy (macOS),
# wl-copy (Linux on Wayland) or xclip (Linux on X11).
# Usage: randomizer.sh [length] [copy-to-clipboard]

set -o errexit
set -o pipefail

# Default length of the random string
DEFAULT_LENGTH=32
# Get the desired length from the first argument, or use the default
LENGTH="${1:-$DEFAULT_LENGTH}"
# Validate that the length is a positive integer
if ! [[ "$LENGTH" =~ ^[1-9][0-9]*$ ]]; then
  echo " Error: Length must be a positive integer." >&2
  exit 1
fi
COPY_TO_CLIPBOARD="${2:-false}"
COPY_COMMAND=""
# Generate a random string
RANDOM_STRING=$(head -c 64 /dev/urandom | sha512sum | awk '{print $1}')
# Output the random string truncated to the desired length
# if not in interactive mode, do not add a newline at the end
TRUNCATED_STRING="${RANDOM_STRING:0:LENGTH}"
if [[ -t 1 ]]; then
  # Check if the user wants to copy the result to the clipboard
  # and if so, determine the appropriate command based on the operating system
  # and check if the required clipboard utility is available
  if [[ -t 1 ]]; then
    if [ "$COPY_TO_CLIPBOARD" = "true" ]; then
      if [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v pbcopy >/dev/null 2>&1; then
          COPY_COMMAND="pbcopy"
        else
          echo " Warning: pbcopy is not available. Please install it to use clipboard functionality on macOS." >&2
        fi
      elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v wl-copy >/dev/null 2>&1; then
          COPY_COMMAND="wl-copy"
        elif command -v xclip >/dev/null 2>&1; then
          COPY_COMMAND="xclip -selection clipboard"
        else
          echo " Warning: Neither wl-copy nor xclip is available. Please install one of them to use clipboard functionality on Linux." >&2
        fi
      else
        echo " Warning: Unsupported operating system for clipboard functionality." >&2
      fi
    fi
  fi
  # If the user requested to copy the result to the clipboard, do so
  # and print a message indicating that the string has been copied
  # to the clipboard
  if [[ $COPY_TO_CLIPBOARD != "false" ]] && [[ -n "$COPY_COMMAND" ]]; then
    echo -n "$TRUNCATED_STRING" | eval "$COPY_COMMAND"
    echo -ne " Random string copied to clipboard.\n\n"
  fi
  echo "$TRUNCATED_STRING"
else
  echo -n "$TRUNCATED_STRING"
fi

