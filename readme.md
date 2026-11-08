# On-Screen Nvim

A Neovim 0.11+ config, assembled on Win11, managed with lazy.nvim.
Aims to do a lot but still hopefully do it well.
See [install.md](install.md) for how to install it.

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
- Plain on the surface, yet acting as a tour guide. A neat which-key setup,
  a cheatsheet (`readme.cheatsheet.md`) and `<F2>` context-aware actions.
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

### Commit popup with message writing

Committing opens a small message window next to the staged files, with
lint on the subject and body as you type. A language model can write the
message from the staged diff, and you can switch between models on the
fly: Claude, Copilot, Gemini, aichat or a local ollama.

### Claude Code beside the code

One Claude Code terminal per project, in a split that comes and goes. The
selection or the current spot in a file is pasted into it with its path
and line, and other plugins can send it prompts. The running terminals
are listed in the context menu.

### Start dirs and recent files

A plain text list of start directories, ranked by how often and how
recently they are used, with jumps to the top ones. Recent files follow
their own rules and the same ranking, where edits weigh more than views.

### Tests that know their speed

The config tests itself: servers attach, completion answers, linters
report, plugins behave. Every case is timed; the slow ones are left out
of the default run and listed, and failed cases rerun on their own.

### Eff-Two (context actions)

`<F2>` opens a menu of what you can do right here, collected from the
context: make targets, composer and npm scripts, git add in oil,
diagnostics, languages to switch on, running claude terminals,
 error locations from :messages and markdown actions.
Some actions run through overseer or floaterm.

### Oil as the file manager

Directories are buffers you edit (oil.nvim), with previews sized to fit,
git add and staged diffs from the listing, sorting that cycles, and a
per-folder `.oily` file that hides clutter on top of the dotfile rule.

### telescope decorator

Every telescope picker can get the same refine tools: narrow the results
by more words, drop the ones you don't want, step back, match exactly, and
open entries in oil or in tabs. One way of working across all pickers.
From `plug-wip/genja-finder.nvim`.

### Ghost text provider

minuet suggests code as gray text (`<leader>am` per buffer): Codestral by
default or via ollama.

### Quiet diagnostics

Only the first few diagnostics per severity are drawn in a buffer, so a
file with fifty warnings stays readable; all of them are still in the
lists and floats. Their messages line up in one column per paragraph
instead of trailing each line.

### Cheatsheet

Every key and command the config adds, grouped by plugin and topic, each
naming the file that sets it: `readme.cheatsheet.md`. It is kept up to
date with the config: a new key lands there in the same change.

Inside Neovim, `<leader>?` opens a popup with the keys organized by
category. It is searchable and filters by mode (normal, visual, insert
and the rest).

### Unsaved q

Quitting with modified buffers doesn't stop at an error. A picker lists
them; write each, reset it to the file on disk, or drop it, and Neovim
quits once the list is empty. Buffers without a file get a dated scratch
name to save under.

### :Messages

The message history in a buffer you can search and copy, where each
`file:line` in an error opens that file at that line. The locations can
also go to the quickfix or location list, or to the context menu.

### Ask popup

A one-question popup to any of several backends (Claude, Gemini, Copilot,
aichat, ollama), for the quick question that doesn't need a chat. The
question can go to the Claude terminal instead, to keep the conversation.

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
