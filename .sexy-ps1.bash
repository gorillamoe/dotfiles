function color_my_prompt {
        local defaults="\[\033[38;5;2m\]: )"
        # defaults to green color
        local git_branch_color="\[\033[38;1;2m\]"
        local git_dirty=0
        if [[ $(git diff HEAD 2> /dev/null | grep -e ^*) != "" ]]; then
                git_dirty=0
                echo foo
                # if is dirty make it red
                git_branch_color="\[\033[31m\]"
        fi
        local git_branch='`git branch 2> /dev/null | grep -e ^* | sed -E  s/^\\\\\*\ \(.+\)$/\(\\\\\1\)\ /`'
        local last_color="\[\033[00m\]"
        export PS1="$defaults$git_branch_color$git_branch$last_color "
}
color_my_prompt
