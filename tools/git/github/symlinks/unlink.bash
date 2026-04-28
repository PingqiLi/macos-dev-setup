#!/usr/bin/env bash
set -euo pipefail

source "${DOTFILES}/tools/git/github/utils.bash"
source "${DOTFILES}/tools/shell/bash/utils.bash"

debug "🔗 Removing symlinked config files"
trash "${TOOL_CONFIG_DIR}"
