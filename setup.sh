#/bin/sh

# Simple Symlink-Script by Walialu
# walialu.com
# marcokellershoff.com
# Feel free to grab it and modify it without any restrictions!

EXCLUDED_FILES=("." ".." ".git" ".gitignore" "setup.sh" "readme.markdown")

contains_element () {
  local e
  for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 1; done
  return 0
}

WORKING_DIR=`pwd`

for file in `ls -a1`; do
    contains_element "$file" "${EXCLUDED_FILES[@]}";
    # if it is not one of the excluded files / dirs
    if [  $? == 0  ]; then
        # if it does not already exist
        if [ ! -e ~/$file ]; then
            ABS_FILEPATH=$WORKING_DIR/$file
            echo "ln -s " $ABS_FILEPATH ~/
            ln -s $ABS_FILEPATH ~/$file
        else
            echo "ERROR: File does already exist" ~/$file
        fi

    fi
done
