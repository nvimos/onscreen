# Neovim setup

## Files

     boot - init lazy vim
     api.lua     - source from other config lua scripts
     auto.lua    - autocmds in lua
     env.lua     - shell vars
     fn-keys.lua - custom functions for bound keys
     fn-oil.lua  - functions for nvim-oil
     fn.lua      - functions in general, maybe a separate plugin
     ft.lua      - filetype settings, maybe merge with something
     fu-test.lua - nicify movie-dir names (for searching imdb, etc)
     fu.lua      - user functions (lua) :UserFunction
     hilite.lua  - colors, ui, syntax (lua)
     init.lua    - Safeload the rest, mapleader, colorscheme,
                  - font(?), START_DIRS(?)
     lazy-spec.lua - pluginspec imports and array
     log.lua       - write errors to a file
     map-convoluted.lua - keymaps, hard to grok
     map-jolemak.lua    - keymaps, custom layout quirks
     map-lsp.lua        - keymaps, code-actions, diagnostics navigation
     map-telescope.lua  - keymaps, telescope actions, shortcuts
     map-zero.lua       - keymaps, essential that must not fail
     opt.lua            - neovim configuration
     readme.discovery.md - stuff to checkout related to neovim config, plugins
     zexp.lua            - experiments


Vimscript

     vimrc.almalinux.vim - almalinux solid config
     hilite.vim          - colors, syntax, ui
     fn.vim              - user functions
     auto-alias.vim      - aucmds, shorthand commands, :com-aliases

