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
     opt.lua     - neovim configuration
     env.lua     - shell vars
     ft.lua      - filetype settings, maybe merge with something

custom funcs

     api.lua     - source from other config lua scripts
     fn-oil.lua  - functions for nvim-oil
     fu.lua      - user functions (lua) :UserFunction
     hilite.lua  - colors, ui, syntax (lua)

mappings and funcs for them

     fn-keys.lua - custom functions for bound keys
     map-convoluted.lua - keymaps, hard to grok
     map-jolemak.lua    - keymaps, custom layout quirks
     map-lsp.lua        - keymaps, code-actions, diagnostics navigation
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

