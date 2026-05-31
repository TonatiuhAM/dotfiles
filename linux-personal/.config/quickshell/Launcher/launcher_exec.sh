#!/bin/bash
# Receives a shell command string and runs it detached from the launcher process.
# Variables like $XDG_CONFIG_HOME are expanded by the inner bash -c invocation.
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

nohup bash -c "$1" </dev/null >/dev/null 2>&1 &
disown
