function color_my_prompt {
        # unicode "✗"
        local fancyx='\342\234\227'
        # unicode "✓"
        local fancycheckmark='\342\234\223'
        local color_red="$(tput setaf 1)"
        local color_green="$(tput setaf 2)"
        local color_yellow="$(tput setaf 3)"
        local color_blue="$(tput setaf 4)"
        local color_cyan="$(tput setaf 5)"
        local color_brightblue="$(tput setaf 6)"
        local color_grey="$(tput setaf 7)"
        local last_color="\[\033[00m\]"
        local defaults_text="$color_red\u$color_yellow@$color_blue\h$color_cyan2:$color_cyan\W"
        # local git_icon=""
        # local git_branch_color=""
        # local git_branch=""
        # if [[ $(git diff HEAD 2> /dev/null) == "" ]]; then
        #         # everything okay
        #         git_branch_color="$(tput setaf 2)"
        #         git_icon=$fancycheckmark
        # else
        #         # if is dirty make it red
        #         git_branch_color="$(tput setaf 1)"
        #         git_icon=$fancyx
        # fi
        # git_branch='`git branch 2> /dev/null | grep -e ^* | sed -E  s/^\\\\\*\ \(.+\)$/\ \(\\\\\1\)\ /`'
        export PS1="$defaults_text$color_green\$$last_color "
}
color_my_prompt
