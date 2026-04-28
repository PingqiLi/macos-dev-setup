#!/usr/bin/env bash
set -euo pipefail

source "${DOTFILES}/tools/shell/bash/utils.bash"

info "👻 Updating ghostty"
brew bundle --file="${DOTFILES}/tools/ghostty/Brewfile"
