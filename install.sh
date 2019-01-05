#!/usr/bin/env bash

for dir in */; do
    stow "$dir"
done
