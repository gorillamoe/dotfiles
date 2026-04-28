#!/usr/bin/env bash

# Description: Prune all Docker resources and notify the user of the reclaimed space.
# Usage: docker-prune-all.sh

set -o errexit
set -o pipefail

OUTPUT=$(docker system prune -a -f --volumes)
RECLAIMED_SPACE=$(echo "${OUTPUT}" | tail -1)
notify-me.sh "happy" "${RECLAIMED_SPACE}" "Docker Prune Done"
