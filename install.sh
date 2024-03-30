#!/usr/bin/env bash

# Stuff I usaully use on a new Pop!_OS install

# List of packages to install via the default repositories
DEFAULT_REPO_PACKAGES=(
    "curl"
    "git"
    "tmux"
    "wget"
    "zsh"
)

# Neovim release tag to install
NEOVIM_RELEASE_TAG="v0.9.5"

# Node Version Manager release tag to install
NVM_RELEASE_TAG="v0.39.7"

# Node version to install
NODE_VERSION="20.12.0"

# Update package list & install default packages
sudo apt update && sudo apt install -y ${DEFAULT_REPO_PACKAGES[@]}

# Download and install neovim
wget https://github.com/neovim/neovim/releases/download/$NEOVIM_RELEASE_TAG/nvim.appimage && chmod +x nvim.appimage && sudo mv nvim.appimage /usr/bin/nvim

# oh-my-zsh install
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# tmux plugin manager install
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Install node version manager
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_RELEASE_TAG/install.sh | bash

# Source nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Download and install node via nvm
nvm install $NODE_VERSION && nvm use $NODE_VERSION
