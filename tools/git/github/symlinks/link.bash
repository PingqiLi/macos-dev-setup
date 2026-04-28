#!/usr/bin/env bash
set -euo pipefail

source "${DOTFILES}/tools/git/github/utils.bash"
source "${DOTFILES}/tools/shell/bash/utils.bash"

symlink "${DOTFILES}/tools/git/github/config/config.yml" "${TOOL_CONFIG_DIR}"
