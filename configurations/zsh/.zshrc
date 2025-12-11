# Add deno completions to search path
if [[ ":$FPATH:" != *":/home/marco/.zsh/completions:"* ]]; then export FPATH="/home/marco/.zsh/completions:$FPATH"; fi
autoload -U +X compinit && compinit

source /usr/share/zsh/share/antigen.zsh
antigen bundle mroth/evalcache
antigen apply

# store the absolute path of the current directory.
typeset -g ZSH_CWD="$PWD"

# Zsh executes this after every directory change.
function chpwd() {
    ZSH_CWD="$PWD"
}

# Zana
# getzana.net
_evalcache zana env zsh

###
#  Enable vi keybindings
###

# Custom widget to edit command line in Neovim in
# the current working directory
function zle-edit-command-line-cwd {
  local temp_file=$(mktemp -t zsh_cmd_XXXXXXXXXXX -p "$ZSH_CWD")
  print -r -- $BUFFER > $temp_file

  # Open the temporary file in neovim with zsh filetype
  command nvim --cmd "set filetype=zsh" "$temp_file"

  # Read the content back into the Zsh buffer after editing.
  if [[ -f $temp_file ]]; then
    BUFFER=$(cat $temp_file)
    CURSOR=$#BUFFER
    rm $temp_file
    # enter insert mode after returning from nvim
    zle vi-insert
  fi
}

# Register the widget with Zsh's line editor
zle -N zle-edit-command-line-cwd

# Bind the new widget to 'v' in vi command mode
bindkey -M vicmd v zle-edit-command-line-cwd

# Enable vi keybindings
bindkey -v
export VI_MODE_SET_CURSOR=true

# change cursor shape in vi mode
zle-keymap-select () {
    if [[ $KEYMAP == vicmd ]]; then
        # the command mode for vi
        echo -ne "\e[2 q"
    else
        # the insert mode for vi
        echo -ne "\e[5 q"
    fi
}

precmd_functions+=(zle-keymap-select)
zle -N zle-keymap-select

# Keybindings
## Home key
bindkey  "^[[H"   beginning-of-line
## End key
bindkey  "^[[F"   end-of-line
## Delete key
bindkey  "^[[3~"  delete-char

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

export HISTSIZE=50000
export SAVEHIST=50000
export HISTFILE=~/.zsh_history

# INFO:
# Do not write duplicate entries
setopt HIST_IGNORE_ALL_DUPS

# INFO:
# delete duplicates first, when HISTFILE exceeds HISTSIZE
setopt HIST_EXPIRE_DUPS_FIRST

# INFO:
# Even if there are duplicates,
# do not find them when searching history
setopt HIST_FIND_NO_DUPS

# NOTE:
# The following should be turned off,
# if sharing history via setopt SHARE_HISTORY

# INFO:
# It immediately writes the history to the file,
# instead of waiting for the shell to exit
setopt INC_APPEND_HISTORY

# INFO:
# Do not write lines starting
# with space to the history file
setopt HIST_IGNORE_SPACE

# INFO:
# Record time of command in history
setopt EXTENDED_HISTORY

export CARAPACE_BRIDGES='zsh,bash,inshellisense' # optional
zstyle ':completion:*:git:*' group-order 'main commands' 'alias commands' 'external commands'
source <(carapace _carapace)

# Set the directory where we want to store zinit and the plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download and install zinit if it's not already installed
if [[ ! -d $ZINIT_HOME ]]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "$ZINIT_HOME/zinit.zsh"

zinit wait lucid for \
  zdharma-continuum/fast-syntax-highlighting \
  zdharma-continuum/history-search-multi-word \
  blockf \
  zsh-users/zsh-completions \
  atload"bindkey '^n' autosuggest-accept" \
  zsh-users/zsh-autosuggestions

zstyle :plugin:history-search-multi-word reset-prompt-protect 1

# Install oh-my-posh, if not already installed
if ! command -v oh-my-posh &> /dev/null; then
  curl -s https://ohmyposh.dev/install.sh | bash -s
fi

_evalcache oh-my-posh init zsh --config $HOME/.config/oh-my-posh/default.toml

# Cargo path
export PATH="$HOME/.cargo/bin:$PATH"

# Go path
export GOPATH="$HOME/go"

# If you come from bash you might have to change your $PATH.
export PATH="$HOME/bin:/usr/local/bin:/usr/local/go/bin:$GOPATH/bin:$PATH"

# bun completions
[ -s "/home/marco/.bun/_bun" ] && source "/home/marco/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# better ls
alias ls='eza --icons=always'

# I <3 Neovim
alias vim=nvim
alias vi=nvim

alias 'll'='ls -la'
alias 'gopen'='xdg-open'

if command -v batcat &> /dev/null; then
  alias 'bat'='batcat'
fi

if command -v fdfind &> /dev/null; then
  alias 'fd'='fdfind'
fi

# Use yazi to change directory and update shell cwd
yy() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

# shorthand for yazi
alias 'y'='yazi'

# Mise
_evalcache mise activate zsh

# https://direnv.net/docs/hook.html#zsh
_evalcache direnv hook zsh

# Zoxide
_evalcache zoxide init zsh

# Node Modules
# This neeeds to come after nvm
# so that it always prefers the local version
export PATH="node_modules/.bin:$PATH"

# .NET tools
export PATH="$PATH:/home/marco/.dotnet/tools"

export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/gcr/ssh"

# Google Cloud CLI
export PATH="/opt/google-cloud-cli/bin:$PATH"

[[ -d $HOME/.local/bin ]] && export PATH="$HOME/.local/bin:$PATH"

# rustup
[[ -d $HOME/.cargo/env ]] && . "$HOME/.cargo/env"

# Deno
. "/home/marco/.deno/env"

# My own scripts take precedence
[[ -d $HOME/.local/scripts ]] && export PATH="$HOME/.local/scripts:$PATH"
