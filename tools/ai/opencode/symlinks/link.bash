#!/usr/bin/env bash
set -euo pipefail

source "${DOTFILES}/tools/opencode/utils.bash"
source "${DOTFILES}/tools/shell/bash/utils.bash"

mkdir -p "${TOOL_CONFIG_DIR}"
symlink "${DOTFILES}/tools/${TOOL_LOWER}/config/opencode.json" "${TOOL_CONFIG_DIR}"
symlink "${DOTFILES}/tools/${TOOL_LOWER}/config/oh-my-opencode.json" "${TOOL_CONFIG_DIR}"
symlink "${DOTFILES}/tools/${TOOL_LOWER}/config/oh-my-opencode.openrouter-fallback.json" "${TOOL_CONFIG_DIR}"
symlink "${DOTFILES}/tools/${TOOL_LOWER}/config/package.json" "${TOOL_CONFIG_DIR}"
symlink "${DOTFILES}/tools/${TOOL_LOWER}/config/switch-to-openrouter.sh" "${TOOL_CONFIG_DIR}"

if [ -d "${DOTFILES}/tools/${TOOL_LOWER}/config/skills" ]; then
  symlink "${DOTFILES}/tools/${TOOL_LOWER}/config/skills" "${TOOL_CONFIG_DIR}"
fi
