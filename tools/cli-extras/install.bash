#!/usr/bin/env bash
set -euo pipefail
source "${DOTFILES}/tools/bash/utils.bash"
info "🧰 Installing CLI extras"
brew bundle --file="${DOTFILES}/tools/cli-extras/Brewfile"
