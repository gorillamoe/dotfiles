# Various shorthand stuff
export PATH=$PATH:$HOME/.mylocalbin
# Android Development and Debugging
export PATH=$PATH:$HOME/Android/Sdk/tools
export PATH=$PATH:$HOME/Android/Sdk/platform-tools
# Add node global path
 export PATH=~/.npm-global/bin:$PATH
# Add yarn binaries
export PATH=$PATH:$HOME/.yarn/bin
# Go path
export GOPATH=$HOME/code/go
export GOBIN=$GOPATH/bin
export PATH="$PATH:$GOBIN"
# PHP Composer Executables Path
export PATH=$PATH:$HOME/.config/composer/vendor/bin
export PATH="$HOME/.cargo/bin:$PATH"
# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
export GEM_HOME="$HOME/.gem/"
export GEM_PATH="$HOME/.gem/"
export PATH="$GEM_HOME:$PATH"
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

