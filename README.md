<h1 align="center">
  <!-- <a href="https://github.com/laggardkernel/spacezsh-prompt">
    <img alt="space →~ prompt" src="https://cloud.githubusercontent.com/assets/3459374/21679181/46e24706-d34b-11e6-82ee-5efb3d2ba70f.png" width="400">
  </a> -->
  <br>Spacezsh 🚀⭐<br>
</h1>

<h4 align="center">
  <a href="http://zsh.org" target="_blank"><code>ZSH</code></a> prompt for Astronauts.
</h4>

<p align="center">
  <a href="http://zsh.org/">
    <img src="https://img.shields.io/badge/zsh-%3E%3Dv5.2-blue.svg"
      alt="Zsh Version" />
  </a>
  <a href="https://opensource.org/licenses/MIT">
    <img src="https://img.shields.io/badge/License-MIT-c34435.svg"
      alt="MIT license" />
  </a>
</p>

<div align="center">
  <h4>
    <a href="#installing">Install</a> |
    <a href="#features">Features</a> |
    <a href="./docs/Options.md">Options</a> |
    <a href="./docs/API.md">API</a>
  </h4>
</div>

<div align="center">
  <sub>Built with ❤︎ by
  <a href="https://github.com/laggardkernel">laggardkernel</a> and
  <a href="#contributors">contributors </a></sub>
  <br>
  <sub>A fork of <a href="https://github.com/denysdovhan/spaceship-prompt">Spaceship ZSH</a> by
  <a href="https://denysdovhan.com/">Denys Dovhan</a></sub>
</div>

<br>

Spacezsh is an **async** prompt tries to do things right in the ZSH way. It introduced a lot of ZSH goodies including:
- Conditional async on each section/segment.
- 100% `promptinit` compliant.
- `autoload` all of the functions.
- Speed the prompt up with ZSH built-in utilities
  - Env var `$EPOCHREALTIME` replaces external command `date` in `exec_time` section;
  - ZSH module `jobstates` replaces external command `jobs` in `jobs` section;
  - Section `vcs` based on ZSH utility `vcs_info` replaces section `git` and `hg`. It also adds support for SVN;
  - Complete vi mode with more type of hooks being used for a better detection of mode changes.
  - Trigger prompt redrawing on hook `chpwd` where hook `precmd` is not triggered;
- For more changes, new features, new sections brought by Spacezsh, check the [CHANGELOG](./CHANGELOG.md) for detail.

<p align="center">
  <img alt="Spaceship with Hyper and One Dark" src="https://user-images.githubusercontent.com/10276208/36086434-5de52ace-0ff2-11e8-8299-c67f9ab4e9bd.gif" width="980px">
</p>

<sub>Visit <a href="./docs/Troubleshooting.md#why-doesnt-my-prompt-look-like-the-preview">Troubleshooting</a> for instructions to recreate this terminal setup.</sub>

## Features

- Clever hostname and username displaying.
- Prompt character turns red if the last command exits with non-zero code.
- (New) Prompt character changes with vi modes.
- (New) Current branch and status support for Git, Mercurial, SVN:
  - `?` — untracked changes;
  - `◌` — unstaged changes;
  - `●` — staged/uncommitted changes in the index;
  - `$` — stashed changes;
  - `⇡` — ahead of remote branch;
  - `⇣` — behind of remote branch;
  - The following states are supported but disable by default:
    - `»` — renamed files;
    - `✘` — deleted files;
    - `=` — unmerged changes;
    - changeset/commit id;
- Indicator for jobs in the background (`✦`).
- Current Node.js version, through nvm/nodenv/n (`⬢`).
- Current Ruby version, through rvm/rbenv/chruby/asdf (`💎`).
- Current Elm version (`🌳`)
- Current Elixir version, through kiex/exenv/elixir (`💧`).
- Current Swift version, through swiftenv (`🐦`).
- Current Xcode version, through xenv (`🛠`).
- Current Go version (`🐹`).
- Current PHP version (`🐘`).
- Current Rust version (`𝗥`).
- Current version of Haskell GHC Compiler, defined in stack.yaml file (`λ`).
- Current Julia version (`ஃ`).
- (New) Currnet Vagrant machine status (`Ｖ`)
- Current Docker version and connected machine (`🐳`).
- Current Amazon Web Services (AWS) profile (`☁️`) ([Using named profiles](http://docs.aws.amazon.com/cli/latest/userguide/cli-multiple-profiles.html)).
- Current Google Cloud Platform gcloud active configuration (`☁️`).
- Current Python virtualenv (`🐍`).
- Current .NET SDK version, through dotnet-cli (`.NET`).
- Current Ember.js version, through ember-cli (`🐹`).
- Current Kubectl context (`☸️`).
- Current Terraform workspace (`🛠`).
- Package version, if there's is a package in current directory (`📦`).
- Current battery level and status:
  - `⇡` - charging;
  - `⇣` - discharging;
  - `•` - fully charged.
- Current Vi-mode mode ([with handy aliases for temporarily enabling](./docs/Options.md#vi-mode-vi_mode)).
- Optional exit-code of last command ([how to enable](./docs/Options.md#exit-code-exit_code)).
- Optional time stamps 12/24hr in format ([how to enable](./docs/Options.md#time-time)).
- Execution time of the last command if it exceeds the set threshold.

Want more features? Please, [open an issue](https://github.com/laggardkernel/spacezsh-prompt/issues/new/choose) or send pull request.

## Requirements

To work correctly, you will first need:

- [`zsh`](http://www.zsh.org/) (v5.2 or recent) must be installed.
- [Powerline Font][powerline] must be installed and used in your terminal. Or use [Nerd Font][nerd-fonts].

## Installing

### [zplugin]
Use this command in your `.zshrc` to load Spacezsh:

```shell
# Optional: compile source files into bytecode to speed up init
# zplugin ice pick'spacezsh.zsh' \
#   compile'{presets/^(*.zwc),lib/**/^(*.zwc),sections/^(*.zwc)}'
zplugin light laggardkernel/spacezsh-prompt
```

### [prezto]

TODO

### [oh-my-zsh]

Clone this repo:

```zsh
git clone https://github.com/laggardkernel/spacezsh-prompt.git "$ZSH_CUSTOM/themes/spacezsh-prompt" --depth=1
```

Symlink `spaceship.zsh-theme` to your oh-my-zsh custom themes directory:

```zsh
ln -s "$ZSH_CUSTOM/themes/spacezsh-prompt/spacezsh.zsh-theme" "$ZSH_CUSTOM/themes/spacezsh.zsh-theme"
```

Set `ZSH_THEME="spacezsh"` in your `.zshrc`.

## Customization

Spacezsh works well out of the box, but you can customize almost everything if you want.

- [**Options**](./docs/Options.md) — Tweak section's behavior with tons of options.
- [**API**](./docs/API.md) — Define a custom section that will do exactly what you want.

You have ability to customize or disable specific elements of Spacezsh. All options must be overridden in your `.zshrc` file.

## Troubleshooting

Having trouble? Take a look at out [Troubleshooting](./docs/Troubleshooting.md) page.

Still struggling? Please, [file an issue](https://github.com/laggardkernel/spacezsh-prompt/issues/new/choose), describe your problem and we will gladly help you.

## Credits

- [denysdovhan/spaceship-prompt](https://github.com/denysdovhan/spaceship-prompt).
- Conditional async per segment ported from [dritter's implementaion](https://github.com/bhilburn/powerlevel9k/pull/1176).
- [mafredri/zsh-async](https://github.com/mafredri/zsh-async), an asynchronous library.
- [robobenklein/zinc](https://github.com/robobenklein/zinc), neat prompt framework where the neat framework and custom hook system are borrowed.
- [Powerlevel9k/powerlevel9k](https://github.com/Powerlevel9k/powerlevel9k), used as a reference for section optimization.

## License

MIT © [laggardkernel](https://github.com/laggardkernel)

<!-- References -->

[oh-my-zsh]: http://ohmyz.sh/
[prezto]: https://github.com/sorin-ionescu/prezto
[zplugin]: https://github.com/zdharma/zplugin/
[nerd-fonts]: https://github.com/ryanoasis/nerd-fonts
[powerline]: https://github.com/powerline/fonts
