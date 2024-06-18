#!/usr/bin/env bash

TEXT="";
TOOLTIP="DND is enabled";

if dunstctl is-paused | grep -q "false" ; then
  TEXT="";
  TOOLTIP="Notifications are enabled";
fi

printf '{"text": "%s", "tooltip": "%s"}\n' "$TEXT" "$TOOLTIP"

