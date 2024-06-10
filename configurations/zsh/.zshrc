CONFIG_HOME="$HOME/.config/zsh"
SOURCE_DIR="$CONFIG_HOME/sourcing"

SOURCES_FILES=(
  "history"
  "zinit"
  "oh-my-posh"
  "path"
  "editor"
  "aliases"
  "functions"
)

for file in "${SOURCES_FILES[@]}"; do
  source "$SOURCE_DIR/$file.zsh"
done

