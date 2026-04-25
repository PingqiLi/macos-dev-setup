###########
# ALIASES #
###########

# Replace `cd` with smart `z` jumper.
alias cd="z"

# Quick jumps
alias h="z ${HOME}"
alias dot="z ${DOTFILES}"

# Add your own project aliases here, e.g.:
# alias proj="z ${HOME}/Projects/my-project"

###############
# COMPLETIONS #
###############

if have zoxide; then
  eval "$(zoxide init zsh)"
fi
