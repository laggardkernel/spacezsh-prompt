#!/usr/bin/env zsh
# vim: ft=zsh fdm=marker foldlevel=0 sw=2 ts=2 sts=2 et
#
# Spacezsh

# Current version of Spacezsh
export SPACESHIP_VERSION="4.4.0"

### Installation location
# https://git.io/vdBH7
if [[ -z "$SPACESHIP_ROOT" ]]; then
  if [[ "${(%):-%N}" == '(eval)' ]]; then
    if [[ "$0" == '-antigen-load' ]] && [[ -r "${PWD}/spacezsh.zsh" ]]; then
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

### ENTRY POINT

sz::selfdestruct_setup() {
  # Test if we already autoloaded the functions
  (( ${fpath[(I)"${SPACESHIP_ROOT}"]} )) || {
    fpath+=("${SPACESHIP_ROOT}/lib/setups")
    fpath+=("${SPACESHIP_ROOT}/lib/utils")
    fpath+=("${SPACESHIP_ROOT}/sections")
  }

  # remove self from precmd
  precmd_functions=("${(@)precmd_functions:#sz::selfdestruct_setup}")
  builtin unfunction sz::selfdestruct_setup

  # Setup
  autoload -Uz +X prompt_spacezsh_setup
  autoload -Uz +X promptinit &>/dev/null && {
    promptinit
    prompt spacezsh
  } || {
    prompt_spacezsh_setup
  }
  prompt_spacezsh_preexec
  prompt_spacezsh_precmd
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd sz::selfdestruct_setup
