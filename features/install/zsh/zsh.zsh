#!/usr/bin/env zsh

info "🐚 Configuring zsh shell"

# Use the Homebrew version of Zsh
shell_path="/opt/homebrew/bin/zsh"

# Install brew zsh if not present
if [[ ! -x "$shell_path" ]]; then
  printf "\n🍺 Installing zsh via Homebrew...\n"
  brew install zsh
fi

if [[ ! -x "$shell_path" ]]; then
  printf "\n❌ Failed to install zsh at ${shell_path}. Please try again.\n"
  exit 1
fi

if ! grep "$shell_path" /etc/shells > /dev/null 2>&1 ; then
  printf "\n📄 Adding '${shell_path}' to /etc/shells\n"
  sudo sh -c "echo ${shell_path} >> /etc/shells"
fi

printf "\n🐚 Changing your shell to $shell_path...\n"
sudo chsh -s "$shell_path" "$USER"

printf "\n🚀 Done configuring zsh shell.\n"
