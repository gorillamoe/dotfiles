# Set the directory where we want to store zinit and the plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download and install zinit if it's not already installed
if [[ ! -d $ZINIT_HOME ]]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "$ZINIT_HOME/zinit.zsh"

# lazy load nvm
export NVM_LAZY_LOAD=true

zinit wait lucid for \
 atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
    zdharma-continuum/fast-syntax-highlighting \
    zdharma-continuum/history-search-multi-word \
 blockf \
    zsh-users/zsh-completions \
 atload"bindkey '^n' autosuggest-accept" \
    zsh-users/zsh-autosuggestions \
    lukechilds/zsh-nvm

zstyle :plugin:history-search-multi-word reset-prompt-protect 1
zstyle ':completion:*' menu select
