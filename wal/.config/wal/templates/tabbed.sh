#!/usr/bin/env bash

background={background}
foreground={foreground}
color1={color1}

tabbed -t "$background" -T "$color1" -u "$background" -U "$foreground" -c $*
