# vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8

prompt_spaceship_help () {
  cat <<'EOF'
🚀⭐️ A Zsh prompt for Astronauts

  prompt spaceship

Spaceship is a minimalistic, powerful and extremely customizable Zsh prompt.
It combines everything you may need for convenient work, without unnecessary
complications, like a real spaceship.
EOF
}

# Internal variable for checking if prompt is opened
spaceship_prompt_opened="$SPACESHIP_PROMPT_FIRST_PREFIX_SHOW"

# Draw prompt section (bold is used as default)
# USAGE:
#   spaceship::section <color> [prefix] <content> [suffix]
spaceship::section() {
  local color prefix content suffix
  [[ -n $1 ]] && color="%F{$1}"  || color="%f"
  [[ -n $2 ]] && prefix="$2"     || prefix=""
  [[ -n $3 ]] && content="$3"    || content=""
  [[ -n $4 ]] && suffix="$4"     || suffix=""

  [[ -z $3 && -z $4 ]] && content=$2 prefix=''

  local result=""

  result+="%{%B%}" # set bold
  if [[ $spaceship_prompt_opened == true ]] && [[ $SPACESHIP_PROMPT_PREFIXES_SHOW == true ]]; then
    restult+="$prefix"
  fi
  spaceship_prompt_opened=true
  result+="%{%b%}" # unset bold

  result+="%{%B$color%}" # set color
  result+="$content"     # section content
  result+="%{%b%f%}"     # unset color

  result+="%{%B%}" # reset bold, if it was diabled before
  if [[ $SPACESHIP_PROMPT_SUFFIXES_SHOW == true ]]; then
    result+="$suffix"
  fi
  result+="%{%b%}" # unset bold

  echo -n "$result"
}

# Takes the result of the sections computation and echos it,
# so that ZSH-Async can grab it.
#
# @args
#   $1 string The command to execute
#   $* Parameters for the command
spaceship::async_wrapper() {
  local command="$1"

  echo -n "${2}"

  shift 1
  ${command}
}

# Build prompt cache from section functions
# @description
#   This function loops through the prompt elements and calls
#   the related section functions.
#
# @args
#   $1 string, prompt/rprompt, alignment info
spaceship::build_section_cache() {
  # Option EXTENDED_GLOB is set locally to force filename generation on
  # argument to conditions, i.e. allow usage of explicit glob qualifier (#q).
  # See the description of filename generation in
  # http://zsh.sourceforge.net/Doc/Release/Conditional-Expressions.html
  setopt EXTENDED_GLOB LOCAL_OPTIONS

  local -a alignments=("prompt" "rprompt")
  local alignment
  local custom async section cache_key result
  local index

  [[ -n "$1" ]] && alignments=("$1")

  for alignment in "${alignments[@]}"; do
    [[ ${#__SS_DATA[${alignment}_sections]} == "0" ]] && continue

    index=1
    for section in ${=__SS_DATA[${alignment}_sections]}; do
      spaceship::section_is_tagged_as "async" "${section}" && async=true || async=false

      cache_key="${alignment}::${section}"

      if ${async}; then
        async_job "spaceship_async_worker" "spaceship::async_wrapper" "spaceship_${section}" "${section}·|·${alignment}·|·"

        # Placeholder
        __ss_section_cache[${cache_key}]="${section}·|·${alignment}·|·${SPACESHIP_SECTION_PLACEHOLDER}"
      else
        # Pass the alignment and index to the real section func in case that
        # the section func needs to know its position in the left/right prompt.
        # E.g. trigger re-rendering from vi_mode

        # Trick needed: keep single newline from section line_sep
        result="$(spaceship_${section}; echo 'x')"
        result="${result%?}"
        __ss_section_cache[${cache_key}]="${section}·|·${alignment}·|·${result}"
      fi

    index=$((index + 1))
    done
  done

  if [[ ${#alignments} == "2" ]]; then
    spaceship::render
  else
    # only render the corresponding side of the prompt
    spaceship::render "${alignment[1]}"
  fi
}

# Refresh a single item in the cache, and redraw the prompt
#
# @args
#   $1 - section name
#   $2 - boolean true if render the prompt after cache update
function spaceship::refresh_cache_item() {
  [[ -z $1 ]] && return 1

  local section="$1"
  local alignment
  local cache result

  if spaceship::section_in_use "${section}" "prompt"; then
    alignment="prompt"
  elif spaceship::section_in_use "${section}" "rprompt"; then
    alignment="rprompt"
  else
    # Unavailable section name
    return 1
  fi

  spaceship::section_is_tagged_as "async" "${section}" && async=true || async=false

  cache_key="${alignment}::${section}"

  if ${async}; then
    async_job "spaceship_async_worker" "spaceship::async_wrapper" "spaceship_${section}" "${section}·|·${alignment}·|·"

    # Placeholder
    __ss_section_cache[${cache_key}]="${section}·|·${alignment}·|·${SPACESHIP_SECTION_PLACEHOLDER}"
  else
    # Trick needed: keep single newline from section line_sep
    result="$(spaceship_${section}; echo 'x')"
    result="${result%?}"
    __ss_section_cache[${cache_key}]="${section}·|·${alignment}·|·${result}"

    [[ $2 == "true" ]] && spaceship::render "$alignment"
  fi
}

# Exchange result of prompt_<section> function in the cache and
# trigger re-rendering of prompt.
#
# @args
#   $1 job name, e.g. the function passed to async_job
#   $2 return code
#   $3 resulting (stdout) output from job execution
#   $4 execution time, floating point e.g. 0.0076138973 seconds
#   $5 resulting (stderr) error output from job execution
#   $6 has next result in buffer (0 = buffer empty, 1 = yes)
spaceship::async_callback() {
  local job="$1" ret="$2" output="$3" exec_time="$4" err="$5" has_next="$6"
  local section_meta cache_key

  # ignore the async evals used to alter worker environment
  if [[ "${job}" == "[async/eval]" ]] || \
     [[ "${job}" == ";" ]] || \
     [[ "${job}" == "[async]" ]]; then
    return
  fi

  # split input $output into an array - see https://unix.stackexchange.com/a/28873
  section_meta=("${(@s:·|·:)output}") # split on delimiter "·|·" (@s:<delim>:)
  cache_key="${section_meta[2]}::${section_meta[1]}"

  # Skip prompt re-rendering if both placeholder and section content are empty,
  # or section cache is unchanged
  if [[ "$SPACESHIP_SECTION_PLACEHOLDER" == "${section_meta[3]}" ]] \
    || [[ "${__ss_section_cache[${cache_key}]}" == "$output" ]]; then
    return
  else
    __ss_section_cache[${cache_key}]="${output}"
  fi

  # Delay prompt updates if there's another result in the buffer, which
  # prevents strange states in ZLE
  [[ "$has_next" == "0" ]] && spaceship::async_render
}

# Spaceship Render function.
# Goes through cache and renders each entry.
#
# @args
#   $1 - prompt/rprompt
spaceship::render() {
  local RPROMPT_PREFIX RPROMPT_SUFFIX
  local -a alignments=("prompt" "rprompt")
  local -a section_meta
  local alignment section cache_key

  [[ -n $1 ]] && alignments=("$1")

  for alignment in "${alignments[@]}"; do
    [[ ${#__SS_DATA[${alignment}_sections]} == "0" ]] && continue

    # Reset prompt storage
    __ss_unsafe[$alignment]=""

    for section in ${=__SS_DATA[${alignment}_sections]}; do
      cache_key="${alignment}::${section}"
      section_meta=("${(@s:·|·:)${__ss_section_cache[${cache_key}]}}")

      [[ -z "${section_meta[3]}" ]] && continue # Skip if section is empty

      __ss_unsafe[$alignment]+="${section_meta[3]}"
    done

    # left/right specific
    if [[ $alignment == "prompt" ]]; then
      # Allow iTerm integration to work
      [[ "${ITERM_SHELL_INTEGRATION_INSTALLED:-}" == "Yes" ]] \
        && __ss_unsafe[prompt]="%{$(iterm2_prompt_mark)%}${__ss_unsafe[prompt]}"

      local NEWLINE=$'\n'

      [[ "$SPACESHIP_PROMPT_ADD_NEWLINE" == true ]] \
        && __ss_unsafe[prompt]="$NEWLINE${__ss_unsafe[prompt]}"

      # By evaluating $__ss_unsafe[prompt] here in __ss_render we avoid
      # the evaluation of $PROMPT being interrupted.
      # For security $PROMPT is never set directly. This way the prompt render is
      # forced to evaluate the variable and the contents of $__ss_unsafe[prompt]
      # are never executed. The same applies to $RPROMPT.
      PROMPT='${__ss_unsafe[prompt]}'
    else
      if [[ "$SPACESHIP_RPROMPT_ON_NEWLINE" != true ]]; then
        # The right prompt should be on the same line as the first line of the left
        # prompt. To do so, there is just a quite ugly workaround: Before zsh draws
        # the RPROMPT, we advise it, to go one line up. At the end of RPROMPT, we
        # advise it to go one line down. See:
        # http://superuser.com/questions/357107/zsh-right-justify-in-ps1
        RPROMPT_PREFIX='%{'$'\e[1A''%}' # one line up
        RPROMPT_SUFFIX='%{'$'\e[1B''%}' # one line down
        __ss_unsafe[rprompt]="${RPROMPT_PREFIX}${__ss_unsafe[rprompt]}${RPROMPT_SUFFIX}"
      fi
      RPROMPT='${__ss_unsafe[rprompt]}'
    fi
  done
}

spaceship::async_render() {
  spaceship::render "$@"

  # .reset-prompt: bypass the zsh-syntax-highlighting wrapper
  # https://github.com/sorin-ionescu/prezto/issues/1026
  # https://github.com/zsh-users/zsh-autosuggestions/issues/107#issuecomment-183824034
  zle .reset-prompt && zle -R
}

# PS2
# Continuation interactive prompt
spaceship_ps2() {
  local char="${SPACESHIP_CHAR_SYMBOL_SECONDARY="$SPACESHIP_CHAR_SYMBOL"}"
  spaceship::section "$SPACESHIP_CHAR_COLOR_SECONDARY" "$char"
}

# ------------------------------------------------------------------------------
# SETUP
# Setup requirements for prompt
# ------------------------------------------------------------------------------

# Load functions for sections defined in prompt order arrays
#
# @args
#   $1 - prompt/rpromp/""
spaceship::load_sections() {
  local -a alignments=("prompt" "rprompt")
  local -a raw_sections section_meta
  local sections_var section raw_section
  local load_async=false

  [[ -n $1 ]] && alignments=("$1")

  for alignment in "${alignments[@]}"; do
    # Reset related cache
    __SS_DATA[${alignment}_raw_sections]=""
    __SS_DATA[${alignment}_sections]=""
    __SS_DATA[async_${alignment}_sections]=""
    __SS_DATA[custom_${alignment}_sections]=""

    sections_var="SPACESHIP_${(U)alignment}_ORDER"
    raw_sections=(${(P)sections_var})
    for raw_section in "${(@)raw_sections}"; do
      # Split by double-colon
      section_meta=(${(s.::.)raw_section})
      # First value is always section name
      section=${section_meta[1]}

      # Cache sections
      for tag in ${section_meta[2,-1]}; do
        __SS_DATA[${tag}_${alignment}_sections]+="${section} "

        # Special Case: Remember that async lib should be loaded
        [[ "$tag" == "async" ]] && load_async=true
      done

      # Prefer custom section over same name builtin section
      if spaceship::defined "spaceship_$section"; then
        # Custom section is declared, nothing else to do
        continue
      elif spaceship::section_is_tagged_as "custom" "${section}" \
        && [[ -f "${SPACESHIP_CUSTOM_SECTION_LOCATION}/${section}.zsh" ]]; then
        source "${SPACESHIP_CUSTOM_SECTION_LOCATION}/${section}.zsh"
      elif [[ -f "$SPACESHIP_ROOT/sections/$section.zsh" ]]; then
        source "$SPACESHIP_ROOT/sections/$section.zsh"
      else
        # file not found!
        # If this happens, we remove the section from the configured elements,
        # so that we avoid printing errors over and over.
        print -P "%F{yellow}Warning!%f The '%F{cyan}${section}%f' section was not found. Removing it from the prompt."
        SPACESHIP_PROMPT_ORDER=("${(@)SPACESHIP_PROMPT_ORDER:#${raw_section}}")
        SPACESHIP_RPROMPT_ORDER=("${(@)SPACESHIP_RPROMPT_ORDER:#${raw_section}}")
        for tag in ${section_meta[2,-1]}; do
          __SS_DATA[${tag}_${alignment}_sections]="${__SS_DATA[${tag}_${alignment}_sections]%${section} } "
        done
      fi
    done

    # Cache configured sections! As nested arrays are not really possible,
    # store as single string, separated by whitespace.
    # Cache the raw_sections after invalid ones are removed
    raw_sections=(${(P)sections_var})
    __SS_DATA[${alignment}_raw_sections]="${raw_sections[*]}"
    __SS_DATA[${alignment}_sections]="${raw_sections[@]%::*}"
  done

  # Load Async libs at last, because before initializing
  # ZSH-Async, all functions must be defined.
  if ${load_async}; then
    __SS_DATA[async]=true
    # Avoid duplicate sourcing and loading of zsh-async by checking flag ASYNC_INIT_DONE
    (( ASYNC_INIT_DONE )) || source "${SPACESHIP_ROOT}/modules/zsh-async/async.zsh"
  fi
}
# spaceship::load_sections

# ------------------------------------------------------------------------------
# BACKWARD COMPATIBILITY WARNINGS
# Show deprecation messages for options that are set, but not supported
# ------------------------------------------------------------------------------

spaceship::deprecated_check() {
  spaceship::deprecated SPACESHIP_PROMPT_SYMBOL "Use %BSPACESHIP_CHAR_SYMBOL%b instead."
  spaceship::deprecated SPACESHIP_BATTERY_ALWAYS_SHOW "Use %BSPACESHIP_BATTERY_SHOW='always'%b instead."
  spaceship::deprecated SPACESHIP_BATTERY_CHARGING_SYMBOL "Use %BSPACESHIP_BATTERY_SYMBOL_CHARGING%b instead."
  spaceship::deprecated SPACESHIP_BATTERY_DISCHARGING_SYMBOL "Use %BSPACESHIP_BATTERY_SYMBOL_DISCHARGING%b instead."
  spaceship::deprecated SPACESHIP_BATTERY_FULL_SYMBOL "Use %BSPACESHIP_BATTERY_SYMBOL_FULL%b instead."
}

# Runs once when user opens a terminal
# All preparation before drawing prompt should be done here
prompt_spaceship_setup() {
  # reset prompt according to prompt_default_setup
  # +h, override the -h attr given to global special params
  local +h PS1='%m%# '
  local +h PS2='%_> '
  local +h PS3='?# '
  local +h PS4='+%N:%i> '
  unset RPS1 RPS2 RPROMPT RPROMPT2

  # This variable is a magic variable used when loading themes with zsh's prompt
  # function. It will ensure the proper prompt options are set.
  prompt_opts=(cr percent sp subst)

  # Borrowed from promptinit, sets the prompt options in case the prompt was not
  # initialized via promptinit.
  setopt noprompt{bang,cr,percent,subst} "prompt${^prompt_opts[@]}"

  # initialize timing functions
  zmodload zsh/datetime

  # Initialize math functions
  zmodload zsh/mathfunc

  # initialize hooks
  autoload -Uz add-zsh-hook

  typeset -gAH __SS_DATA

  # Global section cache
  typeset -gAh __ss_section_cache=()

  # __ss_unsafe must be a global variable, because we set
  # PROMPT='$__ss_unsafe[left]', so without letting ZSH
  # expand this value (single quotes). This is a workaround
  # to avoid double expansion of the contents of the PROMPT.
  typeset -gAh __ss_unsafe=()

  # Load a preset by name
  # presets must be loaded before lib/default.zsh
  if [[ -n "$1" ]]; then
    if [[ -r "${SPACESHIP_ROOT}/presets/${1}.zsh" ]]; then
      source "${SPACESHIP_ROOT}/presets/${1}.zsh"
    else
      echo "Spaceship: No such preset found in ${SPACESHIP_ROOT}/presets/${1}"
    fi
  fi

  # Always load default conf
  source "$SPACESHIP_ROOT/lib/default.zsh"
  # LIBS
  source "$SPACESHIP_ROOT/lib/utils.zsh"
  source "$SPACESHIP_ROOT/lib/hooks.zsh"
  # sections.zsh is deprecated, cause it's linked as prompt_spaceship_setup
  # source "$SPACESHIP_ROOT/lib/section.zsh"
  spaceship::load_sections
  spaceship::deprecated_check

  # Hooks
  add-zsh-hook precmd prompt_spaceship_precmd
  add-zsh-hook preexec prompt_spaceship_preexec
  # hook into chpwd for bindkey support
  add-zsh-hook chpwd prompt_spaceship_chpwd

  # The value below was set to better support 32-bit CPUs.
  # It's the maximum _signed_ integer value on 32-bit CPUs.
  # Please don't change it until 19 January of 2038. ;)

  # Disable false display of command execution time
  SPACESHIP_EXEC_TIME_start=0x7FFFFFFF

  # Disable python virtualenv environment prompt prefix
  VIRTUAL_ENV_DISABLE_PROMPT=true

  # Expose Spaceship to environment variables
  PS2='$(spaceship_ps2)'

  # prepend custom cleanup hook
  local -a cleanup_hooks
  zstyle -g cleanup_hooks :prompt-theme cleanup
  zstyle -e :prompt-theme cleanup "prompt_spaceship_cleanup;" "${cleanup_hooks[@]}"
  # append cleanup hook with builtin func
  # prompt_cleanup "prompt_spaceship_cleanup"
}

# TODO: compile helper

# This function removes spaceship hooks and resets the prompts.
prompt_spaceship_cleanup() {
  # prmopt specific cleanup
  spaceship_vi_mode_disable 2>/dev/null
  # TODO: cleanup preset conf

  # prompt hooks
  add-zsh-hook -D precmd  prompt_spaceship\*
  add-zsh-hook -D preexec prompt_spaceship\*
  add-zsh-hook -D chpwd   prompt_spaceship\*

  # reset prompt according to prompt_default_setup
  # +h, override the -h attr given to global special params
  local +h PS1='%m%# '
  local +h PS2='%_> '
  local +h PS3='?# '
  local +h PS4='+%N:%i> '
  unset RPS1 RPS2 RPROMPT RPROMPT2
  prompt_opts=( cr percent sp )

  unset __ss_section_cache
  unset __ss_unsafe
}

prompt_spaceship_setup "$@"
