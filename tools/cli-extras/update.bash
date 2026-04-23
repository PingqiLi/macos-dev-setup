#!/usr/bin/env bash
set -euo pipefail
source "${DOTFILES}/tools/bash/utils.bash"
info "🧰 Updating CLI extras"
brew upgrade atuin direnv yq tree pnpm gnu-sed coreutils
