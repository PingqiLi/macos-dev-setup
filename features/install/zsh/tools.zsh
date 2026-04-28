#!/usr/bin/env zsh
# Run install.bash for every tool that has one, skipping _bootstrap (handled separately).

source "${DOTFILES}/tools/shell/bash/utils.bash"

info "🧩 Installing all tool modules"

for install_script in "${DOTFILES}"/tools/*/*/install.bash; do
  group=$(basename "$(dirname "$(dirname "${install_script}")")")
  tool_name=$(basename "$(dirname "${install_script}")")
  [[ "$group" == "_bootstrap" ]] && continue
  printf "\n→ [%s] Installing %s...\n" "${group}" "${tool_name}"
  bash "${install_script}"
done
