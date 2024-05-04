Gorilla Moe's Pop!_OS Setup Files
=================================

This is my 🦍🍌 Pop!_OS setup ♻️ repository.

It contains my dotfiles, as well as a few scripts to set up my system the way I love it ❤️.

## Requirements

 - [shazam.sh](https://github.com/mistweaverco/shazam.sh)

## The following software will be installed

Various software will be installed from the package manager,
see [shazam.sh.yaml](./shazam.sh.yaml) (`.packages`) for more details.

Custom software from custom install scripts.

 - See [customs/](./customs/) and
 - See [shazam.sh.yaml](./shazam.sh.yaml) (`.customs`) for more details.

## The following software will be configured

Various dotfiles will be symlinked

 - See [symlinks/](./symlinks/) and
 - See [shazam.sh.yaml](./shazam.sh.yaml) (`.symlinks`) for more details.

## Installation

```bash
# Ensure directory exists
mkdir -p ~/projects/personal

# Clone the repository
git clone git@github.com:gorillamoe/dotfiles.git ~/projects/personal/dotfiles

# Change directory and run the install script
cd ~/projects/personal/dotfiles
shzm
```
