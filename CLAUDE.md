# Neovim config (genja)

Neovim 0.11+ config on Windows, at `%LOCALAPPDATA%\nvim`.
Plugin data in `%LOCALAPPDATA%\nvim-data`.
Plugin manager: lazy.nvim.

How this file is kept:

One `##` heading per feature, one bullet per decision.
Unmarked bullets were stated by user.
`Hint:` is a working note for Claude.
`(inferred)` marks Claude's reading of the code or history: confirm or delete.

## Ideas and backlog: 

- todo-ideas.md (add new ideas here),
- todo-2026-neovim011.md
- todo-2027.md
- todo-issue/: issues solved in a session, one checklist file each (`solved-<yy.mm.dd>-<HH.MM>-<topic>.md`), written and committed by `/commit-close-issues` (`.claude/skills/nvim-commit-close-issues/`).
- todo-done/: finished top-level items from the files above, one item per file, named `ideas-<nn>-<topic>.md` or `<year>-<topic>.txt`.

## Plugins in this repo

Each has its own CLAUDE.md; read it before changing that plugin.

- @plug-wip/genja-ask.nvim/CLAUDE.md: ask popup (`<M-?>`, `<leader>pc`), backends claude -p, claudefterm, gemini, copilot, aichat.
- @plug-wip/genja-claudefterm.nvim/CLAUDE.md: claude in a floaterm, one per project: `:ClaudeFterm`, session markers, paste context, `send()`.
- @plug-wip/genja-commit.nvim/CLAUDE.md: commit popup (oil), gitcommit lint, message generation.
- @plug-wip/genja-completion011.nvim/CLAUDE.md: LSP servers, completion, ft/lang modules, dictionary words.
- @plug-wip/genja-finder.nvim/CLAUDE.md: live grep and live find pickers.
- @plug-wip/genja-paste-ai.nvim/CLAUDE.md: paste search in the browser, one current provider: `:PasteSearch` (`:Wot`; fixed `:Google`, `:Perplexity`, `:Xty`), `<leader>pl/pw/py/ps`, `<F2>` lookup.
- @plug-wip/genja-oily.nvim/CLAUDE.md: hide oil entries listed in the nearest `.oily` up the tree.
- @plug-wip/genja-startdirs.nvim/CLAUDE.md: start dirs list (text file + spec), oil add/remove, jumps, ranking.
- @plug-wip/genja-recent.nvim/CLAUDE.md: recent files with own rules, frecency ranking; picker on `<C-F1>`.
- @plug-wip/genja-splitpad.nvim/CLAUDE.md: padding column next to the split separator in unfocused windows.
- @plug-wip/genja-statusline.nvim/CLAUDE.md: statusline, tabline, winbar.
- @plug-wip/genja-util.nvim/CLAUDE.md: helpers shared by the plug-wip plugins (centred float, uuid, code fence).

## Working style

- Terse replies. No anthropomorphising.
- Don't run, test, compile or start sandbox runs unless asked; suggest the command instead. Testing is done manually to also learn the new features 
  from the user's perspective.
- Follow-up questions stay on point; no offers to explore unrelated topics.
- When asked for a plan, analysis or "don't change anything yet", edit no files.
- Do only what was asked; list further fixes as suggestions. (inferred)
- In the main checkout, don't commit unless asked.
- In a Claude worktree (`.claude/worktrees/<name>`) or a background session, commit finished work without asking; don't merge or push to master.
- Group commits by feature; no Claude/Co-Authored-By attribution.
- The tree often has unrelated uncommitted changes; leave them alone.
- Before patching around a tool's bugs, check upstream issues and check platform support before recommending a tool.
- Prefer built-in vim/nvim functions over new dependencies.
- Hint: say plainly when something was not run or tested that you wanted to run or test.
- Prompts are often dictated by voice; some words arrive misheard ("deer" = dir, "OAuth" = "followed by", "whip doc"/"VIP doc" = doc-wip). When a phrase makes no sense, read it as speech-to-text and pick the likely word; ask only if still unclear.

## Files and formatting

- Unix newlines (LF) everywhere; only `desktop.ini` is CRLF (`.gitattributes`, `.editorconfig`). Don't mention line endings in replies.
- Spaces (4), single quotes (`.editorconfig` `indent_style = space`, since 39fd23c); older files still have tabs, converted as they are reformatted.
- Readable Lua over clever Lua: plain assignments and `if` blocks.
    - A short, non-nested two-way `(x and y or z)` is fine, wrapped in parentheses; anything longer or nested is an `if` block.
- Shared helpers between plug-wip plugins live in `plug-wip/genja-util.nvim`.
- Comments: short, explain why. For tricky code, at most one line per callback or function.
- Annotate with LuaLS types: `---@type LazySpec` on specs, typed `opts`. `.luarc.json` disables `missing-fields`.

## Logging and reporting logical or runtime issues to user

- Notifications name their source: script path relative to the nvim stdpath config folder.
    - e.g. after/ftplugin/make.lua: ...
    - e.g. lua/genja/map-plugin/init.lua: ...
- Each file declares the prefix once, near the top: `local SRC = 'lua/genja/auto.lua: '` (path, colon, space), and calls `vim.notify(SRC .. 'message')`. Always `SRC`, never `src` or an inline path.
    - plug-wip files only use the dirname/basename.ext like: SRC = 'genja-commit/popup.lua: '

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
    - Hint: when translating Vimscript, spaces before a `"` comment are not part of the value, and `\ ` is one space.
    - Each `fillchars` item is one character.
- `opt.lua` sets `fillchars` `fold:` twice and the last (`·`) wins. (deliberate, ask before changing)

## Alma vimrc split

- `lua/genja/vimrc.almalinux.vim` is a one-file config for legacy vim 9+, to use in a pinch.
- Portable core on top, then `if has('nvim') | finish | endif`, then vim-only parts: vim-plug, curl downloads, fzf, plugin config, statusline, colors, options that conflict with genja, clashing keymaps.
- Plugins installed via vim-plug are never installed when the file is sourced from nvim.
- Don't duplicate alma settings into Lua.
- Today `init.vim` sources it only in the fallback branch.
- A later accidental alma import into `opt.lua`/`auto.lua` was reverted (9555e32); the fold block in `opt.lua` was added back on request.

## Plugins, extensions

- Live grep and live find live in `plug-wip/genja-finder.nvim`; see its CLAUDE.md.
- Telescope extensions (`lua/telescope/_extensions/`: finn, mycolors, mydirs, mylunsj, undersort) stay in the config,
  unless otherwise instructed.
- `Telemap` and the refine decorator live in genja-finder: `require('genja-finder.telemap').Telemap(map)`,
  `require('genja-finder').attach_shared_keys(map)` / `.enhance(picker)`; see its CLAUDE.md.
- Start dirs come from `plug-wip/genja-startdirs.nvim` (`require('genja-startdirs').dirs()` / `.ranked()`); the list is `lua/genja/local/startdirs.txt` (gitignored). The `START_DIRS` global is gone.
- Telescope `file_ignore_patterns` (in `after/plugin/telescope-after.lua`) are anchored, e.g. `"%.a$"`.

## LSP and completion

- Everything lives in `plug-wip/genja-completion011.nvim`, loaded by `lua/lazyp/new/genja-comp011.lua`; see its CLAUDE.md.
- Per-machine language switches go in `lua/genja/lsp/local.lua` (gitignored), not in the spec's `enabled` table.
- Filetype specs live in the plugin's `lua/genja/ft/`; personal ones stay in the config's `lua/genja/ft/` (`yaml.lua`: `yml` -> `yaml.ansible`).
- Treesitter parsers are listed in `lua/lazyp/my/load-treesitter.lua`;

## Keymaps

- `map-zero.lua`: essential maps that must not fail. `map-lsp.lua`, `map-telescope.lua`, `map-convoluted.lua`, `map-jolemak.lua` hold the rest by topic.
- Plugin keys and config keymaps go in `lua/genja/map-plugin/<spec file name>.lua`; specs use `keys = Maps:keys()` and call `Maps:mappings(opts)` in `config`.
- `<leader>?` belongs to keymaps.nvim; cheatsheet.nvim's mapping is commented out.
- Floaterm commands end in `Fterm` (`:LazygitFterm`, `:BashFterm`, `:PythonFterm`, `:RangerFterm`, `:ClaudeFterm`, in `auto-alias.vim`; `:ClaudeFterm` comes from `plug-wip/genja-claudefterm.nvim`).
- `:ClaudeFterm [flags]` passes flags (e.g. `--chrome`) to claude at start; completion list `FLAGS` / `FLAG_VALUES` in `plug-wip/genja-claudefterm.nvim`.
- `<leader>pc` opens the ask popup, `<leader>pC` pastes context into claude, `<leader>mC` lists running claude terminals (`plugin/claude-fterm.lua`); `<F2>` lists them too (`lua/genja/f2/collect/claude.lua`).
- `<leader>cAp` runs `:PhpDocParams` (`map-lsp.lua`, PHP buffers).
- When adding keys:
    - add them to `readme.cheatsheet.md`, one section per plugin or topic, naming the file that sets them.
    - don't list a file's keymaps again in its comments; the code (`desc`) is the list.
    - main config: keys go only in `readme.cheatsheet.md`, not in `lua/genja/readme.md` or other readmes.
    - plug-wip plugin or module with its own README: keys go there only if it already has a keymaps section.
    - write `desc` so it sorts well: which-key sorts by `desc` (`lua/lazyp/my/which-key.lua`), so start with the area and then the object, e.g. `Git: hunk stage`, `Git: hunk reset`, `UI: git status (Neogit)`.
    - add a which-key group (`{ '<leader>x', group = 'Area: topics' }`) in `lua/lazyp/my/which-key.lua` for each new prefix, and widen an existing group's label when new keys land under it.

## Git

- Neogit (UI), gitsigns (hunks), diffview (diffs, history), mini.git (`:Git`); specs in `lua/lazyp/git/`, keys in `lua/genja/map-plugin/<spec>.lua`.
- Fugitive is disabled.
- diffview comes from the maintained fork `dlyongemallo/diffview.nvim`; sindrets/diffview.nvim had no updates since 2024-06. (inferred)
- Keys: `<leader>mg` Neogit, `<leader>mGl` Neogit log, `<leader>mGc` commit popup, `<leader>md`/`mh`/`mH` diffview, `<leader>h…` gitsigns hunks, `<leader>hc` mini.git commit at cursor, `]c` `[c` hunks outside diff mode; gitsigns keys are buffer-local (on_attach).

## Windows environment

- Git for Windows plus Windows OpenSSH; `lua/genja/env.lua` sets `GIT_SSH_COMMAND` so lazy clones over ssh work (gitconfig rewrites https to ssh).
- PHP lives at `C:\tools\php83`; phpactor runs in the WSL distro set in `lsp/local.lua`.
- undotree uses Git's `diff.exe` through an 8.3 short path; an upstream quoting fix is drafted in `lua/lazyp/util-qol/undotree.diff`.
- Hint: write Windows paths with forward slashes in Lua.

## Small features

- Paste search (perplexity and other providers): `plug-wip/genja-paste-ai.nvim`, query encoded with `vim.uri_encode(q, 'rfc2396')`.

## Tests

- `tests/Makefile` runs mini.test through pwsh; `make help` lists targets and variables.
- Timings: every case is timed, its weighted average (newest run 30%) kept in `stdpath('state')/genja-tests/timings.json` (throw-away; `make timings` shows it). Code and details: header of `tests/helpers/timing.lua`.
    - comps011 cases use `S:case()`: groups, a timeout, a slow cutoff, `requires` (what it skips without). Other dirs' cases are timed by `adopt()` with the default timeout (12 s) and cutoff (3 s), no groups.
    - A case is slow when its average is above its cutoff. The default run (`G=` unset) leaves slow cases out and says so after the summary, with the days since the last full `make gather`; `make gather` runs everything; `G=slow` only the slow ones; `make slow` lists them. A skip is not timed; a timeout counts as its timeout.
    - `make plan` estimates from the averages: the selected run, the slow ones left out, and every test of any group (average capped at today's timeout; never timed: the timeout, or "not timed yet" for plain cases).
    - Failures: after each run, `genja-tests/failed.json` (next to the timings) gets the cases that failed and loses the ones that passed or skipped; cases that didn't run keep their last result. `make failed` reruns those, whatever their group, verbose by default.
    - Timeouts are for a working machine, not padded for worst cases: lua_ls `ready`/`cmp` 10 s, slow at 8 s. The tests run with `GENJA_LUA_NO_LIB=1` (lua_ls without libraries); they check that servers work, not the libraries.
- Output of `make status` (and other table output from `tests/helpers/`) is a neat table:
    - The name column (language, tool, linter) comes first.
    - Then the short, fixed-width columns (on/off, ok/MISSING); long or variable ones (commands, paths, notes) go to the right.
    - Each table has a header row with column names at the same widths as its rows; a one-line legend above it when values aren't obvious from the names (`-`, `*`, `enabled`).
    - Row order: on and ok, then on but missing, then off. Within that, the languages table sorts by the server column; rows without a server come last.
    - Notes are terse, no parentheses: `parse errors: ftplugin/gitconfig.lua`.
- `make help` text: lowercase, terse; target descriptions don't mention the variables (D=, G=, V=); no parenthesised asides; don't explain what an unset variable does.

## Quirks

- vim-floaterm `--autoclose` (and `g:floaterm_autoclose`) takes only `always`, `never`, `smart`; numbers like `0` give an argument error.
- `genja-claudefterm` starts claude with `--autoclose=never` and closes the window itself on exit (`on_exit`): floaterm's own close hits E444 when the claude split is the last window. floaterm's `BufHidden,BufWipeout` autocmd (group `floaterm_enter_insertmode`) also closes the window, so `on_exit` clears it before `nvim_win_set_buf`.
