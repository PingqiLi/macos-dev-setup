#!/usr/bin/env bash
set -euo pipefail

source "${DOTFILES}/tools/shell/bash/utils.bash"

info "🔍 Installing fzf"
brew bundle --file="${DOTFILES}/tools/fzf/Brewfile"
