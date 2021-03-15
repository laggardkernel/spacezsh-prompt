# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Removed

- Drop hack solution for line-init, line-finish conflict in vi mode. No point to
  use these zle hook widgets together. Just disable one of them.

## [4.6.0] - 2021-02-01

### Added

- Integrate `conda`, `venv`, `pyenv` into new section `python`

### Fixed

- `docker` section: suppress warning in stdout when docker daemon is not available
- Fix stderr being mapped to `/dev/null` by upgrade `zsh-async` to 1.8.5
- Fix vi status conflict with plugin [zsh-vim-mode](https://github.com/softmoth/zsh-vim-mode)
  in pipenv shell or poetry shell

### Removed

- Drop submodule `gitstatus`, whose installation is left user themselves

### Upstream changes

- Use `SPACESHIP_XCODE_SHOW_*` for `xcode` section, which formerly
  share settings `SPACESHIP_SWIFT_SHOW_*` with `swift`
- New section `gcloud`
- Update instructions to do shallow clone on installation
- Force `command grep` in case it's shadowed by aliases

## [4.5.0] - 2020-03-01

### Added

- Merge with upstream to 6319158

### Changed

- Remove useless subshell in `utils.zsh`

### Fixed

- Use a temp file to pass var back from the worker pseudo shell, which fixes #1, #2
- iTerm2 integration: avoid duplicate markers
- Shallow clone `gitstatus`

## [4.4.0] - 2019-09-12

### Added

- Rename project as "Spacezsh".
- `CHANGELOG.md`
- Fix `README.md` and other documentations.

### Changed

- Reduce number of sections enable in the default conf. Give the option back to users.

### Fixed

- Redraw prompt on working directory changes with hook `chpwd`, where hook `precmd` is not triggered.
- Fix battery status query from [@Runrioter](https://github.com/denysdovhan/spaceship-prompt/pull/640).
- Replace `${=}` with `(s)` for word splitting to avoid `IFS` overridden in the outer scope.

### Removed

- Remove `sz::func_defined`. `(( $functions[foo] ))` is faster than
  `typeset -f + "foo"`. Do things in the ZSH way.

## [4.3.0] - 2019-08-28

### Added

- New section `ssh` to add an SSH connection indicator.
- Cursor style support for section `vi_char`.
- New section `vcs` replaces section `git` and `hg`.

### Changed

- Optimization: remove unnecessary sub-shells in section `git`, `hg`.
- Optimization: skip redundant color escape code concatenation in `ss::section`.

### Fixed

- Typo fix in section renderer `ss::section`.

## [4.2.0] - 2019-07-14

### Added

- `autoload` function: setup functions, library functions, sections,
  borrowed from [robobenklein/zinc](https://github.com/robobenklein/zinc).
- Hook support for sections, borrowed from [robobenklein/zinc](https://github.com/robobenklein/zinc)
  and [`add-zsh-hook`](https://github.com/zsh-users/zsh/blob/master/Functions/Misc/add-zsh-hook).
- New utility functions: `ss::set_default`, `ss::var_defined`.

### Changed

- Enable async for sections in the "default" conf.
- Improve prompt cleanup function.
- Rename `vi_char` as `char`, as the character symbol section.
- Deprecate `git`, `git_status`, `git_branch`, `hg`, `hg_status`, `hg_branch`.
- Deprecate `vi_mode`. Vi mode indicator is integrated into section `char`.

## [4.1.0] - 2019-07-11

### Added

- Fully compliant with the [`promptinit` standard](https://github.com/zsh-users/zsh/blob/master/Functions/Prompts/promptinit)
  borrowed from [robobenklein/zinc](https://github.com/robobenklein/zinc).

### Changed

- Replace `spaceship::section <color> [prefix] <content> [suffix]` with
  `spaceship::section <color> <content> [prefix] [suffix]`.
  Move optional arguments to the end for optimization.
- Optimization: pass output with global variable in section renderer to remove sub-shells.
- Optimization: cache async states of sections.

## [4.0.0] - 2019-07-06

### Added

- Conditional async generator, enable async for section with `section::async`.
- Placeholder support for unrendered async section.
- Right prompt begins at the same line with the left one.
- Same name custom sections override built-in sections.
- New section `gitstatus`.
- New section `vagrant` from [@guilhermeleobas](https://github.com/denysdovhan/spaceship-prompt/pull/376).
- New utility function `spaceship::upsearch`.
- Add `.ruby-version` file check for `rbenv` in section `ruby`.
  Similar checks are added for `nodenv`, `pyenv`.
- New section `vi_char` with integration of prompt character and vi_mode indicator.
- Add mercurial repo detection in section `dir`.
- `autoload` rarely used functions, like environment detection for bug report.

### Changed

- `exec_time` section: Duration calc with variable `EPOCHREALTIME` but not
  external command `date`.
- Optimization: remove unnecessary pipes to reduce cost on spawning processes.
- Optimization: replace `command -v` with faster `(( $+commands[aws] ))`.
  Do things in the ZSH way.
- Recursive search for file existence in sections like `docker`, `dotnet`,
  `exlir`, etc, in commit [f63fb84](https://github.com/laggardkernel/spacezsh-prompt/commit/f63fb8449b6b3b3706f086ba6ab584b679dce247).
- Optimization: priority adjustment for file existence check in `docker`.
- Optimization: trigger `vcs_info` on demand, whenever in a `git` repo.
- Optimization: faster repo detection in section `dir`.
- Optimization: query background jobs with `jobstates` but not external command
  `jobs`. Do things in the ZSH way.

### Fixed

- Prompt refresh in `vi_mode` in the new async mode.
- Reset and redisplay prompt to avoid previous prompt being eaten up in async mode.

### Removed

- Remove utility `spaceship::exists`. `(( $+commands[foo] ))` is faster than
  `command -v foo` in ZSH. Do things in the ZSH way.

## TODO

- Improve repo detection support in section `dir`
- Rewrite `sz::section` to avoid pass variable from the worker back to the main shell
- Project files cleanup
- Remove the totally useless prepositions

[Unreleased]: https://github.com/laggardkernel/spacezsh-prompt/compare/v4.6.0...HEAD
[4.6.0]: https://github.com/laggardkernel/spacezsh-prompt/compare/v4.5.0...4.6.0
[4.5.0]: https://github.com/laggardkernel/spacezsh-prompt/compare/v4.4.0...v4.5.0
[4.4.0]: https://github.com/laggardkernel/spacezsh-prompt/compare/v4.3.0...v4.4.0
[4.3.0]: https://github.com/laggardkernel/spacezsh-prompt/compare/v4.2.0...v4.3.0
[4.2.0]: https://github.com/laggardkernel/spacezsh-prompt/compare/v4.1.0...v4.2.0
[4.1.0]: https://github.com/laggardkernel/spacezsh-prompt/compare/v4.0.0...v4.1.0
[4.0.0]: https://github.com/laggardkernel/spacezsh-prompt/compare/8ccc6fb...v4.0.0
