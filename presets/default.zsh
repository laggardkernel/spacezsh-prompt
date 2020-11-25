#!/usr/bin/env zsh
# vim: ft=zsh fdm=marker foldlevel=0 sw=2 ts=2 sts=2 et

# ------------------------------------------------------------------------------
# CONFIGURATION
# The default configuration that can be overridden in .zshrc
# ------------------------------------------------------------------------------

if [ -z "$SPACESHIP_PROMPT_ORDER" ]; then
  SPACESHIP_PROMPT_ORDER=(
    user               # Username section
    host               # Hostname section
    dir                # Current directory section
    vcs::async         # Version control system section (git, hg, svn)
    # git::async         # deprecated
    # hg::async          # deprecated

    # package::async     # Package version
    # node::async        # Node.js section
    # ruby::async        # Ruby section
    # elm::async         # Elm section
    # elixir::async      # Elixir section
    # xcode::async       # Xcode section
    # swift::async       # Swift section
    # golang::async      # Go section
    # php::async         # PHP section
    # rust::async        # Rust section
    # haskell::async     # Haskell Stack section
    # julia::async       # Julia section
    # vagrant::async     # Vagrant section
    # docker::async      # Docker section
    # aws                # Amazon Web Services section
    # gcloud::async      # Google Cloud Platform section
    # venv               # virtualenv section
    # conda              # conda virtualenv section
    # pyenv::async       # Pyenv section
    # dotnet::async      # .NET section
    # ember::async       # Ember.js section
    # kubectl::async     # Kubectl context section
    # terraform::async   # Terraform workspace section

    line_sep           # Line break
    # vi_mode           # deprecated
    char               # Prompt character, with vi-mode indicator integrated
  )
fi

if [ -z "$SPACESHIP_RPROMPT_ORDER" ]; then
  SPACESHIP_RPROMPT_ORDER=(
    exit_code     # Exit code section
    exec_time     # Execution time
    jobs          # Background jobs indicator
    battery       # Battery level and status
    time          # Time stampts section
  )
fi

# PROMPT
SPACESHIP_PROMPT_ADD_NEWLINE="${SPACESHIP_PROMPT_ADD_NEWLINE=true}"
SPACESHIP_PROMPT_SEPARATE_LINE="${SPACESHIP_PROMPT_SEPARATE_LINE=true}"
SPACESHIP_PROMPT_FIRST_PREFIX_SHOW="${SPACESHIP_PROMPT_FIRST_PREFIX_SHOW=false}"
SPACESHIP_PROMPT_PREFIXES_SHOW="${SPACESHIP_PROMPT_PREFIXES_SHOW=true}"
SPACESHIP_PROMPT_SUFFIXES_SHOW="${SPACESHIP_PROMPT_SUFFIXES_SHOW=true}"
SPACESHIP_PROMPT_DEFAULT_PREFIX="${SPACESHIP_PROMPT_DEFAULT_PREFIX="via "}"
SPACESHIP_PROMPT_DEFAULT_SUFFIX="${SPACESHIP_PROMPT_DEFAULT_SUFFIX=" "}"

# RPROMPT
SPACESHIP_RPROMPT_ADD_NEWLINE="${SPACESHIP_RPROMPT_ADD_NEWLINE=false}"

# Placeholder string
SPACESHIP_SECTION_PLACEHOLDER="${SPACESHIP_SECTION_PLACEHOLDER="…"}"

# Load custom section functions tagged with "::custom" from files
SPACESHIP_CUSTOM_SECTION_LOCATION="${SPACESHIP_CUSTOM_SECTION_LOCATION=$HOME/.config/spaceship/sections}"

fpath+=("$SPACESHIP_CUSTOM_SECTION_LOCATION")
