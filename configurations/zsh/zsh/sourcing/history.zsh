
export HISTSIZE=50000
export SAVEHIST=50000
export HISTFILE=~/.zsh_history

# INFO:
# Do not write duplicate entries
setopt HIST_IGNORE_ALL_DUPS

# INFO:
# delete duplicates first, when HISTFILE exceeds HISTSIZE
setopt HIST_EXPIRE_DUPS_FIRST

# INFO:
# Even if there are duplicates,
# do not find them when searching history
setopt HIST_FIND_NO_DUPS

# NOTE:
# The following should be turned off,
# if sharing history via setopt SHARE_HISTORY

# INFO:
# It immediately writes the history to the file,
# instead of waiting for the shell to exit
setopt INC_APPEND_HISTORY

# INFO:
# Do not write lines starting
# with space to the history file
setopt HIST_IGNORE_SPACE

# INFO:
# Record time of command in history
setopt EXTENDED_HISTORY
