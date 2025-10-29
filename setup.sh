#!/usr/bin/env bash

set -euo pipefail

# NOTE:
# For convience,
# Make passwordless sudo possible via
# sudo visudo
# and add the following line to the end of the file
# marco ALL=(ALL) NOPASSWD: ALL
# ---
# also
# sudo cp ./configurations/polkit-1/rules.d/99-pamac-overrides.rules /etc/polkit-1/rules.d/
# and then
# sudo systemctl reload polkit.service
# ---
# add ILoveCandy in your /etc/pacman.conf file
# in the Misc options, for a fancier pacman experience


# Shazam release tag to install
SHAZAM_RELEASE_TAG="v1.0.0"

pamac install -y \
  antigen \
  bat \
  build-essential \
  cargo \
  curl \
  direnv \
  docker \
  dust \
  eza \
  fd-find \
  fuse3 \
  fzf \
  gcc \
  gnome \
  gnome-shell-extension-manager \
  htop \
  btop \
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
  mise \
  net-tools \
  ripgrep \
  shellcheck \
  terragrunt \
  tfswitch \
  tk-dev \
  tmux \
  wget \
  xz-utils \
  zlib1g-dev \
  zsh

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

# tmux plugin manager install
if [ -d ~/.tmux/plugins/tpm ]; then
  echo "📦 tmux plugin manager already installed"
  echo "💡 Skipping tmux plugin manager installation"
else
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# Install bun
if [ -d ~/.bun ]; then
  echo "📦 bun already installed"
  echo "💡 Skipping bun installation"
else
  curl -fsSL https://bun.sh/install | bash
fi

# Install deno
if [ -d ~/.deno ]; then
  echo "📦 deno already installed"
  echo "💡 Skipping deno installation"
else
  curl -fsSL https://deno.land/install.sh | sh
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

# Configure docker
sudo groupadd docker
sudo usermod -aG docker "$USER"
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
sudo systemctl start docker.service
