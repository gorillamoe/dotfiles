#!/usr/bin/env bash

# git-branch-cleaner.sh
# A script that cleans up local git branches.
# It either deletes all local branches (wild mode) or allows the user to select
# local git branches using fzf (edit mode) for deletion.

# Check if fzf is installed
if ! command -v fzf &> /dev/null; then
    echo "⚠️ fzf is not installed. Please install fzf to use this script."
    exit 1
fi

# Check if we are in a git repository
if ! git rev-parse --is-inside-work-tree &> /dev/null; then
    echo "⚠️ This script must be run inside a git repository."
    exit 1
fi

get_formatted_branches() {
  local b=("$@")
  printf ' - %s\n' "${b[@]}"
}

# Get the list of local branches excluding the current branch
# and format it for fzf
branches=$(git for-each-ref --format='%(refname:short)' refs/heads)
current_branch=$(git rev-parse --abbrev-ref HEAD)
branches=$(echo "$branches" | grep -v "^$current_branch$")
formatted_branches=$(get_formatted_branches "${branches[@]}")
wild_mode=""

if [ -z "$branches" ]; then
    echo "✅ No local branches to delete. Exiting."
    exit 0
fi

echo "⚠️ Warning: This will delete these local branches:"
echo "$formatted_branches"
echo
echo -ne "❓ Delete? (y/n/e): "
read -n 1 -r wild_mode
echo

# wild mode, delete all branches
if [[ $wild_mode =~ ^[Yy]$ ]]; then
  selected_branches="$branches"
  echo "🔥 Wild mode selected: Deleting all branches."
# edit mode, choose branches to delete
elif [[ $wild_mode =~ ^[Ee]$ ]]; then
  echo "🔍 Edit mode selected: Choose branches to delete."
  # Use fzf to select branches to delete
  selected_branches=$(echo "$branches" | fzf --multi \
      --preview 'git log -5 --oneline {}' \
      --header 'Press TAB/SPACE to select, ENTER to confirm' \
      --prompt 'Select branches to delete> ' \
      --height 95% \
      --border \
      --ansi \
      --bind 'space:toggle' \
      --info 'inline' \
      --layout 'reverse')
fi

if [ -z "$selected_branches" ]; then
    echo "✅ No branches selected."
else
  # Confirm deletion
  # Prompt the user to confirm deletion of the selected branches
  echo "👀 You have selected the following branches for deletion:"
  echo "${selected_branches//$'\n - '/, }"
  echo -ne "❓ Delete? (y/n): "
  read -n 1 -r confirm
  echo
  if [[ ! $confirm =~ ^[Yy]$ ]]; then
      echo "✅ Branch deletion cancelled. Exiting."
      exit 0
  fi

  # Delete the selected branches
  # Loop through each selected branch and delete it
  echo "$selected_branches" | while read -r branch; do
      git branch -D "$branch"
      echo "🗑️ Deleted branch: $branch"
    done
  echo "♻️ Branch deletion complete."
fi

git fetch --all --prune
echo "♻️ Fetched and pruned remote branches."
