#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Aliases
    # Start ssh-agent with x session
    # (bound to session -> max one per session)
    alias startx='ssh-agent startx'
    # make ls pretty
    alias ls='ls --color=auto'
    # SVN convenience commands
    alias svnst='svn st -u'
    alias svnco='svn commit'


PS1='\[\033[01;31m\]\u\[\033[01;37m\]@\[\033[01;32m\]\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
PATH=$PATH:/home/walialu/.gem/ruby/2.1.0/bin



# Predictable SSH authentication socket location.
# http://qq.is/article/ssh-keys-through-screen
SOCK="/tmp/ssh-agent-$USER-screen"
if test $SSH_AUTH_SOCK && [ $SSH_AUTH_SOCK != $SOCK ]
then
rm -f /tmp/ssh-agent-$USER-tmux
    ln -sf $SSH_AUTH_SOCK $SOCK
    export SSH_AUTH_SOCK=$SOCK
fi



export PATH



# I <3 ViM
export EDITOR=vim

# Display Systeminfo
archey3
