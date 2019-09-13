#!/usr/bin/env zsh

# Required for shunit2 to run correctly
setopt shwordsplit
SHUNIT_PARENT=$0

# ------------------------------------------------------------------------------
# SHUNIT2 HOOKS
# ------------------------------------------------------------------------------

oneTimeSetUp() {
  export TERM="xterm-256color"

  source lib/utils.zsh
}

# ------------------------------------------------------------------------------
# TEST CASES
# ------------------------------------------------------------------------------

test_is_git() {
  local REPO="$SHUNIT_TMPDIR/utils/is_git"
  mkdir -p $REPO/foo
  cd $REPO
  # Init a Git repo in $REPO
  command git init > /dev/null

  assertTrue "should be a git repo" '$(ss::is_git)'
  cd foo
  assertTrue "foo should be in git repo" '$(ss::is_git)'
  cd ../..
  assertFalse "should not be a git repo" '$(ss::is_git)'
}

test_is_hg() {
  # Skip this test case if Mercurial is not istalled
  if ! (( $+commands[hg] )); then
    startSkipping
  fi

  local REPO="$SHUNIT_TMPDIR/utils/is_hg"
  mkdir -p $REPO/foo
  mkdir -p "$REPO/../foo with space"
  cd $REPO

  if (( $+commands[hg] )); then
    command hg init
  fi

  assertTrue "should be a hg repo" '$(ss::is_hg)'
  cd foo
  assertTrue "foo should be in hg repo" '$(ss::is_hg)'
  cd "../../foo with space"
  assertFalse "'foo with space' directory should not be in hg repo" '$(ss::is_hg)'
  cd ../..
  assertFalse "should not be a hg repo" '$(ss::is_hg)'

  if isSkipping; then
    endSkipping
  fi
}

test_deprecated() {
  SPACESHIP_TEST='deprecated'
  local e_expected="%{%B%}SPACESHIP_TEST%{%b%} is deprecated.%{ %}"
  local expected="$(print -P "$e_expected")"
  local actual=$(ss::deprecated SPACESHIP_TEST)

  assertEquals "render deprecation warning" "$expected" "$actual"

  local desc="Use SOMETHING instead!"
  local e_expected=$e_expected$desc
  local expected="$(print -P "$e_expected")"
  local actual=$(ss::deprecated SPACESHIP_TEST "$desc")

  assertEquals "render deprecation warning with description" "$expected" "$actual"

  unset SPACESHIP_TEST
}

test_displaytime() {
  local expected='14d 6h 56m 7s'
  local actual=$(ss::displaytime 1234567)

  assertEquals "$expected" "$actual"
}

# ------------------------------------------------------------------------------
# SHUNIT2
# Run tests with shunit2
# ------------------------------------------------------------------------------

source modules/shunit2/shunit2
