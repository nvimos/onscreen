# Adding a language to genja

One checklist per new language (Flutter/Dart, Rust, ...).
Only step 1 is required; the rest is what makes a language feel like PHP or Go here.
Nothing ships for languages you don't use.

Before step 1, look at LazyVim's language extras and AstroCommunity's packs for that language.
Take their choices (server, tools, parsers, linters) as a starting point; don't copy their configs.
Details: `plug-wip/genja-completion011.nvim/CLAUDE.md`, "Look at LazyVim and AstroNvim first".

1. **Server and Mason tools**
   - File: `plug-wip/genja-completion011.nvim/lua/genja/lang/<name>.lua`
   - `servers`: lspconfig names, with overrides.
   - `tools`: Mason packages.
   - Steps and the headless check: that plugin's CLAUDE.md, "Adding a language".
   - Switch it on per machine in `lua/genja/lsp/local.lua`: `enabled = { <name> = true }`.
   - Or for the session: `:EnableLang <name>` (`-save` writes local.lua).
2. **Parser**
   - Add it to the list in `lua/lazyp/my/load-treesitter.lua`.
   - Building needs a C compiler: LLVM's clang-cl, `winget install LLVM.LLVM`.
3. **Filetype**, when Neovim doesn't know the extension
   - `vim.filetype.add()` in the plugin's `lua/genja/ft/<ft>.lua`.
   - Personal mappings go in the config's `lua/genja/ft/`.
4. **Linters** the server doesn't cover, all in `lua/genja/ext/lint.lua`
   - `M.by_ft`: linter per filetype.
   - `M.mason`: the Mason package.
   - `ROOT_MARKERS`: the project config files that switch it on.
   - No config in the project, no lint run.
5. **Tests**, one of:
   - A neotest adapter next to the PHP and Go ones, in `lua/lazyp/langs/php-neotest.lua`.
   - An overseer template in `lua/overseer/template/user/`.
6. **Debugger**, if needed
   - An nvim-dap adapter and configuration in `lua/lazyp/debug/`.
   - Or none, when the language plugin's own spec brings dap (Go: go.nvim in `lua/lazyp/langs/go.lua`).
7. **Keys**
   - Language keys go in `lua/genja/map-plugin/<spec>.lua`.
   - List them in `readme.cheatsheet.md`.
8. **Check**
   - `make status` in `tests/` lists the language, its servers and tools.
   - A `tests/comps011` case (`lsp <server>`) proves the server attaches.
