#!/usr/bin/env bash
set -euo pipefail
source "${DOTFILES}/tools/bash/utils.bash"
info "🌐 Updating browsers"
brew upgrade --cask google-chrome microsoft-edge
