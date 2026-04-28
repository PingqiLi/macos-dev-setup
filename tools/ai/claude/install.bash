#!/usr/bin/env bash
set -euo pipefail

source "${DOTFILES}/tools/shell/bash/utils.bash"

info "🤖 Installing claude-code"

if ! command -v npm >/dev/null 2>&1; then
  echo "❌ npm not found. Install Node first (via fnm)."
  exit 1
fi

npm install -g @anthropic-ai/claude-code

brew install terminal-notifier
