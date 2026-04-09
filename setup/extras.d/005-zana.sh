#!/usr/bin/env bash

# Zana release tag to install
ZANA_RELEASE_TAG="v1.7.1"

# Install zana for LSP and Linter management
echo "📦 Installing Zana for LSP and Linter management"
if [ -f "$HOME/.local/bin/zana" ]; then
  echo "📦 Zana already installed"
  echo "💡 Skipping Zana installation"
else
  wget "https://github.com/mistweaverco/zana-client/releases/download/$ZANA_RELEASE_TAG/zana-linux-amd64"
  chmod +x zana-linux-amd64
  mv zana-linux-amd64 "$HOME/.local/bin/zana"
fi
