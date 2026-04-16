#!/usr/bin/env bash

# git-tags-helper.sh
# Can help you with:
# - show you the latest (semver) tag
# - show you the previous (semver) tag before the latest (semver) tag
# - show you all (semver) tags
# Usage:
# - ./git-tags-helper.sh semver all
# - ./git-tags-helper.sh semver latest
# - ./git-tags-helper.sh semver previous


_COMMAND="${1:-""}"
_ACTION="${2:-""}"

if ! [[ "$_COMMAND" =~ ^(semver)$ ]]; then
  echo "Usage: $0 [semver]"
  exit 1
fi

if [[ "$_COMMAND" == "semver" ]] && ! [[ "$_ACTION" =~ ^(all|latest|previous)$ ]]; then
  echo "Usage: $0 semver [all|latest|previous]"
  exit 1
fi

if [[ "$_COMMAND" == "semver" ]]; then
  if [[ "$_ACTION" == "all" ]]; then
    git tag -l 'v[0-9]*.[0-9]*.[0-9]*' --sort=v:refname
  elif [[ "$_ACTION" == "latest" ]]; then
    git describe --tags --match 'v[0-9]*.[0-9]*.[0-9]*' --abbrev=0 "$(git rev-list --tags='v[0-9]*.[0-9]*.[0-9]*' --max-count=1 | tail -n 1)"
  elif [[ "$_ACTION" == "previous" ]]; then
    git describe --tags --match 'v[0-9]*.[0-9]*.[0-9]*' --abbrev=0 "$(git rev-list --tags='v[0-9]*.[0-9]*.[0-9]*' --max-count=2 | tail -n 1)"
  else
    echo "Usage: $0 [latest|previous]"
  fi
  exit 0
fi
