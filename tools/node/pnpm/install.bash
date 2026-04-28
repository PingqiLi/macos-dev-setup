#!/usr/bin/env bash
set -euo pipefail
source "${DOTFILES}/tools/shell/bash/utils.bash"
info "📦 Installing pnpm"
brew bundle --file="${DOTFILES}/tools/pnpm/Brewfile"
