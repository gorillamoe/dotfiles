#!/usr/bin/env bash

# Install deno
echo "📦 Installing deno JavaScript/TypeScript runtime"
if [ -d ~/.deno ]; then
  echo "📦 deno already installed"
  echo "💡 Skipping deno installation"
else
  curl -fsSL https://deno.land/install.sh | sh
fi
