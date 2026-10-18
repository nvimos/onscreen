# Neovim setup

## Files

maybe separate plugin

     log.lua       - write errors to a file, maybe separate plugin
     fn.lua      - functions in general, maybe a separate plugin
     fu-test.lua - nicify movie-dir names (for searching imdb, etc)

init / boot

     boot - init lazy vim
     init.lua    - Safeload the rest, mapleader, colorscheme, font(?), START_DIRS(?)
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
     oil/        - functions for nvim-oil, by topic; oil/init.lua lists the files
     oil-actions.lua - oil actions (desc + callback), wires map-oil.lua to them
     f2.lua      - <F2> context picker: make targets (telescope) run via overseer
     fu.lua      - user functions (lua) :UserFunction
     hilite.lua  - colors, ui, syntax (lua)
     ui-select.lua - vim.ui.select in a telescope dropdown (code actions etc.)

mappings and funcs for them

     fn-keys.lua - custom functions for bound keys
     map-convoluted.lua - keymaps, hard to grok
     map-jolemak.lua    - keymaps, custom layout quirks
     map-lsp.lua        - keymaps, code-actions, diagnostics navigation
     map-oil.lua        - keymaps, oil buffers: key -> action name; which-key groups
     map-telescope.lua  - keymaps, telescope actions, shortcuts
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
