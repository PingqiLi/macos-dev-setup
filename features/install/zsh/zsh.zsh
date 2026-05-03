#!/usr/bin/env zsh

info "🐚 Configuring zsh shell"

# Use the Homebrew version of Zsh
shell_path="/opt/homebrew/bin/zsh"

# Check if Zsh is installed
if [[ ! -x "$shell_path" ]]; then
  printf "\n❌ Zsh not found at ${shell_path}. Installing Zsh via Homebrew...\n"
  source "$DOTFILES/features/install/zsh/homebrew.zsh"

  # Check if Zsh is now installed
  if [[ ! -x "$shell_path" ]]; then
    printf "\n❌ Failed to install Zsh. Please try again.\n"
    exit 1
  else
    printf "\n✅ Zsh installed successfully.\n"
  fi
fi

if ! grep "$shell_path" /etc/shells > /dev/null 2>&1 ; then
  printf "\n📄 Adding '${shell_path}' to /etc/shells\n"
  sudo sh -c "echo ${shell_path} >> /etc/shells"
fi

printf "\n🐚 Changing your shell to $shell_path...\n"
sudo chsh -s "$shell_path" "$USER"

printf "\n🚀 Done configuring zsh shell.\n"
