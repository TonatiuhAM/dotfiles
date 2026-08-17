#!/bin/bash
# Launches a shell command via Hyprland 0.55+ Lua dispatch API.
# exec_cmd is forked directly by Hyprland, which associates the resulting
# window with the active workspace at dispatch time — fixing workspace placement.
# Lua long-string [[ ]] syntax accepts any content without quoting issues.
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

hyprctl dispatch "hl.dsp.exec_cmd([[$1]])"
