#!/usr/bin/env bash
set -euo pipefail
source "${DOTFILES}/tools/bash/utils.bash"
info "🐳 Updating orbstack"
brew upgrade --cask orbstack
