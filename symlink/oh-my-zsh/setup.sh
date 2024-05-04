#!/usr/bin/env bash

SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "$HOME/.oh-my-zsh does not exist, creating..."
  mkdir "$HOME/.oh-my-zsh"
fi

if [ ! -d "$HOME/.oh-my-zsh/custom" ]; then
  echo "$HOME/.oh-my-zsh/custom does not exist, creating..."
  mkdir "$HOME/.oh-my-zsh/custom"
fi

ln -s "$SCRIPT_PATH/.oh-my-zsh/custom/aliases.zsh" "$HOME/.oh-my-zsh/custom"
