#!/usr/bin/env bash
set -euo pipefail

source "${DOTFILES}/tools/multiplexer/tmux/utils.bash"
source "${DOTFILES}/tools/shell/bash/utils.bash"

symlink "${DOTFILES}/tools/multiplexer/tmux/config/gitmux.conf" "${TOOL_CONFIG_DIR}"
symlink "${DOTFILES}/tools/multiplexer/tmux/config/tmux.conf" "${TOOL_CONFIG_DIR}"
