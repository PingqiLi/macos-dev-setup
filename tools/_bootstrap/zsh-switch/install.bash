#!/usr/bin/env bash
set -euo pipefail

shell_path="/opt/homebrew/bin/zsh"

if [[ ! -x "$shell_path" ]]; then
  echo "❌ brew zsh not found. Install Homebrew first."
  exit 1
fi

if ! grep -q "$shell_path" /etc/shells; then
  echo "📄 Adding $shell_path to /etc/shells"
  sudo sh -c "echo ${shell_path} >> /etc/shells"
fi

if [[ "$SHELL" == "$shell_path" ]]; then
  echo "🐚 Already using brew zsh"
  exit 0
fi

echo "🐚 Switching default shell to $shell_path"
sudo chsh -s "$shell_path" "$USER"
echo "✅ Shell changed. Restart terminal to take effect."
