#!/usr/bin/env bash
set -euo pipefail

source "${DOTFILES}/tools/shell/bash/utils.bash"

info "🦇 Installing bat"
brew bundle --file="${DOTFILES}/tools/bat/Brewfile"
