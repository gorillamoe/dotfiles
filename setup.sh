#!/usr/bin/env bash

set -euo pipefail

# NOTE:
# add ILoveCandy in your /etc/pacman.conf file
# in the Misc options, for a fancier pacman experience

# Shazam release tag to install
SHAZAM_RELEASE_TAG="v1.0.0"

# Zana release tag to install
ZANA_RELEASE_TAG="v0.8.0"

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
pamac install --no-confirm \
  antigen \
  aspnet-runtime \
  bandwhich \
  bat \
  btop \
  carapace-bin \
  cargo \
  cosign \
  curl \
  direnv \
  docker \
  docker-buildx \
  dos2unix \
  dotnet-sdk \
  dust \
  eza \
  fastfetch \
  fd \
  fuse3 \
  fzf \
  gcc \
  gcr-4 \
  gnome \
  gnome-shell-extensions \
  pamac-gnome-integration \
  htop \
  jq \
  bzip2 \
  libffi \
  libwebp-utils \
  ncdu \
  ncurses \
  pandoc \
  readline \
  sqlite3 \
  llvm \
  lua \
  lua-lanes \
  lua-language-server \
  luacheck \
  luarocks \
  make \
  marksman \
  mise \
  netcat \
  net-tools \
  openssl \
  oryx \
  ripgrep \
  shellcheck \
  slides \
  stylua \
  terraform-ls \
  terragrunt \
  tfswitch \
  tk \
  vale \
  vhs \
  vivid \
  wezterm \
  wget \
  xz \
  yazi \
  zlib \
  zls \
  zoxide \
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

# Install rustup
if [ -d ~/.cargo ]; then
  echo "📦 rustup already installed"
  echo "💡 Skipping rustup installation"
else
  echo "📦 Installing rustup (Rust toolchain manager)"
  if command -v rust &>/dev/null; then
    echo "📦 Rust already installed"
    echo "💡 Removing existing Rust installation to avoid conflicts"
    pamac remove --no-confirm rust
  fi
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
fi

# Install dotnet packages
echo "📦 Installing .NET global tools"
dotnet tool install --global csharp-ls
dotnet tool install --global csharpier

# Install shazam.sh and symlink dotfiles
echo "📦 Installing shazam.sh for dotfiles management"
if [ -f /usr/bin/shazam ]; then
  echo "📦 shazam.sh already installed"
  echo "💡 Skipping shazam.sh installation"
else
  wget "https://github.com/mistweaverco/shazam.sh/releases/download/$SHAZAM_RELEASE_TAG/shazam-linux"
  chmod +x shazam-linux
  mv shazam-linux "$HOME/.local/bin/shazam"
fi

# Install shazam.sh and symlink dotfiles
echo "📦 Installing Zana for LSP and Linter management"
if [ -f "$HOME/.local/bin/zana" ]; then
  echo "📦 Zana already installed"
  echo "💡 Skipping Zana installation"
else
  wget "https://github.com/mistweaverco/zana-client/releases/download/$ZANA_RELEASE_TAG/zana-linux-amd64"
  chmod +x zana-linux-amd64
  mv zana-linux-amd64 "$HOME/.local/bin/zana"
fi

# Symlink dotfiles
echo "🔗 Symlinking dotfiles using shazam.sh"
shazam

# Make zsh the default shell
echo "🔄 Setting zsh as the default shell"
if [[ "$SHELL" = *zsh ]]; then
  echo "📦 zsh already the default shell"
  echo "💡 Skipping zsh default shell setup"
else
  chsh -s "$(which zsh)"
fi

# Enable auto ssh key unlocking
systemctl enable --user --now gcr-ssh-agent.service

# Configure docker
echo "🐳 Configuring Docker to run without sudo"
if groups "$USER" | grep &>/dev/null '\bdocker\b'; then
  echo "📦 User '$USER' is already in the docker group"
  echo "💡 Skipping docker group setup"
else
  echo "🔄 Adding user '$USER' to the docker group"
  if ! getent group docker &>/dev/null; then
    echo "🆕 Docker group does not exist. Creating docker group."
    sudo groupadd docker
  fi
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
