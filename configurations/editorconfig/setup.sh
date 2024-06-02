#!/usr/bin/env bash

SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -f "$HOME/.editorconfig" ]; then
  echo "$HOME/.editorconfig already exists. Skipping..."
  exit 0
fi

ln -s "$SCRIPT_PATH/.editorconfig" "$HOME"
