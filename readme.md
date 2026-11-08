# On-Screen Nvim

A Neovim 0.11+ config, assembled on Win11, managed with lazy.nvim.
Aims to do a lot but still hopefully do it well.

## Why it exists

The distributions I tried were either slow and far from Vim (animated
popups, lagging input, a file tree eating the screen), or good starting
points whose LSP, completion and diagnostics didn't work together.

On-Screen Nvim sits in between: a ready-to-go coding setup that still
feels like Vim. Not a Vi clone, not Eclipse, not Jetbrains, not Vscode,
not Sublime but something in between. It's meant to be plain on the
surface and capable underneath, you discover what it can do by digging.
This is the way I learned Vim, and the way I keep learning Nvim.

Hopefully someone else finds it useful and appreciates the same balance.

## Goals

- As responsive as Vim: input shows up at once, no animated messages.
- Startup below a second; plugins load lazily.
- Screen space for text: floats and sidebars only on demand; files in oil.
- The Vim feel: built-in behaviour first, plugins where they add something.
- Coding workflows that fit together: native LSP, blink.cmp, lint,
  diagnostics, tests, git and AI helpers, with keys in the same patterns.
- Projects that work out of the box: a PHP project with its HTML, CSS, JS,
  framework, tests and tooling is linted, parsed and understood without
  days of setup.

  Real projects mix (a Drupal site, a Symfony app with React), and sooner
  or later you need a debugger; nobody ships that setup configured. It
  should feel the same in C or Go. PHP is the starting point, Go is next.
- Languages on demand: a small default set, more with `:EnableLang`; a new
  language plugs in with its own rules.
- Kubernetes manifests: component docs fetched once and shown as `:help`,
  `K` hover or a popup, not in a browser.
- Nvim as the interface to the system: terminals, git, WSL and Docker
  without leaving the editor.
- Plain on the surface: which-key, a cheatsheet (`readme.cheatsheet.md`)
  and `<F2>` menus when you look for them.
- Checked by tests: mini.test cases in `tests/` (`make help`).
- Simple Control Helm feeling: `<F1>` `<F2>` `<F3>` do more than open help.


## Layout

- `init.vim`: loads lazy.nvim, then the `genja` profile, with a small fallback if that fails.
- `lua/genja/`: options, keymaps, autocommands; `lua/genja/readme.md` describes each file.
- `lua/lazyp/<topic>/`: plugin specs.
- `tests/`: automated tests.
- `todo-*.md`: plans and backlog.
- `plug-wip/`: plugins written for this config, each its own repo (below).
  A spec loads the local checkout when it's there, else lazy.nvim clones the
  repo, so a fresh clone of the config works without them.
  This Nvim distro is very much a work in progress still.

## Features

### telescope decorator

Any telescope picker can get the same refine keys:
`require('genja-finder').enhance(picker)` wraps it, or call
`attach_shared_keys(map)` in its `attach_mappings`. In the results,
`<M-f>` filters, `<M-x>` excludes, `<BS>` undoes and `<M-n>` matches
exactly; `<C-]>` opens the entry's dir in oil and `<M-t>` opens the
selection in tabs. From `plug-wip/genja-finder.nvim`.

### Eff-Two (context actions)

`<F2>` opens a menu of what you can do right here, collected from the
context: make targets, composer and npm scripts, git add in oil,
diagnostics, languages to switch on, running claude terminals,
`:messages` error locations and markdown actions. Items run through
overseer or floaterm; other code adds its own with `add_task`. Code in
`lua/genja/f2/`, tests in `tests/f2/`.

### Ghost text provider

minuet suggests code as gray text (`<leader>am` per buffer): Codestral by
default, or a local ollama model. Spec: `lua/lazyp/langs-comps/minuet.lua`.

## Plugins

Written for On-Screen Nvim, potentially usable on their own.

| Plugin | What it does |
| --- | --- |
| [genja-ask.nvim](https://github.com/tox2ik/genja-ask.nvim) | ask popup: one question to claude, gemini, copilot, aichat or ollama |
| [genja-claudefterm.nvim](https://github.com/tox2ik/genja-claudefterm.nvim) | Claude Code in a floaterm, one per project |
| [genja-commit.nvim](https://github.com/tox2ik/genja-commit.nvim) | commit popup, gitcommit lint, message generation |
| [genja-completion.nvim](https://github.com/tox2ik/genja-completion.nvim) | LSP servers, blink.cmp completion, one module per language (folder `genja-completion011.nvim`) |
| [genja-finder.nvim](https://github.com/tox2ik/genja-finder.nvim) | live grep and live find pickers (telescope) |
| [genja-oily.nvim](https://github.com/tox2ik/genja-oily.nvim) | hide oil.nvim entries listed in `.oily` |
| [genja-paste-ai.nvim](https://github.com/tox2ik/genja-paste-ai.nvim) | send a query to a web or AI search in the browser |
| [genja-recent.nvim](https://github.com/tox2ik/genja-recent.nvim) | recent files, frecency ranking |
| [genja-splitpad.nvim](https://github.com/tox2ik/genja-splitpad.nvim) | padding column next to the split separator |
| [genja-startdirs.nvim](https://github.com/tox2ik/genja-startdirs.nvim) | start directories: list, jumps, ranking |
| [genja-statusline.nvim](https://github.com/tox2ik/genja-statusline.nvim) | statusline, tabline, winbar |
| [genja-util.nvim](https://github.com/tox2ik/genja-util.nvim) | helpers the others share |
| [keymaps.nvim](https://github.com/tox2ik/keymaps.nvim) (fork) | keymap cheatsheet with usage counts |
