#!/usr/bin/env bash

set -euo pipefail

# NOTE:
# For convience,
# Make passwordless sudo possible via
# sudo visudo
# and add the following line to the end of the file
# <username> ALL=(ALL) NOPASSWD: ALL
#
# INFO:
# If you happen to be a vim user,
# you can replace the default editor with vim
# sudo update-alternatives --config editor
# before editing the sudoers file

# Neovim release tag to install
NEOVIM_RELEASE_TAG="v0.10.0"

# Shazam release tag to install
SHAZAM_RELEASE_TAG="v1.0.0"

# Go version to install
GO_VERSION="1.22.4"

sudo apt update

sudo apt install -y \
  bat \
  build-essential \
  cargo \
  curl \
  curl \
  eza \
  fd-find \
  flameshot \
  fuse3 \
  fzf \
  gcc \
  gnome \
  gnome-shell-extension-manager \
  htop \
  jq \
  libbz2-dev \
  libffi-dev \
  liblzma-dev \
  libncurses5-dev \
  libncursesw5-dev \
  libreadline-dev \
  libsqlite3-dev \
  libssl-dev \
  llvm \
  lua5.4 \
  luarocks \
  make \
  make \
  net-tools \
  pipx \
  python3-openssl
  ripgrep \
  shellcheck \
  tk-dev \
  tmux \
  touchegg \
  wget \
  xz-utils \
  zlib1g-dev \                                                                                               43.097s
  zsh

# Install Go
if [ -f /usr/local/go/bin/go ] && [ "$(go version | awk '{print $3}')" = "go$GO_VERSION" ]; then
  echo "📦 Go already installed"
  echo "💡 Skipping Go installation"
else
  if [ -f /usr/local/go/bin/go ]; then
    echo "📌 Go already installed but not the required version"
    echo "🧹 Removing the existing Go installation"
    rm -rf /usr/local/go
  fi
  wget https://golang.org/dl/go$GO_VERSION.linux-amd64.tar.gz
  sudo tar -C /usr/local -xzf go$GO_VERSION.linux-amd64.tar.gz
  rm go$GO_VERSION.linux-amd64.tar.gz
fi

# Install fonts
FONTS_INSTALLED=0
if [ ! -d ~/.local/share/fonts ]; then
  mkdir -p ~/.local/share/fonts
fi
if [ -f ~/.local/share/fonts/FiraCodeNerdFont-Regular.ttf ]; then
  echo "📦 FiraCodeNerdFont already installed"
  echo "💡 Skipping FiraCode installation"
else
  wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/FiraCode.zip
  unzip FiraCode.zip -d ~/.local/share/fonts
  rm ~/.local/share/fonts/*.md
  rm ~/.local/share/fonts/LICENSE*
  rm FiraCode.zip
  FONTS_INSTALLED=1
fi
if [ -f ~/.local/share/fonts/VictorMonoNerdFont-Regular.ttf ]; then
  echo "📦 VictorMonoNerdFont already installed"
  echo "💡 Skipping VictorMono installation"
else
  wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/VictorMono.zip
  unzip VictorMono.zip -d ~/.local/share/fonts
  rm ~/.local/share/fonts/*.md
  rm ~/.local/share/fonts/LICENSE*
  rm VictorMono.zip
  FONTS_INSTALLED=1
fi
if [ $FONTS_INSTALLED -eq 1 ]; then
  fc-cache -f -v
fi

# Install wezterm
if [ -f /usr/bin/wezterm ]; then
  echo "📦 wezterm already installed"
  echo "💡 Skipping wezterm installation"
else
  curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
  echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
  sudo apt update
  sudo apt install wezterm
fi

# Install Google Chrome
if [ -f /usr/bin/google-chrome ]; then
  echo "📦 Google Chrome already installed"
  echo "💡 Skipping Google Chrome installation"
else
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  sudo apt install -y ./google-chrome-stable_current_amd64.deb
  rm google-chrome-stable_current_amd64.deb
fi

# tmux plugin manager install
if [ -d ~/.tmux/plugins/tpm ]; then
  echo "📦 tmux plugin manager already installed"
  echo "💡 Skipping tmux plugin manager installation"
else
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# Install Neovim
if [ -f /usr/bin/nvim ]; then
  echo "📦 Neovim already installed"
  echo "💡 Skipping Neovim installation"
else
  wget https://github.com/neovim/neovim/releases/download/$NEOVIM_RELEASE_TAG/nvim.appimage
  chmod +x nvim.appimage
  sudo mv nvim.appimage /usr/bin/nvim
fi

# Install pyenv
if [ -d ~/.pyenv ]; then
  echo "📦 pyenv already installed"
  echo "💡 Skipping pyenv installation"
else
  curl https://pyenv.run | bash
fi

# Install shazam.sh and symlink dotfiles
if [ -f /usr/bin/shazam ]; then
  echo "📦 shazam.sh already installed"
  echo "💡 Skipping shazam.sh installation"
else
  wget "https://github.com/mistweaverco/shazam.sh/releases/download/$SHAZAM_RELEASE_TAG/shazam-linux"
  chmod +x shazam-linux
  sudo mv shazam-linux /usr/bin/shazam
fi
# Symlink dotfiles
shazam

# Ensure $HOME/.local/bin directory exists
if [ ! -d ~/.local/bin ]; then
  mkdir -p ~/.local/bin
fi

# Make zsh the default shell
if [ "$SHELL" = "/bin/zsh" ]; then
  echo "📦 zsh already the default shell"
  echo "💡 Skipping zsh default shell setup"
else
  chsh -s "$(which zsh)"
fi

# Install Docker

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update && sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo groupadd docker
sudo usermod -aG docker "$USER"
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
sudo systemctl start docker.service
