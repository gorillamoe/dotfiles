#!/usr/bin/env bash

sudo apt update

sudo apt install -y curl exa jq shellcheck \
  tmux ripgrep batcat sqlite fzf fd-find zsh \
  sway rofi waybar feh pavucontrol arandr \
  blueman dunst gnome-keyring lxappearance

# Install wezterm
curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | tee /etc/apt/sources.list.d/wezterm.list
sudo apt update
sudo apt install wezterm

# tmux plugin manager install
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Neovim release tag to install
NEOVIM_RELEASE_TAG="v0.10.0"

# Download and install neovim
wget https://github.com/neovim/neovim/releases/download/$NEOVIM_RELEASE_TAG/nvim.appimage && \
  chmod +x nvim.appimage && \
  sudo mv nvim.appimage /usr/bin/nvim

# Install shazam.sh for symlink management
wget "https://github.com/mistweaverco/shazam.sh/releases/download/v1.0.0/shazam-linux" \
  sudo mv shazam-linux /usr/bin/shazam

# Symlink dotfiles
shazam

# Make zsh the default shell
chsh -s "$(which zsh)"

# Make gnome-keyring work with sway
systemctl --user enable --now gnome-keyring-daemon
