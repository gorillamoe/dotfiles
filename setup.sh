#!/usr/bin/env bash

set -euo pipefail

# NOTE:
# add ILoveCandy in your /etc/pacman.conf file
# in the Misc options, for a fancier pacman experience

# Shazam release tag to install
SHAZAM_RELEASE_TAG="v1.0.0"

# Update git submodules
echo "🔄 Updating git submodules"
git submodule update --init --recursive --remote

# Set up passwordless sudo for the current user
echo "🔒 Setting up passwordless sudo for user $USER"
if  [ -f "/etc/sudoers.d/$USER" ]; then
  echo "📦 Passwordless sudo already configured for user $USER"
  echo "💡 Skipping sudoers setup"
else
  echo "🔄 Configuring passwordless sudo for user $USER"
  sudo tee "/etc/sudoers.d/$USER" >/dev/null <<EOF
$USER ALL=(ALL) NOPASSWD: ALL
EOF
fi

# Copy polkit rules to allow pamac to run without password
echo "🔒 Setting up polkit rules for pamac"
if [ -f "/etc/polkit-1/rules.d/99-pamac-overrides.rules" ]; then
  echo "📦 Polkit rules for pamac already exist"
  echo "💡 Skipping polkit rules setup"
else
  echo "🔄 Copying polkit rules for pamac"
  sudo cp ./configurations/polkit-1/rules.d/99-pamac-overrides.rules /etc/polkit-1/rules.d/
fi

echo "📦 Updating system packages"
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
  marksman \
  mise \
  net-tools \
  ripgrep \
  shellcheck \
  slides \
  terragrunt \
  tfswitch \
  tk-dev \
  tmux \
  vhs \
  wezterm \
  wget \
  xz-utils \
  zlib1g-dev \
  zsh

# Ensure $HOME/.local/bin directory exists
echo "📁 Ensuring ~/.local/bin directory exists"
if [ ! -d ~/.local/bin ]; then
  mkdir -p ~/.local/bin
fi

# Install fonts
echo "🔤 Installing Nerd Fonts (Fira Code and Victor Mono)"
FONTS_INSTALLED=0
if [ ! -d ~/.local/share/fonts ]; then
  mkdir -p ~/.local/share/fonts
fi
if [ -f ~/.local/share/fonts/FiraCodeNerdFont-Regular.ttf ]; then
  echo "📦 FiraCodeNerdFont already installed"
  echo "💡 Skipping FiraCode installation"
else
  cp -p ./configurations/fonts/fira-code-nerd-font/* ~/.local/share/fonts/
  rm ~/.local/share/fonts/*.md
  rm ~/.local/share/fonts/LICENSE*
  rm FiraCode.zip
  FONTS_INSTALLED=1
fi
if [ -f ~/.local/share/fonts/VictorMonoNerdFont-Regular.ttf ]; then
  echo "📦 VictorMonoNerdFont already installed"
  echo "💡 Skipping VictorMono installation"
else
  cp -p ./configurations/fonts/victor-mono-nerd-font/* ~/.local/share/fonts/
  rm ~/.local/share/fonts/*.md
  rm ~/.local/share/fonts/LICENSE*
  FONTS_INSTALLED=1
fi
if [ $FONTS_INSTALLED -eq 1 ]; then
  echo "🔤 Rebuilding font cache"
  fc-cache -f -v
fi

# Install bun
echo "📦 Installing bun JavaScript/TypeScript runtime"
if [ -d ~/.bun ]; then
  echo "📦 bun already installed"
  echo "💡 Skipping bun installation"
else
  curl -fsSL https://bun.sh/install | bash
fi

# Install deno
echo "📦 Installing deno JavaScript/TypeScript runtime"
if [ -d ~/.deno ]; then
  echo "📦 deno already installed"
  echo "💡 Skipping deno installation"
else
  curl -fsSL https://deno.land/install.sh | sh
fi

# Install shazam.sh and symlink dotfiles
echo "📦 Installing shazam.sh for dotfiles management"
if [ -f /usr/bin/shazam ]; then
  echo "📦 shazam.sh already installed"
  echo "💡 Skipping shazam.sh installation"
else
  wget "https://github.com/mistweaverco/shazam.sh/releases/download/$SHAZAM_RELEASE_TAG/shazam-linux"
  chmod +x shazam-linux
  sudo mv shazam-linux /usr/bin/shazam
fi

# Symlink dotfiles
echo "🔗 Symlinking dotfiles using shazam.sh"
shazam

# Make zsh the default shell
echo "🔄 Setting zsh as the default shell"
if [ "$SHELL" = "/bin/zsh" ]; then
  echo "📦 zsh already the default shell"
  echo "💡 Skipping zsh default shell setup"
else
  chsh -s "$(which zsh)"
fi

# Configure docker
echo "🐳 Configuring Docker to run without sudo"
if groups "$USER" | grep &>/dev/null '\bdocker\b'; then
  echo "📦 User '$USER' is already in the docker group"
  echo "💡 Skipping docker group setup"
else
  echo "🔄 Adding user '$USER' to the docker group"
  sudo groupadd docker
  sudo usermod -aG docker "$USER"
fi

# Enable and start docker service
echo "🚀 Enabling and starting Docker service"
if sudo systemctl is-enabled docker.service &>/dev/null; then
  echo "📦 Docker service is already enabled"
  echo "💡 Skipping docker service enablement"
else
  echo "🔄 Enabling Docker service to start on boot"
  sudo systemctl enable docker.service
  sudo systemctl enable containerd.service
  sudo systemctl start docker.service
fi

echo "✅ Setup completed successfully! Please reboot your system to apply all changes."
