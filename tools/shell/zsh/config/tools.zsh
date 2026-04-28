# Add tool-specific environment variables, aliases and completions to zsh environment

# Source all shell config files from features and tools (excluding @new and @archive)
while IFS= read -r file; do
  source "$file"
done < <(find "${DOTFILES}/features" "${DOTFILES}/tools" \
  \( -name '@new' -o -name '@archive' \) -prune -o \
  \( -name 'shell.zsh' -o -path '*/shell/variables.zsh' -o -path '*/shell/aliases.zsh' -o -path '*/shell/integration.zsh' \) \
  -print | sort)

###################################
# LEGACY: ONE-OFF VARIABLES SETUP #
###################################

# gRPC
# export GRPC_PYTHON_BUILD_SYSTEM_OPENSSL=1
# export GRPC_PYTHON_BUILD_SYSTEM_ZLIB=1

# NPM
export NPM_CONFIG_USERCONFIG=${HOME}/.config/npm/.npmrc

# OpenSSL
if have brew; then
  export PATH="/opt/homebrew/opt/openssl@3/bin:${PATH}"
  export CPPFLAGS="-I/opt/homebrew/opt/openssl@3/include"
  export LDFLAGS="-L/opt/homebrew/opt/openssl@3/lib"
  export PKG_CONFIG_PATH="/opt/homebrew/opt/openssl@3/lib/pkgconfig"
fi

# Python
export MYPYPATH="${HOME}"
export PYTHONPATH="${HOME}"
export VIRTUAL_ENV_PROMPT='' # avoid extra (venv) prompt prefix


