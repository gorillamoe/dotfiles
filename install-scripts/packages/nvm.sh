#!/usr/bin/env bash

# Node Version Manager release tag to install
NVM_RELEASE_TAG="v0.39.7"

# Node version to install
NODE_VERSION="20.12.0"

# Install node version manager
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_RELEASE_TAG/install.sh | bash

# Source nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Download and install node via nvm
nvm install $NODE_VERSION && nvm use $NODE_VERSION
