#!/usr/bin/env bash
set -euo pipefail
source "${DOTFILES}/tools/shell/bash/utils.bash"
info "🔄 Updating pnpm"
brew upgrade pnpm
