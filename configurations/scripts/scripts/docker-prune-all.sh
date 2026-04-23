#!/usr/bin/env bash

# Notifies me
# Usage: some-long-running-task && notify-me.sh "happy" "Long Running Task Done"

set -o errexit
set -o pipefail

OUTPUT=$(docker system prune -a -f --volumes)
RECLAIMED_SPACE=$(echo "${OUTPUT}" | tail -1)
notify-me.sh "happy" "Docker Prune All - ${RECLAIMED_SPACE} Reclaimed" "Docker Prune Done"
