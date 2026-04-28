#!/usr/bin/env bash
set -euo pipefail
source "${DOTFILES}/tools/shell/bash/utils.bash"
info "🐳 Installing orbstack"
brew bundle --file="${DOTFILES}/tools/orbstack/Brewfile"
