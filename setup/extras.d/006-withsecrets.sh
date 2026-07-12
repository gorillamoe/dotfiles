#!/usr/bin/env bash

# WithSecrets release tag to install
WITHSECRETS_RELEASE_TAG="v2.1.0"

# Install WithSecrets
echo "📦 Installing WithSecrets"
if [ -f "$HOME/.local/bin/ws" ]; then
  echo "📦 WithSecrets already installed"
  echo "💡 Skipping WithSecrets installation"
else
  wget "https://github.com/mistweaverco/withsecrets/releases/download/$WITHSECRETS_RELEASE_TAG/ws-linux-amd64"
  chmod +x ws-linux-amd64
  mv ws-linux-amd64 "$HOME/.local/bin/ws"
fi
