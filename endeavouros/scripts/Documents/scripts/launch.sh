#!/bin/bash

hyprctl reload
pypr reload
killall -9 waybar
swaync-client -R && swaync-client -rs

waybar &

