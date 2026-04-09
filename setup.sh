#!/usr/bin/env bash

set -euo pipefail

# NOTE:
# add ILoveCandy in your /etc/pacman.conf file
# in the Misc options, for a fancier pacman experience

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

echo "📦 Installing default packages from default-packages.txt"
xargs -a ./setup/default-packages.txt paru -S

# Ensure $HOME/.local/bin directory exists
echo "📁 Ensuring ~/.local/bin directory exists"
if [ ! -d ~/.local/bin ]; then
  mkdir -p ~/.local/bin
fi

# Install fonts
bash setup/install-fonts.sh

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

# Install extras
bash setup/install-extras.sh

echo "✅ Setup completed successfully! Please reboot your system to apply all changes."
