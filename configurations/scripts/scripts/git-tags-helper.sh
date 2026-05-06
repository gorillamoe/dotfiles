#!/usr/bin/env bash

# git-tags-helper.sh
# Can help you with:
# - show you the latest (semver) tag
# - show you the previous (semver) tag before the latest (semver) tag
# - show you all (semver) tags
# Usage:
# - ./git-tags-helper.sh all semver
# - ./git-tags-helper.sh latest semver
# - ./git-tags-helper.sh previous semver


_TAG_FILTER="${1:-"all"}"
_TAG_TYPE="${2:-"semver"}"

_show_usage() {
  echo "Usage: $0 [latest|previous|all] [semver]"
}

if [[ "$_TAG_TYPE" == "semver" ]] && ! [[ "$_TAG_FILTER" =~ ^(all|latest|previous|prev)$ ]]; then
  _show_usage
  exit 1
fi

if ! [[ "$_TAG_TYPE" =~ ^(semver)$ ]]; then
  _show_usage
  exit 1
fi

if [[ "$_TAG_TYPE" == "semver" ]]; then
  if [[ "$_TAG_FILTER" == "all" ]]; then
    git tag -l 'v[0-9]*.[0-9]*.[0-9]*' --sort=v:refname
  elif [[ "$_TAG_FILTER" == "latest" ]]; then
    git describe --tags --match 'v[0-9]*.[0-9]*.[0-9]*' --abbrev=0 "$(git rev-list --tags='v[0-9]*.[0-9]*.[0-9]*' --max-count=1 | tail -n 1)"
  elif [[ "$_TAG_FILTER" == "previous" ]] || [[ "$_TAG_FILTER" == "prev" ]]; then
    git describe --tags --match 'v[0-9]*.[0-9]*.[0-9]*' --abbrev=0 "$(git rev-list --tags='v[0-9]*.[0-9]*.[0-9]*' --max-count=2 | tail -n 1)"
  else
    echo "Usage: $0 [latest|previous]"
  fi
  exit 0
fi
