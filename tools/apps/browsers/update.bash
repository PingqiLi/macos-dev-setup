#!/usr/bin/env bash
set -euo pipefail
source "${DOTFILES}/tools/shell/bash/utils.bash"
info "🌐 Updating browsers"
brew upgrade --cask google-chrome microsoft-edge
