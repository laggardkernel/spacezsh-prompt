#!/usr/bin/env zsh
# vim: ft=zsh fdm=marker foldlevel=0 sw=2 ts=2 sts=2 et

# ------------------------------------------------------------------------------
# UTILS
# Utils for common used actions
# ------------------------------------------------------------------------------

# TODO: variable defined, set_default

# Check if the current directory is in a Git repository.
# USAGE:
#   sz::is_git
function sz::is_git {
  # See https://git.io/fp8Pa for related discussion
  command git rev-parse --is-inside-work-tree &>/dev/null
}

# Check if the current directory is in a Mercurial repository.
# USAGE:
#   sz::is_hg
function sz::is_hg {
  local root="$PWD"

  while [[ "$root" ]] && [[ ! -d "$root/.hg" ]]; do
    root="${root%/*}"
  done

  [[ -n "$root" ]] &>/dev/null
}

# Print message backward compatibility warning
# USAGE:
#  sz::deprecated <deprecated> [message]
function sz::deprecated {
  [[ -n $1 ]] || return
  local deprecated=$1 message=$2
  local deprecated_value=${(P)deprecated} # the value of variable name $deprecated
  [[ -n $deprecated_value ]] || return
  print -P "%{%B%}$deprecated%{%b%} is deprecated. $message"
}

# Display seconds in human readable fromat
# Based on http://stackoverflow.com/a/32164707/3859566
# USAGE:
#   sz::displaytime <seconds>
function sz::displaytime {
  local T=$1
  local D=$((T/60/60/24))
  local H=$((T/60/60%24))
  local M=$((T/60%60))
  local S=$((T%60))
  [[ $D > 0 ]] && printf '%dd ' $D
  [[ $H > 0 ]] && printf '%dh ' $H
  [[ $M > 0 ]] && printf '%dm ' $M
  printf '%ds' $S
}

# Determine if the passed section is used in either the LEFT or
# RIGHT prompt arrays.
#
# @args
#   $1 string The section to be tested.
#   $2 prompt/rprompt/"" The alignment info
function sz::section_in_use {
  local section="$1"
  local -a sections
  local alignment
  local -a alignments=("prompt" "rprompt")

  [[ -n "$2" ]] && alignments=("$2")

  for alignment in "${(@)alignments}"; do
    sections=(${(@)sections} ${(s/ /)_SS_DATA[${alignment}_sections]:-})
  done
  (( ${sections[(Ie)${section}]} ))
}

# Search recursively in parent folders for given file.
#
# @args
#   $1 string File/folder name to search for.
#   $2 file/dir, type to be searched
# @return
#   The 1st path where the file/folder has been found
function sz::upsearch {
  local search_type=""
  local root="$PWD"

  if [[ -z $2 ]]; then
    search_type="file"
  else
    search_type="$2"
  fi

  if [[ $search_type == file ]]; then
    while [[ -n "$root" ]] && [[ ! -f "$root/$1" ]]; do
      root="${root%/*}"
    done
  elif [[ $search_type == dir ]]; then
    while [[ -n "$root" ]] && [[ ! -d "$root/$1" ]]; do
      root="${root%/*}"
    done
  fi

  if [[ -n "$root" ]]; then
    echo "$root"
    return 0
  else
    return 1
  fi
}
