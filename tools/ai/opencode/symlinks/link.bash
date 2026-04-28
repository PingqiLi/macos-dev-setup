#!/usr/bin/env bash
set -euo pipefail

source "${DOTFILES}/tools/ai/opencode/utils.bash"
source "${DOTFILES}/tools/shell/bash/utils.bash"

mkdir -p "${TOOL_CONFIG_DIR}"
symlink "${DOTFILES}/tools/ai/opencode/config/opencode.json" "${TOOL_CONFIG_DIR}"
symlink "${DOTFILES}/tools/ai/opencode/config/oh-my-opencode.json" "${TOOL_CONFIG_DIR}"
symlink "${DOTFILES}/tools/ai/opencode/config/oh-my-opencode.openrouter-fallback.json" "${TOOL_CONFIG_DIR}"
symlink "${DOTFILES}/tools/ai/opencode/config/package.json" "${TOOL_CONFIG_DIR}"
symlink "${DOTFILES}/tools/ai/opencode/config/switch-to-openrouter.sh" "${TOOL_CONFIG_DIR}"

if [ -d "${DOTFILES}/tools/ai/opencode/config/skills" ]; then
  symlink "${DOTFILES}/tools/ai/opencode/config/skills" "${TOOL_CONFIG_DIR}"
fi
