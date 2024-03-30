#!/usr/bin/env bash

# Stuff I usaully use on a new Pop!_OS install
#
# Install scripts for packages that are not available in the default repositories
# go into install-scripts/packages folder.
#
# Files in the files folder will be symlinked to the home directory via
# the install-scripts/symlinks.sh script at the end of the install process.

# List of packages to install via the default repositories
DEFAULT_REPO_PACKAGES=(
    "curl"
    "tmux"
    "wget"
    "zsh"
)

# Absolute path of this script
ABSOULTE_SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Update package list & install default packages
sudo apt update && sudo apt install -y "${DEFAULT_REPO_PACKAGES[@]}"

# Install packages from the install-scripts/packages folder
for file in install-scripts/packages/*.sh; do
    bash "$file"
done

# Symlink files from the files folder
bash install-scripts/symlink.sh "$ABSOULTE_SCRIPT_PATH"
