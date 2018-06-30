#!/bin/bash

twitter_handle_avail() {
        local res=$(curl -Is https://twitter.com/"$1" | head -1 | awk '{print $2}')
        if [[ "$res" == "404" ]]; then
                echo -e "\e[1m$1\e[21m \e[32mavailable\e[0m"
        else
                echo -e "\e[1m$1\e[21m \e[31mnot available\e[0m"
        fi
}

main() {
        for handle in "$@"; do
                twitter_handle_avail "$handle"
        done
}

main "$@"
