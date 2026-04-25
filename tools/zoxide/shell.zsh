###########
# ALIASES #
###########

# Aliases below depend on zoxide being installed AND initialized.
# Guarding the whole block prevents `cd` becoming a broken alias when
# zoxide is missing (e.g. mid-bootstrap, or before the brew bundle ran).

if have zoxide; then
  eval "$(zoxide init zsh)"

  # Replace `cd` with smart `z` jumper.
  alias cd="z"

  # Quick jumps
  alias h="z ${HOME}"
  alias dot="z ${DOTFILES}"

  # Add your own project aliases here, e.g.:
  # alias proj="z ${HOME}/Projects/my-project"
fi
