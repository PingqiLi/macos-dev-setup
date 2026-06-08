# Login-shell init. Sourced after .zshenv, before .zshrc (login shells only).
# GLOBAL_RCS is unset in .zshenv, so /etc/zprofile is skipped — put global
# login setup that must run before interactive config here.

# Homebrew: put /opt/homebrew/bin on PATH (and set MANPATH/INFOPATH). The
# interactive config in core.zsh relies on `have brew`, so this must run first.
eval "$(/opt/homebrew/bin/brew shellenv)"

# JetBrains Toolbox CLI launchers
export PATH="${PATH}:${HOME}/Library/Application Support/JetBrains/Toolbox/scripts"
