#!/usr/bin/env bash

main() {
  local cmd

  cmd=$(command gcloud compute ssh "$@" --dry-run) || return $?
  cmd=${cmd#/usr/bin/}

  [[ "$cmd" == ssh\ * ]] || {
    echo "Unexpected gcloud SSH command: $cmd"
    return 1
  }

  eval "kitten $cmd"
}

main "$@"
