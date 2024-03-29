#!/usr/bin/env zsh
#
# Author: Denys Dovhan, denysdovhan.com
#

# ------------------------------------------------------------------------------
# Colors
# Set color variables for colorful output
# ------------------------------------------------------------------------------

# If we have tput, let's set colors
if [[ ! -z $(which tput 2> /dev/null) ]]; then
  reset=$(tput sgr0)
  bold=$(tput bold)
  red=$(tput setaf 1)
  green=$(tput setaf 2)
  yellow=$(tput setaf 3)
  blue=$(tput setaf 4)
  magenta=$(tput setaf 5)
  cyan=$(tput setaf 6)
fi

# ------------------------------------------------------------------------------
# VARIABLES
# Paths to important resources
# ------------------------------------------------------------------------------

ZSHRC="${ZDOTDIR:-$HOME}/.zshrc"
USER_SOURCE="${ZDOTDIR:-$HOME}/.spacezsh-prompt"
GLOBAL_DEST="/usr/local/share/zsh/site-functions/prompt_spacezsh_setup"
USER_DEST="${ZDOTDIR:-$HOME}/.zfunctions/prompt_spacezsh_setup"

# ------------------------------------------------------------------------------
# HELPERS
# Useful functions for common tasks
# ------------------------------------------------------------------------------

# Paint text in specific color with reset
# USAGE:
#   paint <color> [text...]
paint() {
  local color=$1 rest=${@:2}
  echo "$color$rest$reset"
}

# Aliases for common used colors
# Colon at the end is required: https://askubuntu.com/a/521942
# USAGE:
#   info|warn|error|success|code [...text]
info()    { paint "$cyan"   "SPACESHIP: $@" ; }
warn()    { paint "$yellow" "SPACESHIP: $@" ; }
error()   { paint "$red"    "SPACESHIP: $@" ; }
success() { paint "$green"  "SPACESHIP: $@" ; }
code()    { paint "$bold"   "SPACESHIP: $@" ; }

# Check if symlink is exists and remove it
# USAGE:
#   rmln <target>
rmln() {
  local target=$1
  if [[ -L "$target" ]]; then
    info "Removing $target..."
    rm -f "$target"
  fi
}

# ------------------------------------------------------------------------------
# MAIN
# Checkings and uninstalling process
# ------------------------------------------------------------------------------

remove_zshrc_content() {
  info "Removing Spaceship from \"${ZDOTDIR:-$HOME}/.zshrc\""
  # Remove enabling statements from .zshrc
  # and remove Spaceship configuration
  # Note: SPACESHIP_RPROMPT_ORDER and SPACESHIP_PROMPT_ORDER configuration may have multiple lines
  # which are grouped by `(`, `)`
  sed '/^# Set Spaceship ZSH as a prompt$/d' "$ZSHRC" | \
  sed '/^autoload -U promptinit; promptinit$/d' | \
  sed '/^prompt spacezsh$/d' | \
  sed  -E '/^SPACESHIP_R?PROMPT_ORDER=\([^)]*$/,/^[^(]*\)/d' | \
  sed '/^SPACESHIP_.*$/d' > "$ZSHRC.bak" && \
  mv -- "$ZSHRC.bak" "$ZSHRC"
}

main() {
  # Remove $GLOBAL_DEST symlink
  if [[ -L "$GLOBAL_DEST" || -L "$USER_DEST" ]]; then
    rmln "$GLOBAL_DEST"
    rmln "$USER_DEST"
  else
    warn "Symlinks to Spaceship are not found."
  fi

  # Remove Spaceship from .zshrc
  if command grep -q "spacezsh" "$ZSHRC"; then
    if [[ '-y' == $1 ]]; then
      remove_zshrc_content
    else
      read "answer?Would you like to remove you Spaceship ZSH configuration from .zshrc? (y/N)"
      if [[ 'y' == ${answer:l} ]]; then
        remove_zshrc_content
      fi
    fi
  else
    warn "Spaceship configuration not found in \"${ZDOTDIR:-$HOME}/.zshrc\"!"
  fi

  success "Done! Spaceship installation has been removed!"
  success "Please, reload your terminal."
}

main "$@"
