#!/usr/bin/env bash
set -euo pipefail
source "${DOTFILES}/tools/shell/bash/utils.bash"
info "🌐 Uninstalling browsers"
brew uninstall --cask google-chrome microsoft-edge
