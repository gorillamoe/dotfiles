#!/usr/bin/env bash

# Install bun
echo "📦 Installing bun JavaScript/TypeScript runtime"
if [ -d ~/.bun ]; then
  echo "📦 bun already installed"
  echo "💡 Skipping bun installation"
else
  curl -fsSL https://bun.sh/install | bash
fi
