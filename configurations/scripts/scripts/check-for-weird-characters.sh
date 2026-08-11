#!/usr/bin/env bash

# Checks for weird characters in the current directory and
# its subdirectories.
# Or if a directory is specified,
# Usage: ./check-for-weird-characters.sh [directory]
# If no directory is specified, the current directory is used.
# You can also add the --fix flag to replace — with -

set -euo pipefail

source "$(dirname "$0")/__shared.sh"

WEIRD_CHARACTERS_ARRAY=(
  "—"
  "–"
  "―"
  "‒"
  "−"
  "﹘"
  "﹣"
  "－"
)

REPLACE_WITH_CHARACTERS_ARRAY=(
  "-"
  "-"
  "-"
  "-"
  "-"
  "-"
  "-"
  "-"
)

# True if the --fix flag is passed, false otherwise
SHOULD_FIX=false

DIR_ARGS=()

# Get all flags passed to the script
for arg in "$@"; do
  if [ "$arg" == "--fix" ]; then
    SHOULD_FIX=true
  else
    DIR_ARGS+=("$arg")
  fi
done

# if DIR_ARGS is empty, use the current directory
if [ ${#DIR_ARGS[@]} -eq 0 ]; then
  DIR_ARGS=(".")
fi

FOUND_WEIRD_CHARS_IN_FILES=()
FOUND_WEIRD_CHARS_IN_FILES=()

for weird_char in "${WEIRD_CHARACTERS_ARRAY[@]}"; do
    while IFS= read -r file; do
        FOUND_WEIRD_CHARS_IN_FILES+=("$file")
    done < <(
        rg \
            --files-with-matches \
            --fixed-strings \
            --ignore-case \
            -- "$weird_char" "${DIR_ARGS[@]}" || true
    )
done

if [ "$SHOULD_FIX" = true ] && [ ${#FOUND_WEIRD_CHARS_IN_FILES[@]} -gt 0 ]; then
  print_color "Fixing weird char usage in files..." "" "yellow"
  for file in "${FOUND_WEIRD_CHARS_IN_FILES[@]}"; do
    for i in "${!WEIRD_CHARACTERS_ARRAY[@]}"; do
      weird_char="${WEIRD_CHARACTERS_ARRAY[$i]}"
      replace_with="${REPLACE_WITH_CHARACTERS_ARRAY[$i]}"
      sed -i "s/$weird_char/$replace_with/g" "$file"
    done
    print_color "Fixed weird characters in $file" "" "green"
  done
  exit 0
fi


if [ -z "${FOUND_WEIRD_CHARS_IN_FILES[*]}" ]; then
  print_color "No weird characters found in ${DIR_ARGS[*]}" "" "green"
else
  print_color "Weird characters found in the following files:" "" "red"
  for file in "${FOUND_WEIRD_CHARS_IN_FILES[@]}"; do
    print_color " - $file" "" "red"
  done
fi
