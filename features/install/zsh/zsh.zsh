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
  printf "\n📄 Adding '%s' to /etc/shells\n" "$shell_path"
  sudo sh -c "echo ${shell_path} >> /etc/shells"
fi

current_shell="$(dscl . -read /Users/"$USER" UserShell 2>/dev/null | awk '{print $2}')"
if [[ "${current_shell}" == "${shell_path}" ]]; then
  printf "\n✅ Login shell already set to %s\n" "${shell_path}"
else
  printf "\n🐚 Changing your shell to %s...\n" "${shell_path}"
  sudo chsh -s "$shell_path" "$USER"
fi

printf "\n🚀 Done configuring zsh shell.\n"
