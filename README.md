# Gorilla Moe's Manjaro Linux Setup Files

This is my 🦍🍌 Linux 🐧 setup ♻️ repository.

It contains my dotfiles,
as well as a few scripts to set up my system
the way I love it ❤️.

## The following software will be installed

Various software will be installed from the package manager,
see [setup/default-packages.txt](./setup/default-packages.txt)
for more details.

Additionally I like to install some [extras](./setup/extras.d/),
that are currently not supported by either the package manager
or [Zana](https://getzana.net).

## The following software will be configured / symlinked

Various dotfiles will be symlinked:

 - See [configurations/](./configurations/) and
 - [shazam.yml](./shazam.yml) (`configurations`) for more details.

## Installation

> [!NOTE]
> [shazam.sh](https://github.com/mistweaverco/shazam.sh) is used to symlink the dotfiles.

```sh
# Ensure directory exists
mkdir -p ~/projects/personal

# Clone the repository
git clone git@github.com:gorillamoe/dotfiles.git ~/projects/personal/dotfiles
git submodule update --init --recursive --remote 

# Change directory
cd ~/projects/personal/dotfiles
# .. and run the setup script
./setup.sh
```

Download private SSH keys and place them in `~/.ssh/`

```sh
cp path/to/private/id_rsa ~/.ssh/id_rsa
cp path/to/private/id_rsa.pub ~/.ssh/id_rsa.pub
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
```

Download private GPG keys and import them:

```sh
gpg --import path/to/private/key.asc
```
