#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Switch to HTTP tmux session
# @raycast.mode silent

if ! tmux has-session -t http 2>/dev/null; then
    ~/.config/tmux/scripts/px "$HOME/Desktop/http" 2>/dev/null || true
fi
~/.config/tmux/scripts/tmux-switch-session http
open -a Ghostty
