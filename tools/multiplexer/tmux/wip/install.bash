#!/usr/bin/env bash

# Tmux installation script
# Installs tmux plugin manager (tpm) and tmux plugins
#
# This script:
# 1. Installs tmux plugin manager (tpm) if not present
# 2. Installs all tmux plugins via tpm
# 3. Configures terminfo settings (optional/disabled by default)

set -euo pipefail

# Configuration
DOTFILES="${DOTFILES:-$HOME/Repos/ooloth/dotfiles}"

# Load utilities
source "${DOTFILES}/tools/multiplexer/tmux/utils.bash"

main() {
    echo "🍱 Installing tmux and plugins..."
    echo ""

    # Check if tmux is available
    if ! command -v tmux >/dev/null 2>&1; then
        echo "⚠️  Tmux is not installed. Please install tmux first."
        echo "   You can install it via Homebrew: brew install tmux"
        return 1
    fi

    # Install tpm (tmux plugin manager)
    echo "🍱 Installing tmux plugin manager (tpm)..."
    if install_tpm; then
        echo "✅ tpm installed successfully"
    else
        echo "❌ Failed to install tpm"
        return 1
    fi

    # Install tmux plugins
    echo "🔌 Installing tmux plugins..."
    if install_tmux_plugins; then
        echo "✅ Tmux plugins installed successfully"
    else
        echo "❌ Failed to install tmux plugins"
        return 1
    fi

    # Optional: Install terminfo configurations
    # Note: These are commented out as they may not be needed for modern setups
    # if install_terminfo_configs; then
    #     echo "✅ Terminfo configurations installed"
    # else
    #     echo "⚠️  Failed to install terminfo configurations"
    # fi

    echo ""
    echo "🍱 Tmux setup completed"
    echo ""
    echo "💡 Next steps:"
    echo "   - Restart your terminal or reload tmux config: tmux source ~/.config/tmux/tmux.conf"
    echo "   - Press prefix + I in tmux to install plugins (if not done automatically)"
}

# Only run main if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
