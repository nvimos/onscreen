# Adding a language to genja

One checklist per new language (Flutter/Dart, Rust, ...). Only the first step is
required; the rest is what makes a language feel like PHP or Go here. Nothing
ships for languages you don't use.

1. **Server and Mason tools**: `plug-wip/genja-completion011.nvim/lua/genja/lang/<name>.lua`
   (`servers` = lspconfig names with overrides, `tools` = Mason packages). Steps and the
   headless check: that plugin's CLAUDE.md, "Adding a language".
   - Switch it on per machine in `lua/genja/lsp/local.lua` (`enabled = { <name> = true }`),
     or for the session with `:EnableLang <name>` (`-save` writes local.lua).
2. **Parser**: add it to the list in `lua/lazyp/my/load-treesitter.lua`. Building needs a C
   compiler (LLVM's clang-cl: `winget install LLVM.LLVM`).
3. **Filetype**, when Neovim doesn't know the extension: `vim.filetype.add()` in the plugin's
   `lua/genja/ft/<ft>.lua`; personal mappings in the config's `lua/genja/ft/`.
4. **Linters** the server doesn't cover: `M.by_ft` in `lua/genja/ext/lint.lua`, the Mason
   package in `M.mason`, and the project config files that switch it on in `ROOT_MARKERS`
   (no config in the project, no lint run).
5. **Tests**: a neotest adapter next to the PHP and Go ones (`lua/lazyp/langs/`), or an overseer
   template in `lua/overseer/template/user/`.
6. **Debugger**, if needed: an nvim-dap adapter and configuration (`lua/lazyp/debug/`).
7. **Keys**: language keys in `lua/genja/map-plugin/<spec>.lua`, listed in `readme.cheatsheet.md`.
8. **Check**: `make status` in `tests/` lists the language, its servers and tools; a
   `tests/comps011` case (`lsp <server>`) proves the server attaches.
