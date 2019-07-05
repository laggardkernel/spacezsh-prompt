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
spaceship_char_async() {
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
  if [[ $SPACESHIP_VI_MODE_CURSOR_CHANGE == true ]]; then
    function zle-keymap-select() {
      # fix vi mode indicator in async mode
      # https://github.com/maximbaz/spaceship-prompt/issues/4
      PROMPT=$(spaceship::compose_prompt $SPACESHIP_PROMPT_ORDER)

      zle reset-prompt ; zle -R

      # http://lynnard.me/blog/2014/01/05/change-cursor-shape-for-zsh-vi-mode/
      if [[ $KEYMAP = vicmd ]]; then
        # block symbol for command mode
        echo -ne "\e[2 q"
      else
        # pipe symbol for insert mode
        echo -ne "\e[6 q"
      fi
    }

    # Use pipe symbol in insert mode
    echo -ne "\e[6 q"

  else
    function zle-keymap-select() {
      PROMPT=$(spaceship::compose_prompt $SPACESHIP_PROMPT_ORDER)
      zle reset-prompt ; zle -R
    }
  fi

  zle -N zle-keymap-select
  bindkey -v
}

# Temporarily switch to emacs-mode
spaceship_vi_mode_disable() {
  bindkey -e
}

[[ $SPACESHIP_VI_MODE_SHOW == true ]] && spaceship_vi_mode_enable