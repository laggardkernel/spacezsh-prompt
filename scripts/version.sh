#!/usr/bin/env zsh

main() {
  new_version=$(command grep -E '"version": "v?([0-9]+\.){1,}' package.json | cut -d\" -f4 2> /dev/null)
  filename="$PWD/spacezsh.zsh"

  sed -e "s/SPACESHIP_VERSION='.*'/SPACESHIP_VERSION='$new_version'/g" "$filename" >"$filename.bak"
  mv -- "$filename.bak" "$filename"

  git add spacezsh.zsh
}

main "$@"
