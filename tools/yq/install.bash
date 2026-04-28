#!/usr/bin/env bash
set -euo pipefail
source "${DOTFILES}/tools/bash/utils.bash"
info "📦 Installing yq"
brew bundle --file="${DOTFILES}/tools/yq/Brewfile"
