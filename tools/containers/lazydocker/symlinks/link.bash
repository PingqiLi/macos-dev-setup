#!/usr/bin/env bash
set -euo pipefail

source "${DOTFILES}/tools/containers/lazydocker/utils.bash"
source "${DOTFILES}/tools/shell/bash/utils.bash"

symlink "${DOTFILES}/tools/containers/lazydocker/config/config.yml" "${TOOL_CONFIG_DIR}"
