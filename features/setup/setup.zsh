#!/usr/bin/env zsh

# Detect repo root from this script's location
DOTFILES="$(cd "$(dirname "$0")/../.." && pwd)"
export DOTFILES

handle_error() {
  local exit_code="$1"
  local line_number="$2"
  printf "\nError on line %s: Command exited with status %s.\n" "$line_number" "$exit_code"
  exit "$exit_code"
}

trap 'handle_error $? $LINENO' ERR

###########
# CONFIRM #
###########

printf "\nWelcome to your new Mac! This will:\n\n"
printf "1. Install Homebrew and switch the default shell to brew zsh\n"
printf "2. Install uv (Python), fnm + Node, global npm packages\n"
printf "3. Install all tool modules (Brewfiles + per-tool setup)\n"
printf "4. Symlink dotfiles to home and config directories\n"
printf "5. Apply macOS system settings\n\n"

vared -p "Sound good? (y/N) " -c key

if [[ ! "$key" == 'y' ]]; then
  printf "\nExiting.\n"
  exit 1
fi

printf "\nHere we go...\n\n"

#################
# PREREQUISITES #
#################

if [ "$(uname)" != "Darwin" ]; then
  printf "❌ This script only works on macOS.\n"
  exit 1
fi

if ! command -v git >/dev/null 2>&1; then
  printf "❌ Git not found. Run: xcode-select --install\n"
  exit 1
fi

printf "Confirming sudo access...\n"
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

####################
# INSTALL + UPDATE #
####################

source "${DOTFILES}/tools/shell/bash/utils.bash"

DOTINSTALL="${DOTFILES}/features/install/zsh"

source "${DOTINSTALL}/homebrew.zsh"
source "${DOTINSTALL}/zsh.zsh"
source "${DOTINSTALL}/uv.zsh"
source "${DOTINSTALL}/node.zsh"
source "${DOTINSTALL}/npm.zsh"
source "${DOTINSTALL}/tools.zsh"
source "${DOTINSTALL}/symlinks.zsh"
source "${DOTINSTALL}/macos.zsh"

###################
# SUGGEST RESTART #
###################

info "🎉 Setup complete!"

printf "\nTo apply all preferences, restart your computer.\n\n"

vared -p "Restart now? (y/N) " -c restart_choice

if [[ "$restart_choice" = 'y' ]]; then
  sudo shutdown -r now
else
  printf "\nRefreshing shell...\n"
  exec -l "$SHELL"
fi
