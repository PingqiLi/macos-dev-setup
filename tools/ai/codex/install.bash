#!/usr/bin/env bash
set -euo pipefail

source "${DOTFILES}/tools/shell/bash/utils.bash"

info "🤖 Installing codex"
brew bundle --file="${DOTFILES}/tools/ai/codex/Brewfile"
