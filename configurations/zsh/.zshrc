autoload -U +X compinit && compinit

# Make alt + combo work in tmux
bindkey -e

# Keybindings
## Home key
bindkey '\e[1~'  beginning-of-line
## End key
bindkey '\e[4~'  end-of-line
## Delete key
bindkey '\e[3~'  delete-char

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

eval "$(oh-my-posh init zsh --config $HOME/.config/oh-my-posh/default.toml)"

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

alias ls='eza --icons=always'

# Terraform and Terragrunt
alias tf='terraform'
alias tg='terragrunt'

# I <3 Neovim
alias vim=nvim
alias vi=nvim

# easier sudo with env
alias 'sudoo'='sudo -E'

alias 'll'='ls -la'
alias '..'='cd ..'
alias 'gopen'='xdg-open'

if command -v batcat &> /dev/null; then
  alias 'bat'='batcat'
fi

if command -v fdfind &> /dev/null; then
  alias 'fd'='fdfind'
fi

# tmux is love, tmux is life
# attach to a new or existing tmux session
# Use default session name (0), if not specified
tmuxa() {
  local session_name="${1:-0}" # Use the first argument, or 0 if none provided
  tmux new-session -A -s "$session_name"
}

# Search downwards
,() {
  local fdres=$(fd --type d --hidden --exclude '.git' --exclude '.npm' "$@")
  if [ -z "$fdres" ]; then
    echo "No results $@"
    return
  fi
  local c=$(echo $fdres | wc -l)
  if [ $c -eq 1 ]; then
    cd $fdres
  else
    local r=$(echo $fdres | fzf-tmux -p)
    if [ -z "$r" ]; then
      return
    fi
    cd $r
  fi
}

# Search upwards
,,() {
  local current_dir=$(pwd)
  local found=0
  while [[ "$current_dir" != "/" ]]; do
    local fdres=$(fd --type d --hidden --exclude '.git' --exclude '.npm' "$@" "$current_dir" | awk -F/ -v d="$(dirname "$current_dir")" '$0 == d "/" $NF')
    if [ -n "$fdres" ]; then
      local c=$(echo "$fdres" | wc -l)
      if [ "$c" -eq 1 ]; then
        cd "$fdres"
        found=1
        break
      else
        local r=$(echo "$fdres" | fzf-tmux -p)
        if [ -n "$r" ]; then
          cd "$r"
          found=1
          break
        fi
      fi
    fi
    current_dir=$(dirname "$current_dir")
  done
  if [ "$found" -eq 0 ]; then
    local fdres=$(fd --type d --hidden --exclude '.git' --exclude '.npm' "$@" "/")
    if [ -n "$fdres" ]; then
      local c=$(echo "$fdres" | wc -l)
      if [ "$c" -eq 1 ]; then
        cd "$fdres"
      else
        local r=$(echo "$fdres" | fzf-tmux -p)
        if [ -n "$r" ]; then
          cd "$r"
        fi
      fi
    else
        echo "No results $@"
    fi
  fi
}

cdx() {
  local count=$1
  if [[ ! "$count" =~ ^[0-9]+$ ]]; then
    echo "cdx: Argument must be a positive integer."
    return 1
  fi

  local current_dir=$(pwd)

  for ((i = 0; i < count; i++)); do
    if [[ "$current_dir" == "/" ]]; then
      echo "cdx: Already at root directory."
      return 1
    fi
    current_dir=$(dirname "$current_dir")
    cd "$current_dir"
  done
}

yy() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

# https://direnv.net/docs/hook.html#zsh
eval "$(direnv hook zsh)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Node Modules
# This neeeds to come after nvm
# so that it always prefers the local version
export PATH="node_modules/.bin:$PATH"

export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/gcr/ssh"

# Google Cloud CLI
export PATH="/opt/google-cloud-cli/bin:$PATH"

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

[[ -d $HOME/.local/bin ]] && export PATH="$HOME/.local/bin:$PATH"

# rustup
. "$HOME/.cargo/env"

# sesh
function sesh-sessions() {
  {
    exec </dev/tty
    exec <&1
    local session
    session=$(sesh list --icons | fzf-tmux -p 80%,70% \
      --no-sort --ansi --border-label ' sesh ' --prompt '⚡  ' \
      --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find' \
      --bind 'tab:down,btab:up' \
      --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list -t -c)' \
      --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t)' \
      --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c)' \
      --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z)' \
      --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
      --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list -t -c)' \
      --preview-window 'right:55%' \
      --preview 'sesh preview {}')
    zle reset-prompt > /dev/null 2>&1 || true
    [[ -z "$session" ]] && return
    sesh connect $session
  }
}

bindkey -s '^k' 'sesh-sessions\n'

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

# Init zoxide
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
  alias cd='z'
fi
