#!/usr/bin/env bash

# Install fonts
echo "🔤 Installing Nerd Fonts (DepartureMono, Fira Code and Victor Mono)"
echo " - https://font.subf.dev/en/"
echo " - https://departuremono.com"
echo " - https://github.com/tonsky/FiraCode"
echo " - https://rubjo.github.io/victor-mono"
FONTS_INSTALLED=0
if [ ! -d ~/.local/share/fonts ]; then
  mkdir -p ~/.local/share/fonts
fi
if [ -f ~/.local/share/fonts/MapleMono-Regular.otf ]; then
  echo "📦 MapleMono already installed"
  echo "💡 Skipping MapleMono installation"
else
  cp -p ./configurations/fonts/maple-mono/*.otf ~/.local/share/fonts/
  FONTS_INSTALLED=1
fi
if [ -f ~/.local/share/fonts/DepartureMonoNerdFont-Regular.otf ]; then
  echo "📦 DepartureMonoNerdFont already installed"
  echo "💡 Skipping DepartureMono installation"
else
  cp -p ./configurations/fonts/departure-mono-nerd-font/*.otf ~/.local/share/fonts/
  FONTS_INSTALLED=1
fi
if [ -f ~/.local/share/fonts/FiraCodeNerdFont-Regular.ttf ]; then
  echo "📦 FiraCodeNerdFont already installed"
  echo "💡 Skipping FiraCode installation"
else
  cp -p ./configurations/fonts/fira-code-nerd-font/*.ttf ~/.local/share/fonts/
  FONTS_INSTALLED=1
fi
if [ -f ~/.local/share/fonts/VictorMonoNerdFont-Regular.ttf ]; then
  echo "📦 VictorMonoNerdFont already installed"
  echo "💡 Skipping VictorMono installation"
else
  cp -p ./configurations/fonts/victor-mono-nerd-font/*.ttf ~/.local/share/fonts/
  FONTS_INSTALLED=1
fi
if [ $FONTS_INSTALLED -eq 1 ]; then
  echo "🔤 Rebuilding font cache"
  fc-cache -f -v
fi
