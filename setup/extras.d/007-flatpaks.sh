#!/usr/bin/env bash

xargs -a ./setup/extras.d/flatpaks.txt flatpak install -y
