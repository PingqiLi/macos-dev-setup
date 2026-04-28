#!/usr/bin/env bash
set -euo pipefail

source "${DOTFILES}/tools/tmux/utils.bash"
source "${DOTFILES}/tools/shell/bash/utils.bash"

symlink "${DOTFILES}/tools/${TOOL_LOWER}/config/gitmux.conf" "${TOOL_CONFIG_DIR}"
symlink "${DOTFILES}/tools/${TOOL_LOWER}/config/tmux.conf" "${TOOL_CONFIG_DIR}"
