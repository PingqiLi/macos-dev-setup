#!/usr/bin/env bash
set -euo pipefail

source "${DOTFILES}/tools/macos/fcitx5/utils.bash"
source "${DOTFILES}/tools/shell/bash/utils.bash"

RIME_DIR="${TOOL_RIME_DIR}"
CONFIG_DIR="${TOOL_CONFIG_DIR}"

mkdir -p "${CONFIG_DIR}/conf"
mkdir -p "${RIME_DIR}"

# fcitx5 main config
symlink "${DOTFILES}/tools/macos/fcitx5/config/fcitx5/config"  "${CONFIG_DIR}"
symlink "${DOTFILES}/tools/macos/fcitx5/config/fcitx5/profile" "${CONFIG_DIR}"

# fcitx5 per-addon config
symlink "${DOTFILES}/tools/macos/fcitx5/config/fcitx5/conf/rime.conf"              "${CONFIG_DIR}/conf"
symlink "${DOTFILES}/tools/macos/fcitx5/config/fcitx5/conf/macosfrontend.conf"     "${CONFIG_DIR}/conf"
symlink "${DOTFILES}/tools/macos/fcitx5/config/fcitx5/conf/macosnotifications.conf" "${CONFIG_DIR}/conf"

# Rime user config
symlink "${DOTFILES}/tools/macos/fcitx5/config/rime/default.custom.yaml" "${RIME_DIR}"
