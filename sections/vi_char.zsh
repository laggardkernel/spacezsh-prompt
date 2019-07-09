#
# Prompt character
#

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

SPACESHIP_CHAR_PREFIX="${SPACESHIP_CHAR_PREFIX=""}"
SPACESHIP_CHAR_SUFFIX="${SPACESHIP_CHAR_SUFFIX=""}"
SPACESHIP_CHAR_SYMBOL="${SPACESHIP_CHAR_SYMBOL="➜ "}"
SPACESHIP_CHAR_SYMBOL_ROOT="${SPACESHIP_CHAR_SYMBOL_ROOT="$SPACESHIP_CHAR_SYMBOL"}"
SPACESHIP_CHAR_SYMBOL_SECONDARY="${SPACESHIP_CHAR_SYMBOL_SECONDARY="..."}"
SPACESHIP_CHAR_COLOR_SUCCESS="${SPACESHIP_CHAR_COLOR_SUCCESS="green"}"
SPACESHIP_CHAR_COLOR_FAILURE="${SPACESHIP_CHAR_COLOR_FAILURE="red"}"
SPACESHIP_CHAR_COLOR_SECONDARY="${SPACESHIP_CHAR_COLOR_SECONDARY="yellow"}"

SPACESHIP_VI_MODE_SHOW="${SPACESHIP_VI_MODE_SHOW=true}"
SPACESHIP_VI_MODE_INSERT="${SPACESHIP_VI_MODE_INSERT="❯ "}"
SPACESHIP_VI_MODE_NORMAL="${SPACESHIP_VI_MODE_NORMAL="❮ "}"
SPACESHIP_VI_MODE_CURSOR_CHANGE="${SPACESHIP_VI_MODE_CURSOR_CHANGE="false"}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Paint $PROMPT_SYMBOL in red if previous command was fail and
# paint in green if everything was OK.
spaceship_vi_char() {
  local 'color' 'char'

  if [[ $RETVAL -eq 0 ]]; then
    color="$SPACESHIP_CHAR_COLOR_SUCCESS"
  else
    color="$SPACESHIP_CHAR_COLOR_FAILURE"
  fi

  if [[ $SPACESHIP_VI_MODE_SHOW == true ]]; then
    char="${SPACESHIP_VI_MODE_INSERT}"

    case "${KEYMAP}" in
      main|viins)
      char="${SPACESHIP_VI_MODE_INSERT}"
      ;;
      vicmd)
      char="${SPACESHIP_VI_MODE_NORMAL}"
      ;;
    esac

  else
    if [[ $UID -eq 0 ]]; then
      char="$SPACESHIP_CHAR_SYMBOL_ROOT"
    else
      char="$SPACESHIP_CHAR_SYMBOL"
    fi
  fi

  spaceship::section \
    "$color" \
    "$SPACESHIP_CHAR_PREFIX" \
    "$char" \
    "$SPACESHIP_CHAR_SUFFIX"
}

# ------------------------------------------------------------------------------
# Helpers
# ------------------------------------------------------------------------------

# Temporarily switch to vi-mode
spaceship_vi_mode_enable() {
  function zle-char-switch {
    # TODO: make char style compatible with more terminals
    if [[ $KEYMAP = vicmd ]]; then
      # block symbol for command mode
      echo -ne "\e[2 q"
    else
      # pipe symbol for insert mode
      echo -ne "\e[6 q"
    fi
  }
  zle -N zle-char-switch

  # Enables terminal application mode and updates editor information.
  function zle-line-init() {
    # The terminal must be in application mode when ZLE is active for $terminfo
    # values to be valid.
    if (( $+terminfo[smkx] )); then
      # Enable terminal application mode.
      echoti smkx
    fi

    # rerender prompt to get vi mode updated
    spaceship::refresh_cache_item "vi_char" "true"

    zle-char-switch
  }
  zle -N zle-line-init

  # Disables terminal application mode and updates editor information.
  function zle-line-finish {
    # The terminal must be in application mode when ZLE is active for $terminfo
    # values to be valid.
    if (( $+terminfo[rmkx] )); then
      # Disable terminal application mode.
      echoti rmkx
    fi

    # rerender prompt to get vi mode updated
    spaceship::refresh_cache_item "vi_char" "true"

    zle-char-switch
  }
  zle -N zle-line-finish

  # Updates editor information when the keymap changes.
  function zle-keymap-select() {
    # rerender prompt to get vi mode updated
    spaceship::refresh_cache_item "vi_char" "true"

    zle-char-switch
  }
  zle -N zle-keymap-select

  bindkey -v
}

# Temporarily switch to emacs-mode
spaceship_vi_mode_disable() {
  zle -D zle-line-init
  zle -D zle-line-finish
  zle -D zle-keymap-select
  zle -D zle-char-switch
  unset -f zle-line-init
  unset -f zle-line-finish
  unset -f zle-keymap-select
  unset -f zle-char-switch
  bindkey -e
}

[[ $SPACESHIP_VI_MODE_SHOW == true ]] && spaceship_vi_mode_enable
