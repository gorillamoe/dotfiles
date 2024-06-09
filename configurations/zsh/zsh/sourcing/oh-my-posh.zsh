# Install oh-my-posh, if not already installed
if ! command -v oh-my-posh &> /dev/null; then
  curl -s https://ohmyposh.dev/install.sh | sudo bash -s
fi

eval "$(oh-my-posh init zsh --config $HOME/.config/oh-my-posh/default.toml)"
