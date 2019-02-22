#
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
  ssh-agent > ~/.ssh-agent-thing
fi
if [[ "$SSH_AGENT_PID" == "" ]]; then
  eval "$(<~/.ssh-agent-thing)" &>/dev/null
fi

# History Management
export HISTTIMEFORMAT='%F %T '
export HISTSIZE=9999
export HISTIGNORE="&:ls*:ll*::[bf]g:exit:pwd:clear:mount:umount:[ \\t]*:fg"

export EDITOR=nvim

# This is sexy, isn't it?
source "$HOME/.sexy-ps1.bash"

# Saves a lot of tab presses for me!
# Found here:
# http://stackoverflow.com/questions/8917480/bash-completion-how-to-get-rid-of-unneeded-tab-presses
bind 'set show-all-if-ambiguous on'

export TERM="xterm-256color"

if [ -n "$DISPLAY" ];then
  export BROWSER=/usr/bin/google-chrome-stable
  # Who needs capslock anyway?
  # Remap capslock to escape
  setxkbmap -option caps:escape
fi

# CommaCD
# See: https://github.com/shyiko/commacd
source ~/.commacd.bash
export TODOTXT_DEFAULT_ACTION=ls

# Auto CD into directory by typing its name
# Source: https://apple.stackexchange.com/questions/55412/cd-to-a-directory-by-typing-its-name
shopt -s autocd

switch_kubeconfig() {
        local kubeconfig_path=$(realpath $1)
        export KUBECONFIG=$kubeconfig_path
}

# fzf config start

export FZF_DEFAULT_COMMAND='fd --type f --color=never'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d . --color=never'
export FZF_DEFAULT_OPTS='--height 75% --multi --reverse --bind ctrl-f:page-down,ctrl-b:page-up'
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :500 {}'"
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -100'"
fzf_find_edit() {
        local file
        file=$(
        fzf --no-multi --preview 'bat --color=always --line-range :500 {}'
        )
        if [[ -n $file ]]; then
                "$EDITOR" "$file"
        fi
}

alias ffe='fzf_find_edit'

fzf_grep_edit(){
        if [[ $# == 0 ]]; then
                echo 'Error: search term was not provided.'
                return
        fi
        local match
        match=$(rg --color=never --line-number "$1" | fzf --no-multi --delimiter : --preview "bat --color=always --line-range {2}: {1}")
        local file
        file=$(echo "$match" | cut -d':' -f1)
        if [[ -n $file ]]; then
                "$EDITOR" "$file" +"$(echo "$match" | cut -d':' -f2)"
        fi
}

alias fge='fzf_grep_edit'

fzf_kill() {
        local pids
        pids=$(ps -f -u "$USER" | sed 1d | fzf --multi | tr -s "[:blank:]" | cut -d' ' -f3)
        if [[ -n $pids ]]; then
                echo "$pids" | xargs kill -9 "$@"
        fi
}

alias fkill='fzf_kill'

fzf_git_log() {
        local commits
        commits=$(git ll --color=always "$@" | fzf --ansi --no-sort --height 100% --preview "echo {} | grep -o '[a-f0-9]\{7\}' | head -1 | xargs -I@ sh -c 'git show --color=always @'")
        if [[ -n $commits ]]; then
                local hashes
                hashes=$(printf "$commits" | cut -d' ' -f2 | tr '\n' ' ')
                git show "$hashes"
        fi
}

alias gll='fzf_git_log'

fzf_git_reflog() {
        local hash
        hash=$(git reflog --color=always "$@" | fzf --no-multi --ansi --no-sort --height 100% --preview "git show --color=always {1}")
        echo "$hash"
}

alias grf='fzf_git_reflog'

fzf_git_log_pickaxe() {
        if [[ $# == 0 ]]; then
                echo 'Error: search term was not provided.'
                return
        fi
        local commits
        commits=$(git log --oneline --color=always -S "$@" | fzf --ansi --no-sort --height 100% --preview "git show --color=always {1}")
        if [[ -n $commits ]]; then
                local hashes
                hashes=$(echo "$commits" | cut -d' ' -f1 | tr '\n' ' ')
                git show "${hashes%% }"
        fi
}

alias glS='fzf_git_log_pickaxe'

 #fzf config end

# tmux config start

function tmux_send_keys_helper {
        tmux send-keys -t "$1" "${*:2}" enter
}

alias t='tmux_send_keys_helper'

# tmux config end

# git config start

if [ -f /usr/share/bash-completion/completions/git ]; then
        . /usr/share/bash-completion/completions/git
fi

function git_superevil_shorthand {
         if [[ $# == 0 ]]; then git status --short --branch; else git "$@"; fi 
}

alias g='git_superevil_shorthand'
complete -o default -o nospace -F _git g

# git config end

source $HOME/.bash_aliases

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:./node_modules/.bin"

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

