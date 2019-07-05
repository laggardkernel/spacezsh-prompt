#
# Vagrant
#
# Vagrant enables users to create and configure lightweight, reproducible, and portable development environments.
# Link: https://www.vagrantup.com

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

SPACESHIP_VAGRANT_SHOW="${SPACESHIP_VAGRANT_SHOW=true}"
SPACESHIP_VAGRANT_PREFIX="${SPACESHIP_VAGRANT_PREFIX="on "}"
SPACESHIP_VAGRANT_SUFFIX="${SPACESHIP_VAGRANT_SUFFIX="$SPACESHIP_PROMPT_DEFAULT_SUFFIX"}"
SPACESHIP_VAGRANT_SYMBOL="${SPACESHIP_VAGRANT_SYMBOL="Ｖ"}"
SPACESHIP_VAGRANT_ON_COLOR="${SPACESHIP_VAGRANT_ON_COLOR="39"}" # deepskyblue
SPACESHIP_VAGRANT_OFF_COLOR="${SPACESHIP_VAGRANT_OFF_COLOR="247"}" # grey62
SPACESHIP_VAGRANT_COLOR=""

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Show current Vagrant status
spaceship_vagrant() {
  [[ $SPACESHIP_VAGRANT_SHOW == false ]] && return

  (( $+commands[vagrant] )) || return

  # Show Vagrant status only for Vagrant-specific folders
  local project_root=$(spaceship::upsearch "${VAGRANT_VAGRANTFILE:-Vagrantfile}")
  [[ -n $project_root ]] || return

  local vagrant_index="${VAGRANT_HOME:-$HOME/.vagrant.d}/data/machine-index/index"

  if (( $+commands[jq] )); then
    local vagrant_status=$(jq -r --arg dir "$project_root" '.machines[] | select(.vagrantfile_path == $dir).state' "$vagrant_index")
  else
    local vagrant_status=$(<"$vagrant_index" python -c 'import sys, os, json;
json_file = json.load(sys.stdin)["machines"]
for box in json_file:
  if (json_file[box]["vagrantfile_path"] == os.getcwd()):
    print (json_file[box]["state"])
    break;
')
  fi

  # possible status: running, poweroff
  if [[ -z ${vagrant_status} ]]; then
    return
  elif [[ $vagrant_status == poweroff ]]; then
    SPACESHIP_VAGRANT_COLOR="$SPACESHIP_VAGRANT_OFF_COLOR"
  elif [[ $vagrant_status == running ]]; then
    SPACESHIP_VAGRANT_COLOR="$SPACESHIP_VAGRANT_ON_COLOR"
  fi
  vagrant_status=""

  spaceship::section \
    "$SPACESHIP_VAGRANT_COLOR" \
    "$SPACESHIP_VAGRANT_PREFIX" \
    "${SPACESHIP_VAGRANT_SYMBOL}${vagrant_status}" \
    "$SPACESHIP_VAGRANT_SUFFIX"
}
