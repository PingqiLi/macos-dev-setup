#!/usr/bin/env bash
set -euo pipefail

source "${DOTFILES}/tools/shell/bash/utils.bash"

info "📊 Updating btop"
brew bundle --file="${DOTFILES}/tools/shell/btop/Brewfile"

debug "🔗 Symlinking btop configuration"
bash "${DOTFILES}/tools/btop/symlinks/link.bash"
