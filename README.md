Gorilla Moe's Pop!_OS Setup Files
=================================

This is my 🦍🍌 Pop!_OS setup ♻️ repository.

It contains my dotfiles, as well as a few scripts to set up my system the way I love it ❤️.

## The following software will be installed

Various software will be installed from the package manager,
see [pop_os-setup.sh](./pop_os-setup.sh) for more details.

## The following software will be configured / symlinked

Various dotfiles will be symlinked:

 - See [symlink/](./symlink/) and
 - See [shazam.sh.yml](./shazam.sh.yml) (`.symlinks`) for more details.

## Installation

```bash
# Ensure directory exists
mkdir -p ~/projects/personal

# Clone the repository
git clone git@github.com:gorillamoe/dotfiles.git ~/projects/personal/dotfiles

# Change directory and run the install script
cd ~/projects/personal/dotfiles
shzm # shazam.sh package manager on steroids - https://github.com/mistweaverco/shazam.sh
```
