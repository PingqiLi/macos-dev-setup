#!/usr/bin/env bash
set -euo pipefail

source "${DOTFILES}/tools/git/lazygit/utils.bash"
source "${DOTFILES}/tools/shell/bash/utils.bash"

symlink "${DOTFILES}/tools/git/lazygit/config/config.yml" "${TOOL_CONFIG_DIR}"
