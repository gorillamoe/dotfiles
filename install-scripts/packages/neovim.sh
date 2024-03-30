#!/usr/bin/env bash

# Neovim release tag to install
NEOVIM_RELEASE_TAG="v0.9.5"

# Download and install neovim
wget https://github.com/neovim/neovim/releases/download/$NEOVIM_RELEASE_TAG/nvim.appimage && \
  chmod +x nvim.appimage && \
  sudo mv nvim.appimage /usr/bin/nvim
