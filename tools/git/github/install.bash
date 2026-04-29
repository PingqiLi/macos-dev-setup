#!/usr/bin/env bash
set -euo pipefail

source "${DOTFILES}/tools/shell/bash/utils.bash"

info "🐙 Installing gh"
brew bundle --file="${DOTFILES}/tools/git/github/Brewfile"

debug "🔗 Symlinking gh configuration"
bash "${DOTFILES}/tools/github/symlinks/link.bash"
