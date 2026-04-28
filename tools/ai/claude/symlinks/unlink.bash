#!/usr/bin/env bash
set -euo pipefail

source "${DOTFILES}/tools/claude/utils.bash"
source "${DOTFILES}/tools/shell/bash/utils.bash"

debug "🔗 Removing symlinked config files"
trash "${TOOL_CONFIG_DIR}"
