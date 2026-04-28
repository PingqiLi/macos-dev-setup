#!/usr/bin/env bash
set -euo pipefail
source "${DOTFILES}/tools/bash/utils.bash"
info "🌐 Uninstalling browsers"
brew uninstall --cask google-chrome microsoft-edge
