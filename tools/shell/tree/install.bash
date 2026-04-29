#!/usr/bin/env bash
set -euo pipefail
source "${DOTFILES}/tools/shell/bash/utils.bash"
info "📦 Installing tree"
brew bundle --file="${DOTFILES}/tools/shell/tree/Brewfile"
