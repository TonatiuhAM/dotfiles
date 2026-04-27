#!/usr/bin/env bash

dir="/home/tona/.config/rofi/launchers"
theme='main-style-11'

## Run
rofi \
  -show drun \
  -theme ${dir}/${theme}.rasi
