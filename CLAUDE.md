# Neovim config (genja)

Neovim 0.11+ config on Windows, at `%LOCALAPPDATA%\nvim`; plugin data in
`%LOCALAPPDATA%\nvim-data`. Plugin manager: lazy.nvim.

How this file is kept: one `##` heading per feature, one bullet per decision.
Unmarked bullets were stated by jaro. `(inferred)` marks Claude's reading of the
code or history: confirm or delete. `Hint:` is a working note for Claude.

## Plugins in this repo

Each has its own CLAUDE.md; read it before changing that plugin.

- @plug-wip/genja-completion011.nvim/CLAUDE.md: LSP servers, completion, ft/lang modules, dictionary words.
- @plug-wip/genja-finder.nvim/CLAUDE.md: live grep and live find pickers.
- @plug-wip/genja-oily.nvim/CLAUDE.md: hide oil entries listed in the nearest `.oily` up the tree.
- @plug-wip/genja-statusline.nvim/CLAUDE.md: statusline, tabline, winbar.

## Working style

- Terse replies. No anthropomorphising.
- Follow-up questions stay on point; no offers to explore unrelated topics.

- When asked for a plan, analysis or "don't change anything yet", edit no files.
- Do only what was asked; list further fixes as suggestions. (inferred)
- Before patching around a tool's bugs, check upstream issues, and check platform/os support before recommending a tool.
- Prefer built-in vim/nvim functions over new dependencies.

### No testing nvim

- Don't run, test, compile or start sandbox runs unless asked; suggest the command instead. jaro tests on this machine.
- Hint: say plainly when something was not run or tested. just "not tested" is enough.

### Git workflow

- Don't commit unless asked. Group commits by feature; no Claude/Co-Authored-By attribution.
- Exception: a background job (sub-session) commits its work in its worktree without asking.
- The tree often has unrelated uncommitted changes; leave them alone.


## Files and formatting

- Unix newlines (LF) everywhere; only `desktop.ini` is CRLF (`.gitattributes`, `.editorconfig`). Don't mention line endings in replies.
- Tabs, single quotes. (inferred)
- Readable Lua over clever Lua: plain assignments and `if` blocks, not `x and y or z` to build values.
- Comments: short, explain why. For tricky code, at most one line per callback or function.
- Annotate with LuaLS types: `---@type LazySpec` on specs, typed `opts`. `.luarc.json` disables `missing-fields`.
- Notifications name their source: script path relative to the config's parent, e.g. `nvim/after/ftplugin/make.lua: ...`.

## Layout and loading

- `init.vim` loads `lazy-boot`, then `Safeload('genja')`; if that fails it loads a small fallback subset.
- `lua/genja/`: the main profile. `lua/genja/readme.md` describes each file; keep it current when adding files.
- `lua/lazyp/<topic>/`: lazy specs, imported from `lua/genja/lazy-plug-spec.lua`. New plugins and the plug-wip loaders go in `lua/lazyp/new/`.
- Folder names are hyphenated (`util-qol`, `langs-comps`).
- Plugins load lazily through `cmd`, `keys` or a late event (`VeryLazy`); a spec without a trigger never loads.
- Unused specs carry `-- not used: 2026-10`; archived upstreams carry `-- archived: YYYY-MM`. Keep both comments.
- When an upstream repo is renamed, use the new name and keep the old one in a comment.
- In-repo plugins live in `plug-wip/` and load with `dir = vim.fn.stdpath('config') .. '/plug-wip/<name>'`.
- Hint: `undodir/`, `state/`, `.claude/` are runtime state; don't edit.

## Options (opt.lua)

- `vim.opt` values are strings, not tables; use several `:append()` / `+` lines when needed.
- `timeoutlen` is 300, from `opt.lua`; which-key's override is commented out with an explanation.
- Hint: when translating Vimscript, spaces before a `"` comment are not part of the value, and `\ ` is one space. Each `fillchars` item is one character.
- Hint: `vim.fn.has()` returns 0/1 and 0 is truthy in Lua; compare `== 1`. `has('Windows')` is not a feature name (`opt.lua` netrw, `genja/init.lua` START_DIRS). (inferred: left as is, fix only when asked)
- `opt.lua` sets `fillchars` `fold:` twice and the last (`·`) wins. (inferred: deliberate, ask before changing)

## Alma vimrc split

- `lua/genja/vimrc.almalinux.vim` is a one-file config for legacy vim 9+, to use in a pinch.
- Portable core on top, then `if has('nvim') | finish | endif`, then vim-only parts: vim-plug, curl downloads, fzf, plugin config, statusline, colors, options that conflict with genja, clashing keymaps.
- Plugins installed via vim-plug are never installed when the file is sourced from nvim.
- Don't duplicate alma settings into Lua.
- Goal: source the file after the Lua profile. Today `init.vim` sources it only in the fallback branch. (inferred: current state)
- A later accidental alma import into `opt.lua`/`auto.lua` was reverted (9555e32); the fold block in `opt.lua` was added back on request.

## Finder and live grep

- Live grep and live find live in `plug-wip/genja-finder.nvim`; see its CLAUDE.md.
- Their mappings stay in `lua/genja/map-telescope.lua` (`<F1>`, `<S-F1>`, `<leader>jj`).
- Telescope extensions (`lua/telescope/_extensions/`: finn, mycolors, mydirs, mylunsj, undersort) and `lua/genja/fn/telemap.lua` stay in the config.
- `START_DIRS` in `lua/genja/init.lua` feeds the mydirs picker; plug-wip dirs are listed there.
- Telescope `file_ignore_patterns` (in `after/plugin/telescope-after.lua`) are anchored, e.g. `"%.a$"`.

## LSP and completion

- Everything lives in `plug-wip/genja-completion011.nvim`, loaded by `lua/lazyp/new/genja-comp011.lua`; see its CLAUDE.md.
- Per-machine language switches go in `lua/genja/lsp/local.lua` (gitignored), not in the spec's `enabled` table.
- Filetype specs live in the plugin's `lua/genja/ft/`; personal ones stay in the config's `lua/genja/ft/` (`yaml.lua`: `yml` -> `yaml.ansible`).
- On this slow PC, lua_ls reports `undefined-global` for `vim`, `require` and other well-known Lua globals until it has loaded the workspace. It is startup lag, not a config bug, and does not reproduce on demand.
- Hint: ignore `undefined-global` / `undefined-doc-name` bursts in new-diagnostics reminders for Lua files; don't blame the cwd or `.luarc.json`.
- Treesitter parsers are listed in `lua/lazyp/my/load-treesitter.lua`; `Makefile.lazy.mk` `update`/`sync` also update parsers headless.

## Keymaps

- Leader is space, localleader `,`.
- `map-zero.lua`: essential maps that must not fail. `map-lsp.lua`, `map-telescope.lua`, `map-convoluted.lua`, `map-jolemak.lua` hold the rest by topic.
- `<leader>?` belongs to keymaps.nvim; cheatsheet.nvim's mapping is commented out.
- Floaterm commands end in `Fterm` (`:LazygitFterm`, `:BashFterm`, `:PythonFterm`, `:RangerFterm`, `:ClaudeFterm`, in `auto-alias.vim`).
- `<leader>cAp` runs `:PhpDocParams` (`map-lsp.lua`, PHP buffers).
- Keys and text objects worth remembering go in `readme.cheatsheet.md`.

## Windows environment

- Git for Windows plus Windows OpenSSH; `lua/genja/env.lua` sets `GIT_SSH_COMMAND` so lazy clones over ssh work (gitconfig rewrites https to ssh).
- PHP lives at `C:\tools\php83`; phpactor runs in the WSL distro set in `lsp/local.lua`.
- undotree uses Git's `diff.exe` through an 8.3 short path; an upstream quoting fix is drafted in `lua/lazyp/util-qol/undotree.diff`.
- Hint: write Windows paths with forward slashes in Lua.

## Small features

- Perplexity search: `plugin/perplexity-search.lua`, query encoded with `vim.uri_encode(q, 'rfc2396')`.
- Cheatsheet generation: `plugin/cheatsheet-generate.lua`.
- Ideas and backlog: `todo-ideas.md` (add new ideas here), `todo-2026-neovim011.txt`, `todo-2027.txt`.
