#!/usr/bin/env bash
set -euo pipefail
source "${DOTFILES}/tools/bash/utils.bash"
info "🌐 Installing browsers"
brew bundle --file="${DOTFILES}/tools/browsers/Brewfile"
