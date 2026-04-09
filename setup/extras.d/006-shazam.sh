#!/usr/bin/env bash

# Shazam release tag to install
SHAZAM_RELEASE_TAG="v1.0.0"

# Install shazam.sh and symlink dotfiles
echo "📦 Installing shazam.sh for dotfiles management"
if [ -f /usr/bin/shazam ]; then
  echo "📦 shazam.sh already installed"
  echo "💡 Skipping shazam.sh installation"
else
  wget "https://github.com/mistweaverco/shazam.sh/releases/download/$SHAZAM_RELEASE_TAG/shazam-linux"
  chmod +x shazam-linux
  mv shazam-linux "$HOME/.local/bin/shazam"
  # Symlink dotfiles
  echo "🔗 Symlinking dotfiles using shazam.sh"
  "$HOME/.local/bin/shazam"
fi
