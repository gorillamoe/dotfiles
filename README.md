Gorilla Moe's Ubuntu Setup Files
================================

This is my 🦍🍌 Linux 🐧 setup ♻️ repository.

It contains my dotfiles, as well as a few scripts to set up my system the way I love it ❤️.

## The following software will be installed

Various software will be installed from the package manager,
see [setup.sh](./setup.sh) for more details.

## The following software will be configured / symlinked

Various dotfiles will be symlinked:

 - See [configurations/](./configurations/) and
 - [shazam.yml](./shazam.yml) (`.configurations`) for more details.

## Installation

> [!NOTE]
> [shazam.sh](https://github.com/mistweaverco/shazam.sh) is used to symlink the dotfiles.

```sh
# Ensure directory exists
mkdir -p ~/projects/personal

# Clone the repository
git clone git@github.com:gorillamoe/dotfiles.git ~/projects/personal/dotfiles

# Change directory and run shazam
cd ~/projects/personal/dotfiles && shazam
```
