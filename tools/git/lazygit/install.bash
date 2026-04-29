#!/usr/bin/env bash
set -euo pipefail

source "${DOTFILES}/tools/shell/bash/utils.bash"

info "🔀 Installing lazygit"
brew bundle --file="${DOTFILES}/tools/git/lazygit/Brewfile"

debug "🔗 Symlinking lazygit configuration"
bash "${DOTFILES}/tools/lazygit/symlinks/link.bash"
