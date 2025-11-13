#!/usr/bin/env bash

if ! command -v sshuttle &> /dev/null; then
    echo "sshuttle is not installed. Please install it and try again."
    exit 1
fi

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 user@remote_server"
    exit 1
fi

sudo sshuttle -r "$1" 0/0
