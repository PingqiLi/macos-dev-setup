#!/usr/bin/env bash
set -euo pipefail

source "${DOTFILES}/tools/shell/powerlevel10k/utils.bash"
source "${DOTFILES}/tools/shell/bash/utils.bash"

symlink "${DOTFILES}/tools/shell/powerlevel10k/config/p10k.zsh" "${TOOL_CONFIG_DIR}"
