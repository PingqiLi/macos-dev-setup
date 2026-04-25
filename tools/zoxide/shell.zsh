###########
# ALIASES #
###########

# Aliases below depend on zoxide. They reference the `z` command which is
# defined later by `zoxide init zsh` (called at the very end of ~/.zshrc).
# Aliases are resolved lazily at execution time so this ordering is fine.
#
# zoxide init itself is NOT done here — it must be the LAST line of
# ~/.zshrc per zoxide's recommendation, otherwise zoxide doctor warns
# that other plugins might override its hooks.

if have zoxide; then
  alias cd="z"
  alias h="z ${HOME}"
  alias dot="z ${DOTFILES}"

  # Add your own project aliases here, e.g.:
  # alias proj="z ${HOME}/Projects/my-project"
fi
