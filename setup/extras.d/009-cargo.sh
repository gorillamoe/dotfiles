#!/usr/bin/env bash

while read -r line; do
  # INFO:
  # We actually want to split the line into multiple arguments,
  # so we disable the warning about word splitting.
  # shellcheck disable=SC2086
  cargo install $line
done < ./setup/extras.d/cargo.txt
