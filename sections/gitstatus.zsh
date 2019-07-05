# vim: fdm=marker foldlevel=0 sw=2 ts=2 sts=2
#
# Git supported by romkatv/gitstatus
#
# Configuration {{{
# Gitstatus
SPACESHIP_GITSTATUS_HYBRID="${SPACESHIP_GITSTATUS_HYBRID=false}"
SPACESHIP_GITSTATUS_SKIP_DAEMON="${SPACESHIP_GITSTATUS_SKIP_DAEMON=false}"

# Git
SPACESHIP_GIT_SHOW="${SPACESHIP_GIT_SHOW=true}"
SPACESHIP_GIT_PREFIX="${SPACESHIP_GIT_PREFIX="on "}"
SPACESHIP_GIT_SUFFIX="${SPACESHIP_GIT_SUFFIX="$SPACESHIP_PROMPT_DEFAULT_SUFFIX"}"
SPACESHIP_GIT_SYMBOL="${SPACESHIP_GIT_SYMBOL=" "}"

# Git Branch
SPACESHIP_GIT_BRANCH_SHOW="${SPACESHIP_GIT_BRANCH_SHOW=true}"
SPACESHIP_GIT_BRANCH_PREFIX="${SPACESHIP_GIT_BRANCH_PREFIX="$SPACESHIP_GIT_SYMBOL"}"
SPACESHIP_GIT_BRANCH_SUFFIX="${SPACESHIP_GIT_BRANCH_SUFFIX=""}"
SPACESHIP_GIT_BRANCH_COLOR="${SPACESHIP_GIT_BRANCH_COLOR="magenta"}"

# Git Status
SPACESHIP_GIT_STATUS_SHOW="${SPACESHIP_GIT_STATUS_SHOW=true}"
SPACESHIP_GIT_STATUS_PREFIX="${SPACESHIP_GIT_STATUS_PREFIX=" ["}"
SPACESHIP_GIT_STATUS_SUFFIX="${SPACESHIP_GIT_STATUS_SUFFIX="]"}"
SPACESHIP_GIT_STATUS_COLOR="${SPACESHIP_GIT_STATUS_COLOR="red"}"
SPACESHIP_GIT_STATUS_UNTRACKED="${SPACESHIP_GIT_STATUS_UNTRACKED="?"}"
SPACESHIP_GIT_STATUS_ADDED="${SPACESHIP_GIT_STATUS_ADDED="+"}"
SPACESHIP_GIT_STATUS_MODIFIED="${SPACESHIP_GIT_STATUS_MODIFIED="!"}"
SPACESHIP_GIT_STATUS_RENAMED="${SPACESHIP_GIT_STATUS_RENAMED="»"}"
SPACESHIP_GIT_STATUS_DELETED="${SPACESHIP_GIT_STATUS_DELETED="✘"}"
SPACESHIP_GIT_STATUS_STASHED="${SPACESHIP_GIT_STATUS_STASHED="$"}"
SPACESHIP_GIT_STATUS_UNMERGED="${SPACESHIP_GIT_STATUS_UNMERGED="="}"
SPACESHIP_GIT_STATUS_AHEAD="${SPACESHIP_GIT_STATUS_AHEAD="⇡"}"
SPACESHIP_GIT_STATUS_BEHIND="${SPACESHIP_GIT_STATUS_BEHIND="⇣"}"
SPACESHIP_GIT_STATUS_DIVERGED="${SPACESHIP_GIT_STATUS_DIVERGED="⇕"}"

# }}}
# Gitstatus Daemon {{{
if [[ $SPACESHIP_GITSTATUS_SKIP_MODULE != true ]]; then
  if ! (( $+functions[gitstatus_query] )); then
    source "$SPACESHIP_ROOT/modules/gitstatus/gitstatus.plugin.zsh" || return
  fi

  if [[ $SPACESHIP_GITSTATUS_SKIP_DAEMON != true ]]; then
    gitstatus_stop SPACESHIP && gitstatus_start SPACESHIP
  fi
fi

# }}}
# Dependencies {{{
spaceship_gitstatus_branch() {
  [[ $SPACESHIP_GIT_BRANCH_SHOW == false ]] && return

  [[ -z "$VCS_STATUS_LOCAL_BRANCH" ]] && return

  spaceship::section \
    "$SPACESHIP_GIT_BRANCH_COLOR" \
    "$SPACESHIP_GIT_BRANCH_PREFIX${VCS_STATUS_LOCAL_BRANCH}$SPACESHIP_GIT_BRANCH_SUFFIX"
}

spaceship_gitstatus_status() {
  [[ $SPACESHIP_GIT_STATUS_SHOW == false ]] && return

  local INDEX git_status=""

  # Check for untracked files
  if (( $VCS_STATUS_HAS_UNTRACKED )); then
    git_status="$SPACESHIP_GIT_STATUS_UNTRACKED$git_status"
  fi

  # Check for staged files
  if (( $VCS_STATUS_HAS_STAGED )); then
    git_status="$SPACESHIP_GIT_STATUS_ADDED$git_status"
  fi

  # Unsupported {{{
  if [[ $SPACESHIP_GITSTATUS_HYBRID == true ]]; then
    INDEX=$(command git status --porcelain -b 2> /dev/null)

    # Check for modified files
    if $(<<< "$INDEX" command grep '^[ MARC]M ' &> /dev/null); then
      git_status="$SPACESHIP_GIT_STATUS_MODIFIED$git_status"
    fi

    # Check for renamed files
    if $(<<< "$INDEX" command grep '^R[ MD] ' &> /dev/null); then
      git_status="$SPACESHIP_GIT_STATUS_RENAMED$git_status"
    fi

    # Check for deleted files
    if $(<<< "$INDEX" command grep '^[MARCDU ]D ' &> /dev/null); then
      git_status="$SPACESHIP_GIT_STATUS_DELETED$git_status"
    elif $(<<< "$INDEX" command grep '^D[ UM] ' &> /dev/null); then
      git_status="$SPACESHIP_GIT_STATUS_DELETED$git_status"
    fi
  fi

  # }}}

  # Check for stashes
  if (( $VCS_STATUS_STASHES )); then
    git_status="$SPACESHIP_GIT_STATUS_STASHED$git_status"
  fi

  # Unsupported {{{
  if [[ $SPACESHIP_GITSTATUS_HYBRID == true ]]; then
    # Check for unmerged files
    if $(<<< "$INDEX" command grep '^U[UDA] ' &> /dev/null); then
      git_status="$SPACESHIP_GIT_STATUS_UNMERGED$git_status"
    elif $(<<< "$INDEX" command grep '^AA ' &> /dev/null); then
      git_status="$SPACESHIP_GIT_STATUS_UNMERGED$git_status"
    elif $(<<< "$INDEX" command grep '^DD ' &> /dev/null); then
      git_status="$SPACESHIP_GIT_STATUS_UNMERGED$git_status"
    elif $(<<< "$INDEX" command grep '^[DA]U ' &> /dev/null); then
      git_status="$SPACESHIP_GIT_STATUS_UNMERGED$git_status"
    fi
  fi

  # }}}

  # Check wheather branch has diverged
  if (( $VCS_STATUS_COMMITS_AHEAD )) && (( $VCS_STATUS_COMMITS_BEHIND )); then
    git_status="$SPACESHIP_GIT_STATUS_DIVERGED$git_status"
  else
    (( $VCS_STATUS_COMMITS_AHEAD )) && git_status="$SPACESHIP_GIT_STATUS_AHEAD$git_status"
    (( $VCS_STATUS_COMMITS_BEHIND )) && git_status="$SPACESHIP_GIT_STATUS_BEHIND$git_status"
  fi

  if [[ -n $git_status ]]; then
    # Status prefixes are colorized
    spaceship::section \
      "$SPACESHIP_GIT_STATUS_COLOR" \
      "$SPACESHIP_GIT_STATUS_PREFIX$git_status$SPACESHIP_GIT_STATUS_SUFFIX"
  fi
}

# }}}
# Section {{{
spaceship_gitstatus() {
  [[ $SPACESHIP_GIT_SHOW == false ]] && return

  spaceship::is_git || return

  (( $+functions[gitstatus_query] )) || return

  if gitstatus_query SPACESHIP && [[ "$VCS_STATUS_RESULT" == ok-sync ]]; then
    local git_branch="$(spaceship_gitstatus_branch)" git_status="$(spaceship_gitstatus_status)"

    [[ -z $git_branch ]] && return

    spaceship::section \
      'white' \
      "$SPACESHIP_GIT_PREFIX" \
      "${git_branch}${git_status}" \
      "$SPACESHIP_GIT_SUFFIX"
  fi
}

# }}}
