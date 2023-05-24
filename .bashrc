#!/usr/bin/env bash
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return
# Start ssh-agent with x session
# (bound to session -> max one per session)
alias startx='ssh-agent startx'

# Predictable SSH authentication socket location.
# https://wiki.archlinux.org/index.php/SSH_keys#ssh-agent
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    ssh-agent > "$XDG_RUNTIME_DIR/ssh-agent.env"
fi
if [[ ! "$SSH_AUTH_SOCK" ]]; then
    eval "$(<"$XDG_RUNTIME_DIR/ssh-agent.env")"
fi

# History Management
export HISTTIMEFORMAT='%F %T '
export HISTSIZE=9999

export EDITOR=nvim

export JAVA_HOME=/usr/lib/jvm/java-8-openjdk/

function color_my_prompt() {
  local color_red
  local color_green
  local color_yellow
  local color_blue
  local color_cyan
  local reset_color
  color_red=$(tput setaf 1)
  color_green=$(tput setaf 2)
  color_yellow=$(tput setaf 3)
  color_blue=$(tput setaf 4)
  color_cyan=$(tput setaf 5)
  reset_color=$(tput sgr 0)
  export PS1="\[$color_red\]\u\[$color_yellow\]@\[$color_blue\]\h\[$color_cyan2\]:\[$color_cyan\]\W\[$color_green\]\$\[$reset_color\] "
}
color_my_prompt

# Saves a lot of tab presses for me!
# Found here:
# http://stackoverflow.com/questions/8917480/bash-completion-how-to-get-rid-of-unneeded-tab-presses
bind 'set show-all-if-ambiguous on'

if [ -n "$DISPLAY" ];then
  export BROWSER=/usr/bin/google-chrome-stable
fi

# Add auto complete for minio client
complete -C /usr/bin/mc mc

source $HOME/.bash_aliases

export PATH="$PATH:$HOME/.bin"
export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:$HOME/.gem/ruby/2.7.0/bin"

# Nodemodules
export PATH="$PATH:./node_modules/.bin"

source /usr/share/nvm/init-nvm.sh

# BEGIN_KITTY_SHELL_INTEGRATION
if test -n "$KITTY_INSTALLATION_DIR" -a -e "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"; then source "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"; fi
# END_KITTY_SHELL_INTEGRATION

