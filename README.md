Gorilla Moe's Pop!_OS Setup Files
=================================

This is my 🦍🍌 Pop!_OS setup ♻️ repository.

It contains my dotfiles, as well as a few scripts to set up my system the way I love it ❤️.

## The following software will be installed

Curl, wget, tmux and zsh will be installed from the package manager.
Additionally, various software will be installed;
see [install-scripts/packages](./install-scripts/packages) for more details.

## The following software will be configured

See the [symlink](./symlink) directory for more details.

## Installation

```bash
# Ensure directory exists
mkdir -p ~/projects/personal

# Clone the repository
git clone git@github.com:gorillamoe/dotfiles.git ~/projects/personal/dotfiles

# Change directory and run the install script
cd ~/projects/personal/dotfiles
./install.sh
```
