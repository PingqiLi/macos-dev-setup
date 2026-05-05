#!/usr/bin/env bash
set -euo pipefail

source "${DOTFILES}/tools/shell/bash/utils.bash"

info "🐳 Installing lazydocker"
brew bundle --file="${DOTFILES}/tools/containers/lazydocker/Brewfile"

debug "🔗 Symlinking lazydocker configuration"
bash "${DOTFILES}/tools/containers/lazydocker/symlinks/link.bash"
