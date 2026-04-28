#!/usr/bin/env bash
set -euo pipefail

source "${DOTFILES}/tools/git/git/utils.bash"
source "${DOTFILES}/tools/shell/bash/utils.bash"

symlink "${DOTFILES}/tools/git/git/config/config" "${TOOL_CONFIG_DIR}"
symlink "${DOTFILES}/tools/git/git/config/config.work" "${TOOL_CONFIG_DIR}"
