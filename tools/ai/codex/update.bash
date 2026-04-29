#!/usr/bin/env bash
set -euo pipefail

source "${DOTFILES}/tools/shell/bash/utils.bash"

info "🤖 Updating codex"
brew bundle --file="${DOTFILES}/tools/ai/codex/Brewfile"
