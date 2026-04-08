# Basic Zsh configuration setup

## Add custom completions directory to FPATH
if [[ ":$FPATH:" != *":$HOME/.zsh/completions:"* ]]; then export FPATH="$HOME/.zsh/completions:$FPATH"; fi

## Define XDG_DATA_HOME if not already defined
### Makes it less repetitive to type later on
export XDG_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"
## Define XDG_CONFIG_HOME if not already defined
### Makes it less repetitive to type later on
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"

## Antigen, the GOAT of Zsh plugin managers
## Sadly, this can't be cached with evalcache,
## because antigen needs to be sourced before any antigen commands are run
source /usr/share/zsh/share/antigen.zsh

## Evalcache, the GOAT of caching for shell scripts
antigen bundle mroth/evalcache
antigen apply

# NOTE:
# I probobly should switch fully to Antigen at some point

## Zinit, IDK why I still use it alongside Antigen, but whatever

### Set the directory where we want to store zinit and the plugins
export ZINIT_HOME="${XDG_DATA_HOME}/zinit/zinit.git"

### Download and install zinit if it's not already installed
if [[ ! -d $ZINIT_HOME ]]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

### Don't cache this with evalcache
#### Must be sourced directly, but has built-in caching anyway
source "$ZINIT_HOME/zinit.zsh"

### Load zinit plugins
zinit wait lucid for \
  zdharma-continuum/fast-syntax-highlighting \
  zdharma-continuum/history-search-multi-word \
  blockf \
  zsh-users/zsh-completions \
  atload"bindkey '^n' autosuggest-accept" \
  zsh-users/zsh-autosuggestions

#------------------------------------------#

## Completion system MUST be initialized ONLY ONCE

### I tried multiple locations for this,
### this is the one that I found to be the most reliable
autoload -Uz compinit
compinit

compdef g=git

#------------------------------------------#
## JJ configuration, baseed on the current directory
setup_jj_config() {
    # Override jj config for specific directories, e.g., work projects
    if [[ "$PWD" == "$HOME/projects/work"* ]]; then export JJ_CONFIG="$HOME/.config/jj/config-work.toml"
    else export JJ_CONFIG="$HOME/.config/jj/config.toml"
    fi
}
setup_jj_config

#------------------------------------------#

## store the absolute path of the current directory.
### This is useful for custom widgets that need to know the current directory.
typeset -g ZSH_CWD="$PWD"

## Update ZSH_CWD on directory change
### Can add more logic here if needed in the future
function chpwd() {
    ZSH_CWD="$PWD"
    setup_jj_config
}

#------------------------------------------#

## Vim-like keybindings

### Edit command line in Neovim in the current working directory
#### C-XC-E opens the command line in Neovim by default,
#### but it opens it in the home directory by default,
#### which is not what I want.
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

#### Register the widget with Zsh's line editor
zle -N zle-edit-command-line-cwd

#### Bind the new widget to 'v' in vi command mode
##### so that pressing 'v' opens the command line in Neovim
bindkey -M vicmd v zle-edit-command-line-cwd

### Enable default vi keybindings
bindkey -v

### In vicmd, prevent j/k from falling back to history at buffer edges
### (arrow keys still works)
bindkey -M vicmd 'k' up-line
bindkey -M vicmd 'j' down-line

### Set cursor shape based on mode, blinking block for command mode, blinking bar for insert mode
#### This is just sprinkling some extra UX goodness, but I'm a sucker for that
export VI_MODE_SET_CURSOR=true

### Function to set cursor shape based on keymap
#### Works in wezterm, might work in other terminals as well
function set-cursor-shape {
  case $KEYMAP in
    vicmd)
      print -n -- $'\e[2 q'
      ;;
    *)
      print -n -- $'\e[5 q'
      ;;
  esac
}

#### Function to be called on keymap change
function zle-keymap-select {
  set-cursor-shape
  zle -R
}

#### Register the function as a ZLE widget
zle -N zle-keymap-select

#### Call the function before each prompt
function precmd {
  set-cursor-shape
}

#------------------------------------------#

## Keybindings in general

### Vim-like keybindings for inserting the last word of the previous command
#### Inspired by bash's Alt + . behavior
#### Doesn't usually work in vi mode by default, so we need to define it ourselves

#### Bind Alt + . for Insert mode
bindkey -M viins '^[.' insert-last-word

#### 2. Bind Alt + . for Command mode
bindkey -M vicmd '^[.' insert-last-word

### Keybindings for working for wezterm, possibly others

## Home/End behavior
## - In multiline buffers, beginning/end-of-line only affects the current line.
##   Use custom widgets to jump to start/end of the whole input.
## - Bind in both vi insert/command keymaps, and cover common escape sequences.
function zle-home-buffer {
  CURSOR=0
}
function zle-end-buffer {
  CURSOR=$#BUFFER
}
zle -N zle-home-buffer
zle -N zle-end-buffer

# Tell zsh-syntax-highlighting these widgets are fine (avoids warnings).
typeset -gA ZSH_HIGHLIGHT_WIDGETS
ZSH_HIGHLIGHT_WIDGETS+=(zle-home-buffer none zle-end-buffer none)

for km in viins vicmd; do
  # terminfo-aware (preferred when available)
  [[ -n ${terminfo[khome]-} ]] && bindkey -M $km "${terminfo[khome]}" zle-home-buffer
  [[ -n ${terminfo[kend]-}  ]] && bindkey -M $km "${terminfo[kend]}"  zle-end-buffer

  # common xterm/wezterm sequences
  bindkey -M $km "^[[H"  zle-home-buffer   # Home
  bindkey -M $km "^[[F"  zle-end-buffer    # End
  bindkey -M $km "^[[1~" zle-home-buffer   # Home
  bindkey -M $km "^[[4~" zle-end-buffer    # End
  bindkey -M $km "^[[7~" zle-home-buffer   # Home (rxvt)
  bindkey -M $km "^[[8~" zle-end-buffer    # End  (rxvt)

  # Delete key, delete character under cursor
  bindkey -M $km "^[[3~" delete-char
done

#------------------------------------------#

## Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  # I would use nvim over vi for remote sessions,
  # but nvim is not always available on remote systems
  # so we fall back to vi, which is hopefully always available
  export EDITOR='vi'
else
  export EDITOR='nvim'
fi

#------------------------------------------#

## History configuration

### Increase history size, to a maximum of 50000 entries
export HISTSIZE=50000
export SAVEHIST=50000

### Define history file location
export HISTFILE=~/.zsh_history

### Do not write duplicate entries
setopt HIST_IGNORE_ALL_DUPS

### delete duplicates first, when HISTFILE exceeds HISTSIZE
setopt HIST_EXPIRE_DUPS_FIRST

### Even if there are duplicates, do not find them when searching history
setopt HIST_FIND_NO_DUPS

### Do not write lines starting with space to the history file
setopt HIST_IGNORE_SPACE

### Record time of command in history
setopt EXTENDED_HISTORY

### Enable multi-word history search plugin settings
zstyle :plugin:history-search-multi-word reset-prompt-protect 1

# NOTE:
# Share history between all sessions immediately
# Therefore INC_APPEND_HISTORY and APPEND_HISTORY must be unset
# In fact it is "immediately" in quotation marks,
# because you still need to press enter once to have the command
# appear in the other session's history
# but that is good enough for me
setopt SHARE_HISTORY
unsetopt INC_APPEND_HISTORY
unsetopt APPEND_HISTORY

#------------------------------------------#

## Prompt configuration

### oh-my-posh, the GOAT of prompts
#### Install oh-my-posh if not already installed
if ! command -v oh-my-posh &> /dev/null; then
  curl -s https://ohmyposh.dev/install.sh | bash -s
fi

#### Cache oh-my-posh init for faster startups
 _evalcache oh-my-posh init zsh --config $XDG_CONFIG_HOME/oh-my-posh/default.toml

#------------------------------------------#

## Path settings
### It would be great, if all these tools would align on a common standard,
### but alas, that is not the case in late 2025... 😥

### Cargo (Rust), the Rust package manager -- https://www.rust-lang.org/tools/install
export PATH="$HOME/.cargo/bin:$PATH"

### Go, the gopher language -- https://golang.org
#### Did I mention that this is my second favorite language after TypeScript?
export GOPATH="$HOME/go"
export PATH="$HOME/bin:/usr/local/bin:/usr/local/go/bin:$GOPATH/bin:$PATH"

### Bun, the all-in-one JavaScript runtime -- https://bun.com
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

### Node Modules, the JavaScript ecosystem -- https://nodejs.org
export PATH="node_modules/.bin:$PATH"

### .NET tools, the Microsoft ecosystem -- https://dotnet.microsoft.com/en-us/download/dotnet/thank-you/sdk-7.0.400-linux-x64-installer
export PATH="$PATH:$HOME/.dotnet/tools"

### Google Cloud CLI
#### Google being exceptionally creative with installation paths
export PATH="/opt/google-cloud-cli/bin:$PATH"

### Local user binaries
#### Coming in last to have precedence over mostly everything else
[[ -d $HOME/.local/bin ]] && export PATH="$HOME/.local/bin:$PATH"

#------------------------------------------#

## Aliases

### File and directory listing with eza
alias 'ls'='eza --icons=always'
alias 'll'='eza -la --icons=always --group-directories-first'

### Git shorthand
#### git alias that shows status if no arguments are given
g() {
  if [ "$#" -eq 0 ]; then
    git status
    return
  fi
  git "$@"
}

### Neovim as default editor
#### My muscle memory still prefers vim and vi 🤷
alias 'vim''=nvim'
alias 'vi'='nvim'

### Open files with default application
#### TBH, I rarely use this alias, but it is nice to have it around
alias 'gopen'='xdg-open'

### bat alias if batcat is available
#### On some distributions (e.g., Debian/Ubuntu), the binary is named batcat
if command -v batcat &> /dev/null; then
  alias 'bat'='batcat'
fi

### fd alias if fdfind is available
#### On some distributions (e.g., Debian/Ubuntu), the binary is named fdfind
if command -v fdfind &> /dev/null; then
  alias 'fd'='fdfind'
fi

### Yazi alias that also changes directory if needed
#### Opens yazi and on exit changes directory to the one selected in yazi
yy() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

### Simple yazi alias
alias 'y'='yazi'

#------------------------------------------#

## Source environment scripts
### utilize evalcache for caching

### Mise, the minimalistic shell environment manager
_evalcache mise activate zsh

### Direnv
#### Supercharge your DX, automatically load and unload environment variables
#### https://direnv.net/docs/hook.html#zsh
_evalcache direnv hook zsh

### Zoxide, a smarter cd command
_evalcache zoxide init zsh

# Bun, the all-in-one JavaScript runtime
[ -s "$HOME/.bun/_bun" ] && _evalcache cat "$HOME/.bun/_bun"

### Rustup
#### Preferered way to install and manage Rust toolchains
[[ -d $HOME/.cargo/env ]] && _evalcache cat "$HOME/.cargo/env"

### Deno
[[ -d $HOME/.deno/env ]] && _evalcache cat "$HOME/.deno/env"

# PNPM, the performant JavaScript package manager
export PNPM_HOME="/home/marco/.local/share/pnpm"
[[ -d $HOME/.local/share/pnpm ]] && export PATH="$PNPM_HOME:$PATH"

# Vite+ bin (https://viteplus.dev)
[[ -d $HOME/.vite-plugs/env ]] && _evalcache cat "$HOME/.vite-plugs/env"

### Zana, the niche CLI for managing LSP servers, DAP servers, linters, and formatters
#### Source as late as possible, so it can has precedence over other things in PATH
_evalcache zana env zsh
#### Completions
_evalcache zana completion zsh

### Kuba, the GOAT of using cloud secrets in your environment
#### https://kuba.mwco.app
_evalcache kuba completion zsh

#------------------------------------------#

## Exports

### LS_COLORS using vivid
#### used by ls, eza, also by fzf for colored previews,
#### carapace for colored completions, etc.
export LS_COLORS=$(vivid generate dracula)

### Needed for SSH agent to pick up the correct socket
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/gcr/ssh"

### fzf configuration
#### Set default options to use Ctrl-T for toggling all items
export FZF_DEFAULT_OPTS='--bind ctrl-t:toggle-all'

# INFO:
# Carapace must come AFTER basically everything that has completions
# because it overrides them otherwise
# or my configurations are somehow broken otherwise 🤪

### Carapace, the GOAT of completion engines
export CARAPACE_BRIDGES='zsh,bash,inshellisense'
#### This enables the menu selection for completions
zstyle ':completion:*' menu select group-order 'main commands' 'alias commands' 'external commands'
#### This enables colored completions
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS} "ma=48;5;206;38;5;0"
#### Initialize carapace with evalcache for caching
_evalcache carapace _carapace

#------------------------------------------#

## Custom scripts path

### My own scripts take precedence over everything 🥷
[[ -d $HOME/.local/scripts ]] && export PATH="$HOME/.local/scripts:$PATH"

