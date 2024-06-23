#!/usr/bin/env bash

sudo apt update

sudo apt install -y \
  arandr \
  bat \
  blueman \
  cargo \
  curl \
  dunst \
  eza \
  fd-find \
  fuse \
  fzf \
  gcc \
  gnome \
  gnome-keyring \
  jq \
  kanshi \
  lua5.4 \
  luarocks \
  lxappearance \
  pavucontrol \
  ripgrep \
  rofi \
  shellcheck \
  sway \
  swayidle \
  swaylock \
  touchegg \
  tmux \
  waybar \
  zsh

# Install fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/FiraCode.zip
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/VictorMono.zip
unzip FiraCode.zip -d ~/.local/share/fonts
rm ~/.local/share/fonts/*.md
unzip VictorMono.zip -d ~/.local/share/fonts
rm ~/.local/share/fonts/*.md
fc-cache -f -v
rm FiraCode.zip VictorMono.zip

# Install wezterm
curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
sudo apt update
sudo apt install wezterm

# Install Google Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install -y ./google-chrome-stable_current_amd64.deb
rm google-chrome-stable_current_amd64.deb

# Install PyEnv
curl https://pyenv.run | bash

# tmux plugin manager install
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Neovim release tag to install
NEOVIM_RELEASE_TAG="v0.10.0"

# Download and install neovim
wget https://github.com/neovim/neovim/releases/download/$NEOVIM_RELEASE_TAG/nvim.appimage
chmod +x nvim.appimage
sudo mv nvim.appimage /usr/bin/nvim

# Install pyenv
curl https://pyenv.run | bash

# Install shazam.sh for symlink management
wget "https://github.com/mistweaverco/shazam.sh/releases/download/v1.0.0/shazam-linux" && \
  chmod +x shazam-linux && \
  sudo mv shazam-linux /usr/bin/shazam

# Symlink dotfiles
shazam

# Make zsh the default shell
chsh -s "$(which zsh)"

