#!/usr/bin/env bash
set -euo pipefail

source "${DOTFILES}/tools/shell/bash/utils.bash"

info "⚡ Installing powerlevel10k"
brew bundle --file="${DOTFILES}/tools/shell/powerlevel10k/Brewfile"

debug "🔗 Symlinking powerlevel10k configuration"
bash "${DOTFILES}/tools/shell/powerlevel10k/symlinks/link.bash"
