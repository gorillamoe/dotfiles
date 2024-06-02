#!/usr/bin/env bash

SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -d "$HOME/.tmux" ]; then
  echo "$HOME/.tmux already exists. Skipping..."
  exit 0
fi

if [ -f "$HOME/.tmux.conf" ]; then
  echo "$HOME/.tmux.conf already exists. Skipping..."
  exit 0
fi

ln -s "$SCRIPT_PATH/.tmux" "$HOME"
ln -s "$SCRIPT_PATH/.tmux.conf" "$HOME"
