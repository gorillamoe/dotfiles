#!/usr/bin/env bash

# Notifies me
# Usage: some-long-running-task && notify-me.sh "happy" "Long Running Task Done"

set -o errexit
set -o pipefail

VALID_ICONS=(
  "info"
  "error"
  "warning"
  "warn"
  "information"
  "smile"
  "happy"
  "sad"
  "angry"
)

ICON="${1:-"info"}"
MESSAGE="${2:-"Task Done"}"
APP_NAME="${3:-"Notify Me"}"

if [[ ! " ${VALID_ICONS[*]} " =~ [[:space:]]${ICON}[[:space:]] ]]; then
  ICON="dialog-information"
else
  if [[ "${ICON}" == "warn" ]] || [[ "${ICON}" == "warning" ]]; then ICON="dialog-warning"; fi
  if [[ "${ICON}" == "info" ]] || [[ "${ICON}" == "information" ]]; then ICON="dialog-information"; fi
  if [[ "${ICON}" == "smile" ]] || [[ "${ICON}" == "happy" ]]; then ICON="face-smile"; fi
  if [[ "${ICON}" == "sad" ]]; then ICON="face-sad"; fi
  if [[ "${ICON}" == "angry" ]]; then ICON="face-angry"; fi
fi

notify-send -i "${ICON}" -a "${APP_NAME}" "${MESSAGE}"
