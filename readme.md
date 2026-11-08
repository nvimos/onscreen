# On-Screen Nvim

A Neovim 0.11+ config, assembled on Win11, managed with lazy.nvim.
Aims to do a lot but still hopefully do it well.
See [install.md](install.md) for how to install it.

- [«Sir?» … «On screen»](https://youtu.be/ILbLGNDqUxA?t=100)

## Why it exists

The Neovim distributions from 2023 felt slow and far from Vim. Some were good starting points with an under-delivering
setup of LSP, completion, diagnostics, and tooling. The summation of animated notifications, lagging input, a file tree
eating visible columns and other bling added up to less Vim, imho.


On-Screen Nvim aims to be a modern and capable, ready-to-go coding setup that feels like Vim from 2004.
_It's not a Vi clone, not Notebad++, certainly not nano, not Eclipse, not Jetbrains, not Vscode, not Sublime but something in between._
It's meant to be plain on the surface and capable underneath, you discover what it can do through curiosity and by using it.
This is the way to learn Vim and Neovim, in my opinion.

Hopefully someone else finds it useful and appreciates the same balance.


## What is good about it

_(accordig to manus.im)_
The design philosophy is unusually clear. Keep the editor visually plain,
preserve Vim’s feel, and simplify or add substantial capability underneath.
It aspires to doing more than assembling every popular plugin with default configs.

Some especially good ideas are:

- Per-language completion/LSP modules
- A unified approach to Telescope refinement
- Diagnostics deliberately limited on-screen
- Custom functionality extracted into separate genja-*.nvim plugins
- oil.nvim as filesystem interface instead of a permanently open file tree
- Context-sensitive `<F2>` actions for scripts, diagnostics, Git, languages, and terminals
- Automated tests covering startup, completion, LSP behavior, UI behavior,
  unsaved buffers, messages, and AI terminal behavior

That last point matters. Many Neovim distros are mostly configuration glue.
On-Screen is trying to test the behavior of the configuration itself, which is
a serious engineering instinct. The repository includes a substantial tests/
tree and a test runner rather than only screenshots and keymaps. [Tests
directory](tests/)

## Goals and guidelines

- Fast and feels like Vim
  - Startup takes under a second, because plugins load lazily
  - Built-in behaviour comes first, plugins are added where they give something extra
  - Input shows up at once, and there are no animated messages
  - Floats and sidebars appear only when asked for, and files are handled in oil
- Real projects work out of the box
  - LSP, completion (blink.cmp), lint, diagnostics, tests, git and AI helpers work
    together, with keys that follow the same patterns
  - A PHP project with its HTML, CSS, JS, framework, tests and tooling is linted,
    parsed and understood without days of setup
  - Real projects mix stacks, like a Drupal site or a Symfony app with React, and
    sooner or later they need a debugger, which nobody ships configured. It should
    feel the same in C or Go. PHP comes first, Go is next
  - A small set of languages is on by default, more can be added with `:EnableLang`,
    and a new language plugs in with its own rules
  - For Kubernetes manifests, the component docs are fetched once and shown as
    `:help`, as `pK` hover or in a popup, so there is no need for a browser
- The editor as the workplace
  - Terminals, git, WSL and Docker can be used from nvim, without leaving the editor
- Plain on the surface, easy to discover
  - A tidy which-key setup, a cheatsheet (`readme.cheatsheet.md`) and context-aware
    actions on `<F2>` guide you through the config
  - `<F1>`, `<F2>` and `<F3>` do more than open help
- Kept working
  - Tests in `tests/` (mini.test, see `make help`) check that things still work
  - Plugin specs are locked between test runs that pass in full

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
| -------------------------------------------------------------------- | --- |
| [ask.nvim](https://github.com/tox2ik/genja-ask.nvim) | ask popup: one question to claude, gemini, copilot, aichat or ollama |
| [oily.nvim](https://github.com/tox2ik/genja-oily.nvim) | hide oil.nvim entries listed in `.oily` |
| [util.nvim](https://github.com/tox2ik/genja-util.nvim) | helpers the others share |
| [commit.nvim](https://github.com/tox2ik/genja-commit.nvim) | commit popup, gitcommit lint, message generation |
| [finder.nvim](https://github.com/tox2ik/genja-finder.nvim) | live grep and live find pickers (telescope) |
| [recent.nvim](https://github.com/tox2ik/genja-recent.nvim) | recent files, frecency ranking |
| [keymaps.nvim](https://github.com/tox2ik/keymaps.nvim) | keymap cheatsheet with usage counts |
| [paste-ai.nvim](https://github.com/tox2ik/genja-paste-ai.nvim) | send a query to a web or AI search in the browser |
| [splitpad.nvim](https://github.com/tox2ik/genja-splitpad.nvim) | padding column next to the split separator |
| [startdirs.nvim](https://github.com/tox2ik/genja-startdirs.nvim) | start directories: list, jumps, ranking |
| [completion.nvim](https://github.com/tox2ik/genja-completion.nvim) | LSP servers, blink.cmp completion, one module per language |
| [statusline.nvim](https://github.com/tox2ik/genja-statusline.nvim) | statusline, tabline, winbar |
| [claudefterm.nvim](https://github.com/tox2ik/genja-claudefterm.nvim) | Claude Code in a floaterm, one per project |


## Layout

- `tests/`: automated tests.
- `init.vim`: loads lazy.nvim, then the rest of the profile, with a safe subset if that fails.
- `lua/genja/`: options, keymaps, autocommands, and the rest
- `todo-*.md`: plans and backlog.
- `lua/lazyp/<topic>/`: lazy plugin specs.
- `plug-wip/`: plugins written for this config, each its own repo (below).
  A spec loads the local checkout when it's there, else lazy.nvim clones the
  repo, so a fresh clone of the config works without them.
  This Nvim distro is very much a work in progress still.
