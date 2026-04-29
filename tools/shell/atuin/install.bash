#!/usr/bin/env bash
set -euo pipefail
source "${DOTFILES}/tools/shell/bash/utils.bash"
info "📦 Installing atuin"
brew bundle --file="${DOTFILES}/tools/shell/atuin/Brewfile"
