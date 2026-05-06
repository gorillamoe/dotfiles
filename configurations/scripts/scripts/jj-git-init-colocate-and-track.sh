#!/usr/bin/env bash

# Usage: ./jj-git-init-colocate-and-track.sh [branch1 branch2 ...]

# Check if jj is installed
if ! command -v jj &> /dev/null; then
    echo "jj could not be found. Please install jj and try again."
    exit 1
fi

# Default tracking branches
tracking_branches=("main")

# Override tracking branches if provided as arguments
if [ "$#" -gt 0 ]; then
    tracking_branches=("$@")
fi

jj git init --colocate

for tracking_branch in "${tracking_branches[@]}"; do
  jj bookmark track "$tracking_branch" --remote=origin
  echo "📌 Tracking branch '$tracking_branch' from 'origin'"
done
