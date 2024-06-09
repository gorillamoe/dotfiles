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
  local gr
  local dn
  local fn
  local fdres
  local c
  fdres=$(fd --type f --hidden --exclude '.git' --exclude '.npm' "$@")
  if [ -z "$fdres" ]; then
    echo "No results"
    return
  fi
  c=$(echo $fdres | wc -l)
  if [ $c -eq 1 ]; then
    dn=$(dirname $fdres)
    fn=$(realpath -s --relative-to=$dn $fdres)
    cd $dn
    gr=$(git rev-parse --show-toplevel 2> /dev/null)
    if [ -z "$gr" ]; then # no git root detected
      nvim $fn
    else # git root detected, open file relative to git root
      dn="$gr"
      cd $dn
      fdres=$(fd --type f --hidden --exclude '.git' --exclude '.npm' "$@")
      fn=$(realpath -s --relative-to=$dn $fdres)
      nvim $fn
    fi
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
