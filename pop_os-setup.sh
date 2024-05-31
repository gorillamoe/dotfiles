#!/usr/bin/env bash

sudo apt update

sudo apt install -y curl exa jq shellcheck \
  tmux ripgrep bat sqlite fzf fd-find zsh \
  i3 rofi polybar xautolock feh pavucontrol arandr \
  picom, blueman

# Install wezterm
curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | tee /etc/apt/sources.list.d/wezterm.list
sudo apt update
sudo apt install wezterm

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

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

# tmux plugin manager install
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Neovim release tag to install
NEOVIM_RELEASE_TAG="v0.9.5"

# Download and install neovim
wget https://github.com/neovim/neovim/releases/download/$NEOVIM_RELEASE_TAG/nvim.appimage && \
  chmod +x nvim.appimage && \
  sudo mv nvim.appimage /usr/bin/nvim

# Install shazam.sh for symlink management
wget "https://github.com/mistweaverco/shazam.sh/releases/download/v1.0.3/shazam.sh-1.0.3-linux.tar.gz" && \
  tar -xvf "shazam.sh-1.0.4-linux.tar.gz" && \
  sudo mv shzm /usr/bin/shzm && \
  rm "shazam.sh-1.0.4-linux.tar.gz"

# Symlink dotfiles
shzm
