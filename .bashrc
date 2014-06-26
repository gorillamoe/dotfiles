#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return
# Start ssh-agent with x session
# (bound to session -> max one per session)
alias startx='ssh-agent startx'

# Who needs capslock anyway?
# Remap capslock to escape
setxkbmap -option caps:escape

export PATH=$PATH:/home/walialu/bin
export PATH=$PATH:/opt/android-sdk/tools/
export PATH=$PATH:/opt/android-sdk/platform-tools/
export PATH=$PATH:/home/walialu/.gem/ruby/2.1.0/bin

PS1="\[\e[00;37m\][\[\e[0m\]\[\e[00;32m\]\u\[\e[0m\]\[\e[00;35m\]@\[\e[0m\]\[\e[00;36m\]\h\[\e[0m\]\[\e[00;37m\] \[\e[0m\]\[\e[00;33m\]\W\[\e[0m\]\[\e[00;37m\]]\[\e[0m\]\[\e[00;31m\]\\$\[\e[0m\] "

# I <3 ViM
export EDITOR=vim

# I want it all! All colors belong to me!
alias tmux="tmux -2"
alias ls='ls --color=auto'
