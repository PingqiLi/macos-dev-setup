#!/usr/bin/env bash
set -euo pipefail

source "${DOTFILES}/tools/shell/bash/utils.bash"

info "📊 Uninstalling btop"
brew uninstall --formula btop

debug "🔗 Unlinking btop configuration"
bash "${DOTFILES}/tools/btop/symlinks/unlink.bash"
