#!/usr/bin/env bash
set -euo pipefail

source "${DOTFILES}/tools/shell/bash/utils.bash"

info "🐚 Installing zsh"
brew bundle --file="${DOTFILES}/tools/zsh/Brewfile"

debug "🔗 Symlinking zsh configuration"
bash "${DOTFILES}/tools/zsh/symlinks/link.bash"
