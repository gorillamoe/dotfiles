#!/usr/bin/env bash

# Install fonts
echo "🔤 Installing Nerd Fonts (Fira Code and Victor Mono)"
FONTS_INSTALLED=0
if [ ! -d ~/.local/share/fonts ]; then
  mkdir -p ~/.local/share/fonts
fi
if [ -f ~/.local/share/fonts/FiraCodeNerdFont-Regular.ttf ]; then
  echo "📦 FiraCodeNerdFont already installed"
  echo "💡 Skipping FiraCode installation"
else
  cp -p ./configurations/fonts/fira-code-nerd-font/* ~/.local/share/fonts/
  rm ~/.local/share/fonts/*.md
  rm ~/.local/share/fonts/LICENSE*
  FONTS_INSTALLED=1
fi
if [ -f ~/.local/share/fonts/VictorMonoNerdFont-Regular.ttf ]; then
  echo "📦 VictorMonoNerdFont already installed"
  echo "💡 Skipping VictorMono installation"
else
  cp -p ./configurations/fonts/victor-mono-nerd-font/* ~/.local/share/fonts/
  rm ~/.local/share/fonts/*.md
  rm ~/.local/share/fonts/LICENSE*
  FONTS_INSTALLED=1
fi
if [ $FONTS_INSTALLED -eq 1 ]; then
  echo "🔤 Rebuilding font cache"
  fc-cache -f -v
fi
