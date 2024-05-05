alias ls='exa'

# I <3 Neovim
alias vim=nvim
alias vi=nvim

# easier sudo with env
alias 'sudoo'='sudo -E'

alias 'll'='exa -la'
alias '..'='cd ..'
alias 'gopen'='xdg-open'
if command -v batcat &> /dev/null; then
  alias 'bat'='batcat'
fi
if command -v fdfind &> /dev/null; then
  alias 'fd'='fdfind'
fi

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

,,() {
  local fdres=$(fd --type f --hidden --exclude '.git' --exclude '.npm' "$@")
  if [ -z "$fdres" ]; then
    echo "No results"
    return
  fi
  local c=$(echo $fdres | wc -l)
  # TODO find a clever way to cd into the directory that is the base
  # e.g. the one containing the .git directory
  if [ $c -eq 1 ]; then
    local dn=$(dirname $fdres)
    local fn=$(realpath -s --relative-to=$dn $fdres)
    cd $dn
    nvim $fn
  else
    local r=$(echo $fdres | fzf-tmux -p)
    if [ -z "$r" ]; then
      return
    fi
    local dn=$(dirname $r)
    local fn=$(realpath -s --relative-to=$dn $r)
    cd $dn
    nvim $fn
  fi
}
