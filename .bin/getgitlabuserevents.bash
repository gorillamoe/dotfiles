#!/bin/bash
set -euo pipefail

get_useractivity() {
        local gitlab_base="https://git.intra.hadcs.de"
        local gitlab_private_token="zAgx-ShjMzm1yznJmu1L"
        local user_id="${1/./%2E}"
        local url="$gitlab_base/api/v4/users/$user_id/events"
        local res=$(curl --silent --header "PRIVATE-TOKEN: $gitlab_private_token" "$url")
        echo $res | jq .
        echo
}

main() {
        local user_id
        local user_ids="$(cat $1)"
        for user_id in $user_ids; do
                get_useractivity "$user_id"
        done
}

main "$@"

