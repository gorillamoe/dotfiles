#!/usr/bin/env bash

# Install bun
echo "📦 Installing Vite+, the UnifiedToolchain for the Web"
if [ -d ~/.viteplus ]; then
  echo "📦 Vite+ already installed"
  echo "💡 Skipping Vite+ installation"
else
  curl -fsSL https://vite.plus/install.sh | bash
fi
