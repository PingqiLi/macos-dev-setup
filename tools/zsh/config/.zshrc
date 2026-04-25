# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n] confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export DOTFILES="${HOME}/Projects/macos-dev-setup"

source "${DOTFILES}/tools/zsh/utils.zsh" # have, is_work, info, etc
source "${DOTFILES}/tools/zsh/config/core.zsh" # env, history, completions, aliases
source "${DOTFILES}/tools/zsh/config/hooks.zsh" # python venv activation
source "${DOTFILES}/tools/zsh/config/tools.zsh" # tool-specific configs via manifest

# zoxide must be initialized AS THE VERY LAST LINE of .zshrc — that's
# what its doctor warning insists on. (Otherwise other plugins can
# clobber its precmd / chpwd hooks.)
have zoxide && eval "$(zoxide init zsh)"
