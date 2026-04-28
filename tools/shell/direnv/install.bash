#!/usr/bin/env bash
set -euo pipefail
source "${DOTFILES}/tools/shell/bash/utils.bash"
info "📦 Installing direnv"
brew bundle --file="${DOTFILES}/tools/direnv/Brewfile"
