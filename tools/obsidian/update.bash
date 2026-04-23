#!/usr/bin/env bash
set -euo pipefail
source "${DOTFILES}/tools/bash/utils.bash"
info "📝 Updating obsidian"
brew upgrade --cask obsidian
