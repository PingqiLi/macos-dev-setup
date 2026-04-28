#!/usr/bin/env bash
set -euo pipefail
source "${DOTFILES}/tools/shell/bash/utils.bash"
info "📝 Installing obsidian"
brew bundle --file="${DOTFILES}/tools/obsidian/Brewfile"
