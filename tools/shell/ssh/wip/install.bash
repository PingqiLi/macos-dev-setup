#!/usr/bin/env bash

# SSH installation script
# Handles SSH key generation, configuration, and agent setup
#
# This script:
# 1. Generates SSH keys if not present
# 2. Creates/updates SSH config file
# 3. Adds keys to ssh-agent
# 4. Adds keys to macOS Keychain

set -euo pipefail

# Configuration
DOTFILES="${DOTFILES:-$HOME/Repos/ooloth/dotfiles}"

# Load utilities
source "${DOTFILES}/tools/shell/ssh/utils.bash"

main() {
    echo "🔑 Installing SSH key pair"
    echo ""
    
    # Check for existing SSH keys
    echo "🔍 Checking for existing SSH keys"
    
    if detect_ssh_keys; then
        # Keys found, exit early
        return 0
    fi
    
    # Generate new SSH keys
    echo ""
    echo "✨ Generating a new 2048-bit RSA SSH public/private key pair."
    
    if generate_ssh_keys; then
        echo ""
        echo "✅ SSH key pair generated successfully."
    else
        echo ""
        echo "❌ Failed to generate SSH key pair."
        return 1
    fi
    
    # Create/update SSH config file
    echo ""
    echo "📄 Creating SSH config file"
    
    local ssh_config="$HOME/.ssh/config"
    
    if [[ -f "$ssh_config" ]]; then
        echo ""
        echo "✅ SSH config file found. Checking contents..."
        
        if ssh_config_has_required_settings "$ssh_config"; then
            echo ""
            echo "✅ SSH config file contains all the expected settings."
        else
            echo ""
            echo "❌ SSH config file does not contain all the expected settings. Updating..."
            create_ssh_config "$ssh_config"
            echo ""
            echo "✅ SSH config file updated."
        fi
    else
        echo "SSH config file does not exist. Creating..."
        create_ssh_config "$ssh_config"
        echo ""
        echo "✅ SSH config file created."
    fi
    
    # Add key to SSH agent and Keychain
    echo ""
    echo "🔑 Adding SSH key pair to ssh-agent and Keychain"
    
    if add_ssh_key_to_agent; then
        echo ""
        echo "✅ SSH key added successfully."
    else
        echo ""
        echo "❌ Failed to add SSH key to agent."
        return 1
    fi
    
    echo ""
    echo "🚀 Done configuring your SSH key pair."
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
