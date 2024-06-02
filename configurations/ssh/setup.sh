#!/usr/bin/env bash

SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -d "$HOME/.ssh" ]; then
  echo "$HOME/.ssh does not exist, creating..."
  mkdir "$HOME/.ssh"
fi

if [ -f "$HOME/.ssh/config" ]; then
  echo "$HOME/.ssh/config already exists. Skipping..."
  exit 0
fi

ln -s "$SCRIPT_PATH/.ssh/config" "$HOME/.ssh"
