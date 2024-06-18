#!/usr/bin/env sh

SSH_AGENT_LAUNCHER=gnome-keyring
XDG_CURRENT_DESKTOP=sway

eval "$(/usr/bin/gnome-keyring-daemon --start)"

export SSH_AUTH_SOCK SSH_AGENT_LAUNCHER XDG_CURRENT_DESKTOP

systemctl --user import-environment \
  DBUS_SESSION_BUS_ADDRESS DISPLAY WAYLAND_DISPLAY SWAYSOCK

hash dbus-update-activation-environment 2>/dev/null

dbus-update-activation-environment --systemd \
  DBUS_SESSION_BUS_ADDRESS DISPLAY WAYLAND_DISPLAY SWAYSOCK \
  SSH_AUTH_SOCK XDG_CURRENT_DESKTOP
