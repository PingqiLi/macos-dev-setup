#!/usr/bin/env bash
set -euo pipefail

source "${DOTFILES}/tools/apps/vscode/utils.bash"
source "${DOTFILES}/tools/shell/bash/utils.bash"

symlink "${DOTFILES}/tools/apps/vscode/config/keybindings.json" "${TOOL_CONFIG_DIR}"
symlink "${DOTFILES}/tools/apps/vscode/config/settings.json" "${TOOL_CONFIG_DIR}"
symlink "${DOTFILES}/tools/apps/vscode/config/snippets" "${TOOL_CONFIG_DIR}"
