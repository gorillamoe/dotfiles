#!/usr/bin/env bash

# Install rustup
if [ -d ~/.cargo ]; then
  echo "📦 rustup already installed"
  echo "💡 Skipping rustup installation"
else
  echo "📦 Installing rustup (Rust toolchain manager)"
  if command -v rust &>/dev/null; then
    echo "📦 Rust already installed"
    echo "💡 Removing existing Rust installation to avoid conflicts"
    paru --no-confirm --needed --upgrade --sync --remove rust
  fi
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
fi

