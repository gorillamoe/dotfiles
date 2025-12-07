#!/usr/bin/env bash

# git-release.sh takes the following argument patch|minor|major
# and creates a new semver tag based on the latest tag
# For example, if the latest tag is v1.2.3 and you run
# git release minor, it will create tag v1.3.0
# git release patch will create v1.2.4
# git release major will create v2.0.0
# If there are no tags, it will create v0.1.0 for minor,
# v0.0.1 for patch and v1.0.0 for major
# It will also push the tag to the remote
# Usage: git-release.sh ["patch"|"minor"|"major"] [<create release message boolean>]
# Defaults to patch if no argument is given

RELEASE_TYPE="$1"
CREATE_RELEASE_MESSAGE="$2"
LATEST_TAG="v0.0.0"
NEW_TAG=""
CONFIRM_TAG_CREATION="n"
CONFIRM_TAG_PUSH="n"


set_latest_tag() {
  local lt
  if [ ! -z "$(git tag)" ]; then
    lt="$(git describe --tags --match 'v[0-9]*.[0-9]*.[0-9]*' --abbrev=0 "$(git rev-list --tags='v[0-9]*.[0-9]*.[0-9]*' --max-count=1 | tail -n 1)")"
    if [ -z "$lt" ]; then
      echo "No valid semver tags found. Starting from $LATEST_TAG"
    else
      LATEST_TAG="$lt"
      echo "Found latest tag: $LATEST_TAG"
    fi
  else
    echo "No existing tags found. Starting from $LATEST_TAG"
  fi
}


set_new_tag() {
  IFS='.' read -r -a parts <<< "${LATEST_TAG#v}"
  MAJOR=${parts[0]};
  MINOR=${parts[1]};
  PATCH=${parts[2]};

  case "$RELEASE_TYPE" in
    major)
      NEW_TAG="v$((MAJOR + 1)).0.0";;
    minor)
    NEW_TAG="v$MAJOR.$((MINOR + 1)).0";;
    patch|"" )
      NEW_TAG="v$MAJOR.$MINOR.$((PATCH + 1))";;
    *)
      echo "Usage: git release [patch|minor|major] [<create release message boolean>]"
      return 1;;
  esac
}

prompt_for_confirmation() {
  echo -ne "Create tag $NEW_TAG? (y/n) "
  read -r -n 1 CONFIRM_TAG_CREATION
  echo

  if [[ "$CONFIRM_TAG_CREATION" != "y" ]]; then
    echo "Tag creation aborted."
    exit 0
  fi

  if [[ -n "$CREATE_RELEASE_MESSAGE" ]]; then
    if ! git tag -a "$NEW_TAG" -e; then
      echo "Tag creation aborted."
      exit 1
    fi
  else
    git tag "$NEW_TAG"
  fi

  echo -ne "Do you want to push the new tag to the remote repository? (y/n) "
  read -r -n 1 CONFIRM_TAG_PUSH
  echo

  if [[ "$CONFIRM_TAG_PUSH" == "y" ]]; then
    git push origin "$NEW_TAG"
    echo "Pushed tag $NEW_TAG to remote."
  else
    echo "Tag $NEW_TAG created locally but not pushed."
  fi
}

set_latest_tag
set_new_tag
prompt_for_confirmation
