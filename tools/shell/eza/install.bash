#!/usr/bin/env bash
set -euo pipefail

source "${DOTFILES}/tools/shell/bash/utils.bash"

info "📁 Installing eza"
brew bundle --file="${DOTFILES}/tools/eza/Brewfile"
