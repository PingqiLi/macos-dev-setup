#!/usr/bin/env bash
set -euo pipefail
source "${DOTFILES}/tools/shell/bash/utils.bash"
info "🚂 Uninstalling opencode"
brew uninstall opencode
