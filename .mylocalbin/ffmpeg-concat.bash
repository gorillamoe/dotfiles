#!/bin/bash

get_all_files() {
        local argc=$#
        local argv=($@)
        for (( j=0; j<argc-1; j++ )); do
                echo file $PWD/${argv[j]}
        done
}

main() {
        local argc=$#
        local argv=($@)
        ffmpeg -f concat -safe 0 -i <(get_all_files "$@") -c copy "${argv[$argc-1]}"
}

main "$@"