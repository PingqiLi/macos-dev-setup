#!/usr/bin/env bash
set -euo pipefail

source "${DOTFILES}/tools/bash/utils.bash"
source "${DOTFILES}/tools/opencode/utils.bash"

info "🚂 Installing opencode"
brew bundle --file="${DOTFILES}/tools/opencode/Brewfile"

# Install oh-my-opencode plugin SDK (bun install in ~/.config/opencode)
if command -v bun >/dev/null 2>&1; then
  mkdir -p "${TOOL_CONFIG_DIR}"
  cd "${TOOL_CONFIG_DIR}"
  bun install
fi
