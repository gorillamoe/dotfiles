#!/usr/bin/env bash

# Install extras
for extra_script in ./setup/extras.d/*.sh; do
  echo "🔄 Running extra setup script: $extra_script"
  bash "$extra_script"
done
