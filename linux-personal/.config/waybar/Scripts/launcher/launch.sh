#!/usr/bin/env bash

# Terminate already running bar instances
# If all your bars have ipc enabled, you can use
# polybar-msg cmd quit
# Otherwise you can use the nuclear option:
hyprctl reload
pypr reload
killall -9 waybar
swaync-client -R && swaync-client -rs

waybar &
