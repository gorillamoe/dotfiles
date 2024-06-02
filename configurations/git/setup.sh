#!/usr/bin/env bash

SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -f "$HOME/.gitconfig" ]; then
  echo "$HOME/.gitconfig already exists. Skipping..."
  exit 0
fi

ln -s "$SCRIPT_PATH/.gitconfig" "$HOME"
