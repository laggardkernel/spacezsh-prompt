#
# Spaceship ZSH
#
# Author: Denys Dovhan, denysdovhan.com
# License: MIT
# https://github.com/denysdovhan/spaceship-prompt

# Current version of Spaceship
# Useful for issue reporting
export SPACESHIP_VERSION="3.11.1"

# Determination of Spaceship working directory
# https://git.io/vdBH7
if [[ -z "$SPACESHIP_ROOT" ]]; then
  if [[ "${(%):-%N}" == '(eval)' ]]; then
    if [[ "$0" == '-antigen-load' ]] && [[ -r "${PWD}/spaceship.zsh" ]]; then
      # Antigen uses eval to load things so it can change the plugin (!!)
      # https://github.com/zsh-users/antigen/issues/581
      export SPACESHIP_ROOT=$PWD
    else
      print -P "%F{red}You must set SPACESHIP_ROOT to work from within an (eval).%f"
      return 1
    fi
  else
    # Get the path to file this code is executing in; then
    # get the absolute path and strip the filename.
    # See https://stackoverflow.com/a/28336473/108857
    export SPACESHIP_ROOT=${${(%):-%x}:A:h}
  fi
fi

# ------------------------------------------------------------------------------
# ENTRY POINT
# An entry point of prompt
# ------------------------------------------------------------------------------

spaceship::selfdestruct_setup() {
  # Test if we already autoloaded the functions
  (( ${fpath[(I)"${SPACESHIP_ROOT}/lib/autoload"]} )) || {
    fpath+=("${SPACESHIP_ROOT}/lib/autoload")
  }

  # remove self from precmd
  precmd_functions=("${(@)precmd_functions:#spaceship::selfdestruct_setup}")
  builtin unfunction spaceship::selfdestruct_setup

  # Helper functions
  autoload -Uz +X spaceship::env

  # Setup
  autoload -Uz +X prompt_spaceship_setup
  autoload -Uz +X promptinit 2>&1 >/dev/null && {
    promptinit
    prompt spaceship
  } || {
    prompt_spaceship_setup
  }
  prompt_spaceship_precmd
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd spaceship::selfdestruct_setup
fpath+=("${SPACESHIP_ROOT}/lib/autoload")
autoload -Uz +X prompt_spaceship_setup
