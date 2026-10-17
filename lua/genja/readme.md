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


## Oil: hiding entries with .oily

`<pwd>/.oily` lists entries that oil hides, on top of dotfiles (oil's
default). `g.` in oil still toggles showing everything. Code:
`F.is_hidden_file` / `F.oily_hide` in `fn-oil.lua`, wired up as
`view_options.is_hidden_file` in `lua/lazyp/explorer/oil.lua`.

One rule per line; blank lines and `#` comments are ignored, a trailing `/`
is dropped:

     node_modules         bare name: hidden in every directory
     lua/lazyp/unused     path, relative to the .oily dir: hides that entry
     C:/tmp/scratch       absolute path: hides that entry
     *.log                bare glob: matched against names in every directory
     lua/**/zold*         glob with '/': matched against the path relative to the .oily dir
     C:/tmp/*.bak         absolute glob: matched against the absolute path

- Globs use `vim.glob` syntax (`*`, `?`, `**`, `[abc]`, `{a,b}`) and must
  match the whole name or path.
- Matching ignores case on Windows.
- `.oily` is re-read when its mtime changes; a broken glob warns once with
  its line number and is skipped.
- `.oily` is looked up in `:pwd` only, not in oil's directory or its parents.

Key, in oil buffers:

     <LocalLeader>M   append the entry under the cursor (or the V-selected lines)
                      to .oily as a path, create the file if needed, re-render oil
