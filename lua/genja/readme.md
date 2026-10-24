# Neovim setup

## Files

maybe separate plugin

     log.lua       - write errors to a file, maybe separate plugin
     fn.lua      - functions in general, maybe a separate plugin
     fu-test.lua - nicify movie-dir names (for searching imdb, etc)

init / boot

     boot - init lazy vim
     init.lua    - Safeload the rest, mapleader, colorscheme, font(?)
     local/      - per-machine files, gitignored: startdirs.txt (plug-wip/genja-startdirs.nvim); example next to it
     lazy-spec.lua - pluginspec imports and array

config

     auto.lua    - autocmds in lua
     intro.lua   - startup intro screen without the charity lines (virtual lines, from auto.lua)
     opt.lua     - neovim configuration
     env.lua     - shell vars
     ft.lua      - filetype settings, maybe merge with something

custom funcs

     actions.lua - g. / <LocalLeader>/ action menu (telescope), cur: = item under cursor
     api.lua     - source from other config lua scripts
     claude.lua  - idea #19 A: claude in a floaterm, <leader>pc paste, <leader>pC prompt popup
     oil/        - functions for nvim-oil, by topic; oil/init.lua lists the files, oil/plug/ holds the self-contained ones
     oil-actions.lua - oil actions (desc + callback), used by map-oil.lua
     f2/         - <F2> context picker: init.lua (sources, sorting, add_tasks/add_task/remove_tasks API), picker.lua (shared dropdown: main list and make targets), sources adhoc.lua, git.lua (oil only), make.lua; registry.lua stores added tasks; builder.lua is the add_task builder; run.lua runs keys/functions/commands (overseer, floaterm); Makefile + readme.testing.md: tests in tests/f2/
     md-glow.lua - <F2> in markdown: glow preview of the file in a new pwsh window (Windows only)
     fu.lua      - user functions (lua) :UserFunction
     hilite.lua  - colors, ui, syntax (lua)
     ui-select.lua - vim.ui.select in a telescope dropdown (code actions etc.)

mappings and funcs for them

     fn-keys.lua - custom functions for bound keys
     map-convoluted.lua - keymaps, hard to grok
     map-jolemak.lua    - keymaps, custom layout quirks
     map-lsp.lua        - keymaps, code-actions, diagnostics navigation
     map-oil.lua        - keymaps, oil buffers: key -> oil-actions; which-key groups
     map-plugin/        - keymaps for lazy specs: init.lua (registry, looked up by spec file name), <spec name>.lua (keys + keymap functions), health.lua (:checkhealth genja.map-plugin)
     map-telescope.lua  - keymaps, telescope actions, shortcuts
     map-telescope/fn.lua - functions bound in map-telescope.lua
     ask.lua - <M-?> / <leader>pC ask popup: claude -p, claude floaterm, gemini, copilot, aichat (ask/backends/)
     morning.lua - :Morning page: start dirs, recent files, todo items, untested lines (click opens)
     popup-menu.lua - right-click entries per filetype (markdown, oil, LSP) + Morning, on MenuPopup
     recent.lua - <C-F1> picker for genja-recent (frecency), project first, <M-a> all
     lint.lua - nvim-lint linters per filetype (markdown, yaml, ansible via WSL, lua, make, php, workflows, dockerfile, python, vim; editorconfig-checker on all)
     telescope-keymaps.lua - telescope keymaps with refine keys and <M-r> desc group rotation
     map-zero.lua       - keymaps, essential that must not fail

meta, random

     readme.discovery.md - stuff to checkout related to neovim config, plugins
     zexp.lua            - experiments


Vimscript

     vimrc.almalinux.vim - almalinux solid config
     hilite.vim          - colors, syntax, ui
     fn.vim              - user functions
     auto-alias.vim      - aucmds, shorthand commands, :com-aliases


## Oil: hiding entries with .oily

Moved to `plug-wip/genja-oily.nvim` (README.md there). oil shows a folder:
the nearest `.oily` in it or up the tree applies, child folders included.
Wired up in `lua/lazyp/explorer/oil.lua` (`is_hidden_file`, `<LocalLeader>M`).
