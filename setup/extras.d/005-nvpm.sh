#!/usr/bin/env bash

# nvpm release tag to install
NVPM_RELEASE_TAG="v2.4.0"

# Install nvpm for LSP and Linter management
echo "📦 Installing nvpm for LSP and Linter management"
if [ -f "$HOME/.local/bin/nvpm" ]; then
  echo "📦 nvpm already installed"
  echo "💡 Skipping nvpm installation"
else
  wget "https://github.com/mistweaverco/nvpm-client/releases/download/$NVPM_RELEASE_TAG/nvpm-linux-amd64"
  chmod +x nvpm-linux-amd64
  mv nvpm-linux-amd64 "$HOME/.local/bin/nvpm"
fi
