#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return
# Start ssh-agent with x session
# (bound to session -> max one per session)
alias startx='ssh-agent startx'
/usr/bin/xrdb -merge $HOME/.Xresources

# Predictable SSH authentication socket location.
# https://wiki.archlinux.org/index.php/SSH_keys#ssh-agent
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
  ssh-agent > ~/.ssh-agent-thing
fi
if [[ "$SSH_AGENT_PID" == "" ]]; then
  eval "$(<~/.ssh-agent-thing)" &>/dev/null
fi

# History Management
  export HISTTIMEFORMAT='%F %T '

# Various shorthand stuff
export PATH=$PATH:$HOME/bin
# Android Development and Debugging
export PATH=$PATH:$HOME/Android/Sdk/tools
export PATH=$PATH:$HOME/Android/Sdk/platform-tools
# Ruby
export PATH=$PATH:$HOME/.gem/ruby/2.3.0/bin
export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
# Go path
export GOPATH=$HOME/apps/go
export PATH=$PATH:$GOPATH/bin
# PHP Composer Executables Path
export PATH=$PATH:$HOME/.config/composer/vendor/bin

# This is sexy, isn't it?
PS1="\[\033[38;5;2m\]\w: ) \[\033[38;5;15m\]\[$(tput sgr0)\]"

# Saves a lot of tab presses for me!
# Found here:
# http://stackoverflow.com/questions/8917480/bash-completion-how-to-get-rid-of-unneeded-tab-presses
bind 'set show-all-if-ambiguous on'

# I <3 ViM
export EDITOR=nvim
# .. and rxvt
export TERM="screen-256color"

if [ -n "$DISPLAY" ];then
  export BROWSER=/usr/bin/chromium
  # Who needs capslock anyway?
  # Remap capslock to escape
  setxkbmap -option caps:escape
fi

# I want it all! All colors belong to me!
alias 'vim'='nvim'
alias 'vi'='nvim'
alias 'tmux'='tmux -2'
alias 'll'='ls -la'
alias '..'='cd ..'
alias 'fuck'='$(thefuck $(fc -ln -1))'

function 1080p-dl () { 
    _filename=$(youtube-dl --get-filename ${1});
    youtube-dl -o 'a.m4a' -f 140 "${1}";
    youtube-dl -o 'v.mp4' -f 137 "${1}";
    ffmpeg -i "v.mp4" -i "a.m4a" \
        -c:v copy -c:a copy \
        "${_filename}" \
        && rm a.m4a v.mp4
}

# CommaCD
# See: https://github.com/shyiko/commacd
source ~/.commacd.bash
alias t='todo.sh -d ~/.todo.cfg'
export TODOTXT_DEFAULT_ACTION=ls

# Auto CD into directory by typing its name
# Source: https://apple.stackexchange.com/questions/55412/cd-to-a-directory-by-typing-its-name
shopt -s autocd

# Gets the last downloaded file
# Source: http://blog.jpalardy.com/posts/get-your-last-downloaded-file/
ldf() {  # stands for "last downloaded file"
  local file=$HOME/Downloads/$(/usr/bin/ls -1t ~/Downloads/ | head -n1)
  read -p "confirm: $file "
  mv "$file" .
}

alias ls=exa
