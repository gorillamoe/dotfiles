#!/usr/bin/env bash

# Exit if no path argument is provided
if [ -z "$1" ]; then
    echo "No path argument provided. Exiting..."
    exit 1
fi

# Check if path exists
if [ ! -d "$1/symlink" ]; then
    echo "Path does not exist. Exiting..."
    exit 1
fi

# Symlink files from the files folder to the home directory with absolute paths
for setupfile in "$1/symlink/"*"/setup.sh"; do
  bash "$setupfile" "$1"
done
