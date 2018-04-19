#!/bin/bash
set -euo pipefail
IFS=$'\n'

# Example usage:
# total-go-coverage.bash $(go list ./pkg/... | grep -v /static)

main() {
        local file
        local pack
        local coverage
        local coverage_int
        local linedata
        local notestfiles
        local tmptestfilecontents
        local tmptestfile
        local countfilelines
        local packcounterlines=0
        local totalpacks=0
        local totalpackspercentage=0
        local total_packs_normalized_weight=0
        local total_packs_lines=0
        # Create test files where-ever they're missing..
        for linedata in $(go test "$@" -cover | grep "[no test files]"); do
                pack=$(echo "$linedata" | awk -F '\t' '{print $2}')
                for notestfiles in $(find ../"$pack" -type f -name '*.go' -not -name '*_test.go'); do
                        tmptestfile=${notestfiles/.go/_test.go}
                        if [[ ! -f "$tmptestfile" ]]; then
                                # Get current package
                                tmptestfilecontents=$(cat "$notestfiles" | grep "package " | head -1)
                                echo "$tmptestfilecontents" >> "$tmptestfile"
                        fi
                done
        done
        for linedata in $(go test "$@" -cover | grep "coverage:"); do
                packcounter=0
                pack=$(echo "$linedata" | awk -F '\t' '{print $2}')
                coverage=$(echo "$linedata" | awk -F '\t' '{print $4}')
                coverage_int=$(echo "$coverage" | sed  's/coverage: \([0-9]\{1,3\}\)\.[0-9]\{0,1\}% of .*/\1/')
                for countfilelines in $(find ../"$pack" -type f -name '*.go' -not -name '*_test.go'); do
                        packcounterlines=$((packcounter+$(wc -l "$countfilelines" | awk -F ' ' '{print $1}')))
                done
                totalpacks=$((totalpacks+1))
                total_packs_normalized_weight=$((packcounterlines*coverage_int/100+total_packs_normalized_weight))
                total_packs_lines=$((total_packs_lines+packcounterlines))
        done
        echo "Checked: $@"
        echo Total coverage: $((total_packs_normalized_weight*100/total_packs_lines))%
}

main "$@"

