#!/usr/bin/env bash

# Append aws env vars from add-this file to .bashrc and source it
# Manually upload add-this file with aws cloud9 ide before running this script
cp ~/.bashrc{,.bak} 
cat ~/add-this >> ~/.bashrc
source ~/.bashrc