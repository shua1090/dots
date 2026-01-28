#!/bin/bash

kitty --class screensaver --override remember_window_size=no -e cmatrix &
sleep 1
hyprctl dispatch fullscreen 1
