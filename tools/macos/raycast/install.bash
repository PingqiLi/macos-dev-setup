#!/usr/bin/env bash
set -euo pipefail

source "${DOTFILES}/tools/shell/bash/utils.bash"

info "🚀 Installing raycast"
brew bundle --file="${DOTFILES}/tools/macos/raycast/Brewfile"
