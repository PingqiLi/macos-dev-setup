#!/usr/bin/env bash
set -euo pipefail

source "${DOTFILES}/tools/shell/bash/utils.bash"

info "📁 Updating zsh"
brew bundle --file="${DOTFILES}/tools/shell/zsh/Brewfile"

debug "🔗 Symlinking zsh configuration"
bash "${DOTFILES}/tools/shell/zsh/symlinks/link.bash"
