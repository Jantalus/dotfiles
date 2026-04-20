#!/usr/bin/env bash
set -e

CONFIG="$HOME/.config"

# Make scripts executable
chmod +x "$CONFIG/tmux/scripts/"*

# Add tmux scripts to PATH if not already present
grep -qF '.config/tmux/scripts' ~/.zshrc \
  || echo 'export PATH="$HOME/.config/tmux/scripts:$PATH"' >> ~/.zshrc

echo "Done. Restart your shell or run: source ~/.zshrc"
