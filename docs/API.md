# API

This page describes Spaceship API for creating plugins and tweaking Spaceship's behavior.

Spaceship uses `SPACESHIP_` prefix for variables and `ss::` prefix for a function to avoid conflicts with other ones. All section, including custom ones, are being required to use `spaceship_` prefix before their name to load properly.

## Typical section

Below is an example of a typical section for Spaceship. Pay attention to a few crucial moments:

* Define options for customization. Their names should start with `SPACESHIP_`.
* Section's name should start with `spaceship_`.
* Show section only where it's needed (in directories which contains specific files, when a specific command is available, etc).

Take a look at [Contribution guidelines](../CONTRIBUTING.md) for further information.

```zsh
#
# Foobar
#
# Foobar is a supa-dupa cool tool for making you development easier.
# Link: https://www.foobar.xyz

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

SPACESHIP_FOOBAR_SHOW="${SPACESHIP_FOOBAR_SHOW=true}"
SPACESHIP_FOOBAR_PREFIX="${SPACESHIP_FOOBAR_PREFIX="$SPACESHIP_PROMPT_DEFAULT_PREFIX"}"
SPACESHIP_FOOBAR_SUFFIX="${SPACESHIP_FOOBAR_SUFFIX="$SPACESHIP_PROMPT_DEFAULT_SUFFIX"}"
SPACESHIP_FOOBAR_SYMBOL="${SPACESHIP_FOOBAR_SYMBOL="🍷 "}"
SPACESHIP_FOOBAR_COLOR="${SPACESHIP_FOOBAR_COLOR="white"}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Show foobar status
# spaceship_ prefix before section's name is required!
# Otherwise this section won't be loaded.
spaceship_foobar() {
  # If SPACESHIP_FOOBAR_SHOW is false, don't show foobar section
  [[ $SPACESHIP_FOOBAR_SHOW == false ]] && return

  # Check if foobar command is available for execution
  ss::exists foobar || return

  # Show foobar section only when there are foobar-specific files in current
  # working directory.
  # Here glob qualifiers are used to check if files with specific extension are
  # present in directory. Read more about them here:
  # http://zsh.sourceforge.net/Doc/Release/Expansion.html
  [[ -f foobar.conf || -n *.foo(#qN^/) || -n *.bar(#qN^/) ]] || return

  # Use quotes around unassigned local variables to prevent
  # getting replaced by global aliases
  # http://zsh.sourceforge.net/Doc/Release/Shell-Grammar.html#Aliasing
  local 'foobar_status'

  if [[ $SOME_CONDITION ]]; then
    foobar_status=$(foobar baz)
  else
    foobar_status=$(foobar foo)
  fi

  # Exit section if variable is empty
  [[ -z $foobar_status ]] && return

  # Display foobar section
  ss::section \
    "$SPACESHIP_FOOBAR_COLOR" \
    "$SPACESHIP_FOOBAR_PREFIX" \
    "$SPACESHIP_FOOBAR_SYMBOL$foobar_status" \
    "$SPACESHIP_FOOBAR_SUFFIX"
}
```

## `SPACESHIP_VERSION`

An environment variable that defines the version of currently running Spaceship prompt version. Can be used for issue reporting or debugging purposes.

Accessible to any program or script running in a current shell session.

### Example:

```zsh
echo $SPACESHIP_VERSION
#> 3.0.0
```

## `SPACESHIP_ROOT`

> **Attention!** Do not modify the value of this variable! Changing the value may cause the damage to Spaceship installation!

An environment variable that defines the path to Spaceship prompt installation. Spaceship uses this variable for resolving path to sections and utils.

Accessible to any program or script running in a current shell session.

### Example:

```zsh
echo $SPACESHIP_ROOT
#> /path/to/spaceship-prompt
```

## `SPACESHIP_CUSTOM_SECTION_LOCATION`

Path where custom section files are auto sourced. Defaults to `$HOME/.config/spaceship/sections`.

Custom section name and function name should follow the same pattern as the built/core sections. To be specific, a custom section named `foobar` should be rendered with function `spaceship_foobar` and stored in file `${SPACESHIP_CUSTOM_SECTION_LOCATION}/foobar.zsh`.

To load a custom section defined in a file, you should tag the section name with `custom` (like `foobar::custom`) in the array `SPACESHIP_PROMPT_ORDER`. Tag `custom` is only required for custom section sourced from a file by Spaceship. If you've sourced the file manually before spaceship is loaded, there's no need to use the tag `custom`.

**Note**: custom section is preferred over core/builtin section with the same name.

## `ss::section <color> <content> [prefix] [suffix]`

This command displays prompt section prefixed with `prefix`, suffixed with `suffix` and `content` painted in `color`. **Bold** style is applied by default.

`prefix`, `suffix` and `content` can contain escapes to set additional foreground color, background color and other visual effects. Read more about escapes in [13 Prompt Expansion](http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html) section of Zsh documentation.

If `SPACESHIP_PROMPT_PREFIXES_SHOW` is `false` or if the section is not the first in the prompt, then `prefix` will be omitted.

If `SPACESHIP_PROMPT_SUFFIXES_SHOW` is `false`, then `suffix` will be omitted.

Both `prefix` and `suffix` are optional. They are equal to empty strings by default.

### Arguments

1. `color` _Required_ — Color for displaying the `content`. Can be any of [basic colors](https://wiki.archlinux.org/index.php/zsh#Colors) or [color codes](https://upload.wikimedia.org/wikipedia/commons/1/15/Xterm_256color_chart.svg).
2. `content` _Required_ — The content of the section. Can be any valid value or result of command execution.
3. `prefix` _Optional_ — Prefix before `content`. Usually, it's the value of `SPACESHIP_*_PREFIX`.
4. `suffix` _Optional_ — Suffix after `content`. Usually, it's the value of `SPACESHIP_*_SUFFIX`.

### Example

```zsh
# Display prompt section with prefix and suffix
# Backslash is used to escape line ending
ss::section \
  "$SPACESHIP_SECTION_COLOR" \
  "$SPACESHIP_SECTION_SYMBOL$section_content" \
  "$SPACESHIP_SECTION_PREFIX" \
  "$SPACESHIP_SECTION_SUFFIX"

# Display prompt section without prefix and suffix
ss::section "$color" "$SPACESHIP_CHAR_SYMBOL"
```

## `ss::func_defined <function>`

The same as [`ss::exists`](#spaceshipexists-command), but for functions. It returns zero exit code if a `function` has been defined previously and non-zero if `function` hasn't.

You can use this utility to check if a user has previously defined a function or not. Spaceship uses this utility internally to check if a custom section has been defined and available for execution.

### Arguments

1. `function` _Required_ — a function that needs to be checked.

### Example

```zsh
# Check if section has been defined
if ss::func_defined spaceship_section; then
  spaceship_section
else
  # section is not found
fi
```

## `ss::is_git`

This utility returns zero exit code if a current working directory is a Git repository and non-zero if it's not.

### Example

```zsh
# Return if current directory is not a git repository
ss::is_git || return
```

## `ss::is_hg`

The same as [`ss::is_git`](#spaceshipisgit), but for Mercurial repositories. This utility returns zero exit code if a current working directory is a Mercurial repository and non-zero if it's not.

### Example

```zsh
# Return if current directory is not a Mercurial repository
ss::is_hg || return
```

## `ss::deprecated <option> [message]`

This utility checks if `option` variable is set and if it is, prints the `message`. The `message` supports escapes to set foreground color, background color and other visual effects. Read more about escapes in [13 Prompt Expansion](http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html) section of Zsh documentation.

### Arguments

1. `option` _Required_ — the name of a deprecated variable. If this variable is set (contains any value), then `"%B$deprecated%b is deprecated.` will be printed. `%B` and `%b` is escapes to set the bold style for text.
2. `message` _Optional_ — a string for additional deprecation message.

### Example

```zsh
# Check if SPACESHIP_BATTERY_ALWAYS_SHOW is set
ss::deprecated SPACESHIP_BATTERY_ALWAYS_SHOW "Use %BSPACESHIP_BATTERY_SHOW='always'%b instead."
#> SPACESHIP_BATTERY_ALWAYS_SHOW is deprecated. Use SPACESHIP_BATTERY_SHOW='always' instead.
```

## `ss::displaytime <seconds>`

This utility converts `seconds` into a human-readable format. It splits `seconds` into days (`d`), hours (`h`), minutes (`m`) and seconds (`s`).

### Arguments

1. `seconds` _Required_ — seconds for conversion into the readable format.

### Example

```zsh
ss::displaytime 123456
#> 1d 10h 17m 36s
```
