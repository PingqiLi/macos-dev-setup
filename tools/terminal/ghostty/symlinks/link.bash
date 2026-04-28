#!/usr/bin/env bash
set -euo pipefail

source "${DOTFILES}/tools/terminal/ghostty/utils.bash"
source "${DOTFILES}/tools/shell/bash/utils.bash"

symlink "${DOTFILES}/tools/terminal/ghostty/config/config" "${TOOL_CONFIG_DIR}"
