#!/usr/bin/env bash
set -euo pipefail

source "${DOTFILES}/tools/shell/bash/utils.bash"

symlink "${DOTFILES}/tools/shell/btop/config/btop.conf" "${HOME}/.config/btop"
