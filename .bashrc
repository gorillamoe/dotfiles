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
# http://qq.is/article/ssh-keys-through-screen
SOCK="/tmp/ssh-agent-$USER-screen"
if test $SSH_AUTH_SOCK && [ $SSH_AUTH_SOCK != $SOCK ]
then
rm -f /tmp/ssh-agent-$USER-tmux
  ln -sf $SSH_AUTH_SOCK $SOCK
  export SSH_AUTH_SOCK=$SOCK
fi

# History Management
  export HISTTIMEFORMAT='%F %T '

# Various shorthand stuff
export PATH=$PATH:$HOME/bin
# Android Development and Debugging
export PATH=$PATH:/opt/android-sdk/tools/
export PATH=$PATH:/opt/android-sdk/platform-tools/
# Ruby
export PATH=$PATH:$HOME/.gem/ruby/2.2.0/bin
export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
# Go path
export GOPATH=$HOME/apps/go
export PATH=$PATH:$GOPATH/bin

# This is sexy, isn't it?
PS1="\[\e[01;48m\][\[\e[0m\]\[\e[01;34m\]\u\[\e[0m\]\[\e[01;36m\]@\[\e[0m\]\[\e[01;35m\]\h\[\e[0m\]\[\e[00;37m\] \[\e[0m\]\[\e[00;00m\]\W\[\e[0m\]\[\e[01;48m\]]\[\e[0m\]\[\e[00;31m\]\\$\[\e[0m\] "

# I <3 ViM
export EDITOR=vim
# .. and rxvt
export TERM="screen-256color"

if [ -n "$DISPLAY" ];then
  export BROWSER=/usr/bin/chromium
  # Who needs capslock anyway?
  # Remap capslock to escape
  setxkbmap -option caps:escape
fi

# I want it all! All colors belong to me!
alias 'tmux'='tmux -2'
alias 'ls'='ls --color=auto'
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
