#!/usr/bin/env bash
set -euo pipefail

source "${DOTFILES}/tools/shell/bash/utils.bash"

info "📝 Installing git"
brew bundle --file="${DOTFILES}/tools/git/git/Brewfile"

debug "🔗 Symlinking git configuration"
bash "${DOTFILES}/tools/git/symlinks/link.bash"
