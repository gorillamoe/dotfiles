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

alias ","="cd \$(fd --type d --hidden --exclude \'.git\' --exclude \'.npm\' | fzf-tmux -p)"
,,() {
  local r=$(fd --type f --hidden --exclude '.git' --exclude '.npm' | fzf-tmux -p)
  local dn=$(dirname $r)
  local fn=$(realpath -s --relative-to=$dn $r)
  cd $dn
  nvim $fn
}
