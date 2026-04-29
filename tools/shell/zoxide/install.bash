#!/usr/bin/env bash
set -euo pipefail

source "${DOTFILES}/tools/shell/bash/utils.bash"

info "⚡ Installing zoxide"
brew bundle --file="${DOTFILES}/tools/shell/zoxide/Brewfile"
