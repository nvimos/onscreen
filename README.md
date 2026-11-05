# genja

A Neovim 0.11+ config, Windows first, managed with lazy.nvim.

## Why it exists

I tried several Neovim distributions. They fell into two groups:

- Too slow, and too far from the feel of Vim. Animated notifications and
  messages sliding across the editor bring a desktop paradigm into nvim,
  where it looks out of place. Rendering them, and the delay before typed
  input showed up, made those setups much clunkier than Vim.
- A file tree in a sidebar. Trees have their place (I used NERDTree for
  years), but the sidebar takes screen space I'd rather use for text.
- Good starting points, but without well-integrated workflows for coding:
  LSP, completion, diagnostics and the tools around them were there, but
  didn't work together.

genja sits between those: more than a starter config, less than a full
distribution. It is a ready-to-go setup for coding that still feels like Vim.

I've used Vim since the 2000s. genja is my take on a clean, Vi-like
experience: not a Vi clone, and not an IDE look either. It is capable,
but you find what it can do by digging under the surface, the way you
learn Vim itself. That isn't ideal for everyone, but it's the way I like it.

This is not a contest. Other distributions do many things well; genja is
just another option for people who want the same balance I do.

## Goals

- As responsive as Vim: typed input shows up at once; no animated or
  sliding messages in the editor.
- Fast startup: below a second, ideally. Plugins load lazily, on a
  command, a key or late in startup.
- Screen space for text: no sidebars that stay open or distracting UI.
  Floats and the outline sidebar appear on demand and go away again. Files are
  browsed with oil, a directory listing you edit like a buffer.
- The Vim feel: built-in Vim and Neovim behaviour first, plugins where they
  add something.
- Coding workflows that fit together: LSP through the native
  `vim.lsp.config` API, completion (blink.cmp), lint, diagnostics, tests,
  git, and AI helpers working in the same buffers with keys that follow
  the same patterns.
- Projects that work out of the box. Take a PHP project: PHP, HTML, CSS
  and JavaScript in one tree, maybe Symfony, Laravel, Drupal or WordPress,
  tests in PHPUnit, Pest or Behat, tooling from Composer and npm or Bun.
  genja should lint it, understand the project, highlight and parse every
  language in it, and pick up its tooling and `.editorconfig`, without days
  of setup.

  A "PHP project" is rarely only PHP: a Drupal site, a Symfony app with a
  React front end. The framework, the front end and a test framework creep
  in, and nobody ships a configured setup for that mix. PHP comes first;
  Go projects should get the same feel next.
- Languages on demand: a conservative default set, more with `:EnableLang`,
  per machine in a local file. PHP and Go get full project workflows; C is
  for reading and navigating. A new language (Flutter, or whatever comes
  next) plugs in with its own rules, without the config shipping every
  language up front.
- Docs where you write. Kubernetes manifests are the next case: the valid
  values depend on the ingress, router or autoscaler in use. genja should
  fetch those components' docs once and show them the Vim way, as `:help`
  pages, `K` hover or a popup, instead of sending you to a browser.
- nvim as the interface to the system for coding work: terminals
  (PowerShell, Git Bash), git, WSL distros and Docker containers, without leaving the
  editor for simple tasks. On Windows that fills the gap a Linux desktop
  used to fill.
- Plain on the surface: no IDE look. Features are there when you look for
  them: which-key groups, a cheatsheet (`readme.cheatsheet.md`), `<F2>`
  menus.
- Checked by tests: `tests/` runs mini.test cases for LSP, completion,
  lint and the in-repo plugins (`make help` in `tests/`).

## How it's meant to be used

Start nvim in the folder you're working in and open a bunch of tabs: that's
the work session. Open splits when you need them. Tabs come first because
they're simpler to navigate and simpler to close.

## Status

Personal config in active use. Install from a clean machine and Linux
support have not been tested yet.

## Layout

- `init.vim`: loads lazy.nvim, then the `genja` profile, with a small
  fallback if that fails.
- `lua/genja/`: options, keymaps, autocommands; `lua/genja/readme.md`
  describes each file.
- `lua/lazyp/<topic>/`: plugin specs.
- `plug-wip/`: plugins written for this config (finder, completion,
  statusline, commit popup, ask popup, Claude terminal, and others); most
  have their own README.
- `tests/`: automated tests.
- `todo-*.md`: plans and backlog.
