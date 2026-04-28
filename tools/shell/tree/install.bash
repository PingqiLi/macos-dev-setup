#!/usr/bin/env bash
set -euo pipefail
source "${DOTFILES}/tools/bash/utils.bash"
info "📦 Installing tree"
brew bundle --file="${DOTFILES}/tools/tree/Brewfile"
