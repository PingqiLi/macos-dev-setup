#!/usr/bin/env zsh

# In case this file is sourced before shell variables have been symlinked
export DOTFILES="${HOME}/Projects/macos-dev-setup"

handle_error() {
  local exit_code="$1"
  local line_number="$2"
  printf "\nError on line $line_number: Command exited with status $exit_code.\n"
  exit "$exit_code"
}

# Trap ERR signals and call handle_error()
trap 'handle_error $? $LINENO' ERR

###########
# CONFIRM #
###########

printf "\nWelcome to your new Mac! This installation will perform the following steps:\n\n"
printf "1. Confirm this is a Mac\n"
printf "2. Ask you to enter your password\n"
printf "3. Confirm the Command Line Developer Tools are installed\n"
printf "4. Clone macos-dev-setup\n"
printf "5. Create your SSH keys\n"
printf "6. Confirm you can SSH to GitHub\n"
printf "7. Install Homebrew\n"
printf "8. Configure your Mac to use the Homebrew version of Zsh\n"
printf "9. Install uv (Python)\n"
printf "10. Install the latest version of Node via fnm and set it as the default\n"
printf "11. Install global npm dependencies\n"
printf "12. Install tmux dependencies\n"
printf "13. Install all tool modules (Brewfiles + per-tool setup)\n"
printf "14. Symlink your dotfiles to your home and library directories\n"
printf "15. Apply macOS system settings\n\n"

vared -p "Sound good? (y/N) " -c key

if [[ ! "$key" == 'y' ]]; then
  printf "\nNo worries! Maybe next time."
  printf "\nExiting..."
  exit 1
else
  printf "\nExcellent! Here we go...\n\n"
fi

#################
# PREREQUISITES #
#################

printf "Verifying prerequisites...\n\n"

printf "Confirming this is a Mac...\n"
if [ "$(uname)" != "Darwin" ]; then
  printf "Oops, it looks like this is a non-UNIX system. This script only works on a Mac.\n\nExiting..."
  exit 1
fi
printf "This is a Mac. But you knew that already.\n\n"

# Command Line Tools check (critical for git clone)
if ! command -v git >/dev/null 2>&1; then
  printf "❌ Git is not installed. Please install Command Line Developer Tools first.\n"
  printf "Run: xcode-select --install\n"
  exit 1
fi
printf "✅ Git is available for cloning dotfiles.\n\n"

# You know this Mac's password
printf "Confirming you are authorized to install things on this Mac...\n\n"
sudo -v
# Keep-alive: update existing `sudo` time stamp until setup has finished
while true; do
  sudo -n true
  sleep 60
  kill -0 "$$" || exit
done 2>/dev/null &
printf "Yup. That's the password.\n\n"

##################
# CLONE DOTFILES #
##################

if [ -d "$DOTFILES" ]; then
  printf "📂 Dotfiles are already installed. Pulling latest changes.\n"
  cd "$DOTFILES"
  git pull
else
  printf "📂 Installing dotfiles"
  mkdir -p "$(dirname "$DOTFILES")"
  git clone "https://github.com/PingqiLi/macos-dev-setup.git" "$DOTFILES"
fi

####################
# INSTALL + UPDATE #
####################

DOTINSTALL="${DOTFILES}/features/install/zsh"

source "${DOTINSTALL}/ssh.zsh"
source "${DOTINSTALL}/github.zsh"
source "${DOTINSTALL}/homebrew.zsh"
source "${DOTINSTALL}/zsh.zsh"
source "${DOTINSTALL}/uv.zsh"
source "${DOTINSTALL}/node.zsh"
source "${DOTINSTALL}/npm.zsh"
source "${DOTINSTALL}/tmux.zsh"
source "${DOTINSTALL}/tools.zsh"
source "${DOTINSTALL}/symlinks.zsh"
source "${DOTINSTALL}/macos.zsh"

###################
# SUGGEST RESTART #
###################

info "🎉 Setup complete!"

printf "\nCongratulations! Your Mac is nearly set up.\n\n"
printf "To apply all preferences, your computer needs to restart.\n\n"

vared -p "Are you ready to restart now (recommended)? (y/N) " -c restart_choice

if [[ "$restart_choice" = 'y' ]]; then
  printf "\nExcellent choice.\n"
  printf "\nRestarting..."
  sudo shutdown -r now
else
  printf "\nNo worries! Your terminal session will now refresh...\n"
  exec -l "$SHELL"
fi
