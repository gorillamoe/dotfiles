#!/usr/bin/env bash

SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -d "$HOME/.config" ]; then
  echo "$HOME/.config does not exist, creating..."
  mkdir "$HOME/.config"
fi

if [ -d "$HOME/.config/kitty" ] || [ -L "$HOME/.config/kitty" ]; then
  echo "$HOME/.config/kitty already exists. Skipping..."
  exit 0
fi

ln -s "$SCRIPT_PATH/kitty" "$HOME/.config"
