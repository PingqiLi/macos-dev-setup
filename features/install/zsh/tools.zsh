#!/usr/bin/env zsh
# Run install.bash for every tool that has one.

source "${DOTFILES}/tools/shell/bash/utils.bash"

info "🧩 Installing all tool modules"

for install_script in "${DOTFILES}"/tools/*/install.bash; do
  tool_name=$(basename "$(dirname "${install_script}")")
  printf "\n→ Installing %s...\n" "${tool_name}"
  bash "${install_script}"
done
