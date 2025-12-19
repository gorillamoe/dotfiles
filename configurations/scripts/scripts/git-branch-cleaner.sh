#!/usr/bin/env bash

# git-branch-cleaner.sh
# A script that generates a multi select prompt to delete
# local git branches.

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

# Get the list of local branches excluding the current branch
# and format it for fzf
branches=$(git for-each-ref --format='%(refname:short)' refs/heads)
current_branch=$(git rev-parse --abbrev-ref HEAD)
branches=$(echo "$branches" | grep -v "^$current_branch$")
if [ -z "$branches" ]; then
    echo "✅ No local branches to delete. Exiting."
    exit 0
fi

# Use fzf to select branches to delete
selected_branches=$(echo "$branches" | fzf --multi \
    --preview 'git log -5 --oneline {}' \
    --header 'Press TAB/SPACE to select, ENTER to confirm' \
    --prompt 'Delete branches> ' \
    --height 95% \
    --border \
    --ansi \
    --bind 'ctrl-a:select-all' \
    --bind 'space:toggle' \
    --info 'inline' \
    --layout 'reverse')

# Check if any branches were selected
# If none were selected, exit the script
if [ -z "$selected_branches" ]; then
    echo "❌ No branches selected. Exiting."
    exit 0
fi

# Confirm deletion
# Prompt the user to confirm deletion of the selected branches
echo "You have selected the following branches for deletion:"
echo "$selected_branches"
echo -ne "Are you sure you want to delete these branches? (y/n): "
read -n 1 -r confirm
echo
confirm
if [[ ! $confirm =~ ^[Yy]$ ]]; then
    echo "❌ Deletion cancelled. Exiting."
    exit 0
fi

# Delete the selected branches
# Loop through each selected branch and delete it
echo "$selected_branches" | while read -r branch; do
    git branch -D "$branch"
    echo "🗑️ Deleted branch: $branch"
  done
echo "♻️ Branch deletion complete."
git fetch --all --prune
echo "♻️ Fetched and pruned remote branches."
