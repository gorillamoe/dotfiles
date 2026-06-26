#!/usr/bin/env bash

# Checks for usage AI in the current directory and
# its subdirectories.
# Or if a directory is specified,
# checks for usage ai in that directory and its subdirectories.
# Usage: ./check-for-ai-usage.sh [directory]

source "$(dirname "$0")/__shared.sh"

dir="${1:-.}"

files=$(rg '—' "$dir" --ignore-case --color=always)

if [ -z "$files" ]; then
  print_color "No usage of AI   found in $dir " "green"
else
  print_color "Possible usage of AI   found in the following files:" "" "red"
  echo -e "$files"
fi
