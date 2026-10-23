# Squash ideas, 2026-10-17: details, done

Sections moved out of `squash-ideas-oct-17.details.md` once done and tried
(Done = yes), on 2026-10-23. Same numbering.

## 1. genja-finder.nvim move

- Current state: `plug-wip/genja-finder.nvim/` has `init.lua`, `grep.lua`,
  `find.lua`, `scope.lua`; loader `lua/lazyp/new/genja-finder.lua`;
  `<F1>`, `<S-F1>`, `<leader>jj` in `lua/genja/map-telescope.lua:27,28,63`.
- `move-plan.md` mentioned in the todo is no longer in the tree (not in
  `git ls-files`), so the plan is done.
- Remaining: delete the todo line. Optionally grep for leftover old live grep
  code in `lua/genja/` and `lua/telescope/_extensions/`.
- Outcome: done before this round (fc271a7, 0f08579). Follow-ups made under #8.

## 2. quickfix: close with `x`

```lua
-- after/ftplugin/qf.lua
local function close_list()
	local info = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1]
	if info.loclist == 1 then
		vim.cmd.lclose()
	else
		vim.cmd.cclose()
	end
end
vim.keymap.set('n', 'x', close_list, { buffer = true, desc = 'Quickfix: close' })
```

- `x` in a qf buffer is useless anyway (buffer is not modifiable).
- Optional: `q` too.
- Outcome (b7b2f74): as planned, `after/ftplugin/qf.lua`.

## 3. Charity nag

- `opt.lua:52-53`: `shortmess = 'flmnxS'` then `remove('I')`. The intro
  screen (with the ICCF/Uganda text) is built into Neovim and can't be
  partly edited; the only switch is `I`.
- Plan: `shortmess:append('I')`, then in `auto.lua`:
  `VimEnter`, if `vim.fn.argc() == 0` and the buffer is empty, `echo`
  `'NVIM v' .. tostring(vim.version())` plus whatever line is wanted.
- A plugin isn't needed; dashboard specs exist but are marked unused.
- Outcome (2282254 by jaro, 7a0df0a): no echo line. `lua/genja/intro.lua`
  redraws Nvim 0.13's own intro (logo, colors, separators) without the
  charity lines, as virtual lines on the empty start buffer; `opt.lua` adds
  `I` to `shortmess`, `auto.lua` shows it on `VimEnter`.

## 4–5. LSP hover: `<Esc>` close, scroll

- Hover is `vim.lsp.buf.hover` (`map-lsp.lua:65-68`). In 0.11 the float is
  created by `vim.lsp.util.open_floating_preview`, which stores the float's
  window id in the source buffer var `lsp_floating_preview`. Verify the name
  in `runtime/lua/vim/lsp/util.lua` of the installed version before relying
  on it.
- Helper:
  ```lua
  local function hover_win()
  	local win = vim.b.lsp_floating_preview
  	if win and vim.api.nvim_win_is_valid(win) then
  		return win
  	end
  	return nil
  end
  ```
- `<Esc>`: `expr` map or function that closes `hover_win()` and otherwise
  runs the existing `<Esc>` behaviour (check `map-zero.lua` for a current
  `<Esc>` mapping such as `:nohlsearch`, and keep it).
- Scroll: `vim.api.nvim_win_call(win, function() vim.cmd('normal! ' .. keys) end)`
  with `<C-e>`/`<C-y>` repeated or `<C-d>`/`<C-u>`. Fall back to the normal
  key when there is no float.
- Inside the float (entered with `K` twice) `q` already closes it in 0.11.
- Alternative: noice.nvim has `lsp.hover` scrolling, but it's under
  `others-vermaden` and not the main profile. Built-in is enough.
- Outcome (d60c2f8): `map-lsp.lua`. `<Esc>` closes the hover float, else
  runs `nohlsearch` + `<Esc>`; `<C-f>`/`<C-b>` scroll the float, else page.
  First try hung: a `remap = true` `<Esc>` re-entered itself; now a noremap
  Lua map that feeds the keys noremap.

## 6. oil: auto confirm single create

- `skip_confirm_for_simple_edits = true` is already in
  `lua/lazyp/explorer/oil.lua`. Oil's rule for "simple" lives in
  `lua/oil/mutator/preview.lua` (check `is_simple_actions` or similar in
  `nvim-data/lazy/oil.nvim`): creates and renames are simple, deletes, moves
  across adapters and copies may not be.
- Steps: reproduce (create one file `foo.txt`, `:w`). If it prompts, read the
  rule and see what action oil generated (sometimes a trailing-slash dir
  create plus a file counts as two). Only if needed, wrap `:w` in oil buffers.
- Possibly zero code: answer may be "already works", delete the todo.
- Outcome (05f40bd): the prompt was oil's "Save changes?" on `<CR>`, not the
  confirm dialog. `<CR>` on a new entry saves, then finds the entry by name
  (oil re-sorts, so the cursor line is wrong) and opens it by path; files
  open with `:edit`. In `fn-oil.lua`.

## 7. oil: `gga` -> git add

- `fn-oil.lua`:
  ```lua
  F.git_add = function()
  	local entries = F.get_oil_entries()
  	local paths = {}
  	for _, e in ipairs(entries) do
  		table.insert(paths, e.path)
  	end
  	local dir = require('oil').get_current_dir()
  	local cmd = { 'git', 'add', '--' }
  	vim.list_extend(cmd, paths)
  	vim.system(cmd, { cwd = dir }, function(res) ... vim.notify ... end)
  end
  ```
- `get_oil_entries()` also appends `*.finished`/`*.torrent` sidecar files
  (undersort feature); for git add use a plain variant without that.
- `gga` vs oil's `g` maps: oil uses `g?`, `g.`, `gs`, `gx`, `g\`; `gga` has a
  timeout overlap with `gg` (top of file). With `timeoutlen` 300, `gg` waits
  300 ms in oil buffers. Consider `<localleader>a` instead or accept it.
- Refresh after: oil's `git` integration only shows status if configured;
  not currently configured.
- Outcome (94857d4): `gga` and `<LocalLeader>a` add, `ggr` and
  `<LocalLeader>r` unstage (first written as `,,r`, fixed); both work on a
  visual range and jump to the next unstaged entry. Untracked files are
  filtered with `git ls-files` before unstaging and get a notice. Status shown
  by oil-git.nvim (see extras).

## 8. `<S-F1>` from oil dir

- `map-telescope.lua:28` calls `genja_finder_find`. In an oil buffer, the
  buffer name is `oil:///C/...`, so the `bufdir` root in `scope.lua` likely
  resolves to nothing useful.
- Plan: in the config (not the plugin), when `vim.bo.filetype == 'oil'`, call
  `live_find({ root = require('oil').get_current_dir() })`. Check what
  `live_find(opts)` accepts (`find.lua`, `scope.lua`); if there's no explicit
  root/cwd option, add one there and document it in README.md and
  `doc/genja-finder.txt` (per the plugin's CLAUDE.md).
- Same for `<F1>` grep for symmetry.
- Outcome (11b270b): genja-finder already had a `cwd` option; passed for
  `<S-F1>` and `<F1>` in oil. Plugin follow-ups in `scope.lua`: a passed `cwd`
  is root `arg` (first in the `<M-r>` cycle, kept on reopen and on the `<F1>`
  switch), the prompt title shows the last three parts of the scanned dir,
  path labels are unix style. The last of these are untested.

## 9. gitsigns

- Not installed (not in `lazy-lock.json`). Works on Windows with Git for
  Windows.
- Spec `lua/lazyp/git/gitsigns.lua`, `event = 'VeryLazy'` (or
  `BufReadPost`), `---@type LazySpec`, typed `opts`.
- `on_attach(bufnr)` maps: `]h`/`[h` (`nav_hunk('next'|'prev')`),
  `<leader>hs` stage, `<leader>hr` reset, `<leader>hp` preview,
  `<leader>hu` undo stage, visual `hs`/`hr` with line range.
- Check `<leader>h*` is free (`map-*.lua`, which-key). Add to
  `readme.cheatsheet.md`.
- Outcome: done with #37 (9126c56): `lua/lazyp/git/gitsigns.lua`, keys in
  `lua/genja/map-plugin/gitsigns.lua` (`<leader>h…`, `]c` `[c`, `ih`), buffer-local via `on_attach`.

## 10. cmp: popup flash on `:w`

- Cmdline cmp config: `genja-completion011.nvim/lua/genja/completion/cmdline.lua:6-11`
  already has `ignore_cmds = { 'Man', '!', 'w' }`, which only stops
  argument completion; the menu for the command name `w` still opens.
- Autosave: `after/plugin/genja-autosave-go.lua` and others use
  `BufWritePost`; find what actually triggers the save (grep for
  `':w'`, `'<cmd>w'`, `feedkeys`, `InsertLeave`, `TextChanged`). If a mapping
  is `:w<CR>`, change to `<Cmd>write<CR>`: no cmdline, no popup. This is the
  real fix.
- Fallback per the todo: `cmp.setup.cmdline(':', { enabled = function() ... end })`
  returning false when `vim.fn.getcmdline():match('^w')`, or a 500 ms
  debounce via `performance.debounce` (global, affects all completion, so
  less good).
- Outcome (2b17baf by jaro): no delay. Normal-mode `:w<CR>` maps became
  `<Cmd>write<CR>` in `map-zero.lua`, so no cmdline and no popup; which-key's
  `filter` keeps `:` mappings out of its tree, so `:` still opens the
  cmdline. Nothing typed `:w` automatically. Also `<leader>zZ` -> `<cmd>x<cr>`.

## 11. Fold commands with descriptions

- Existing `Folds` block at `map-zero.lua:53`.
- which-key v3 ships `plugins.presets.z` with descriptions for `z` commands;
  check `lua/lazyp/my/which-key.lua` whether presets are on. If on, this is
  only about wording («Fold: …»), still worth doing for keymaps.nvim and
  `:map` listings.
- Table: `zo zO zc zC za zA zv zx zX zm zM zr zR zn zN zi zj zk [z ]z zf zF zd zD zE`.
  `vim.keymap.set({'n','x'}, lhs, lhs, { desc = 'Fold: open', noremap = true })`.
  A same-lhs noremap map is a no-op functionally.
- Don't override existing custom maps (`z<left>` etc.); and oil's `ze`, `za`,
  `zr`, `zj` are buffer-local and win in oil buffers, fine.
- Outcome: not started.
- Later (5155cca, bea7b97, 1d0d2db): first descriptions only in which-key,
  then `map-zero.lua` maps the built-in fold keys to themselves with
  «Fold: …» descriptions; `z<left>` follows the same naming.

## 12. Code actions in telescope

- `<space>ca` / `<space>!` call `vim.lsp.buf.code_action`, which uses
  `vim.ui.select`. dressing.nvim is in `unused-archived`.
- Option A (preferred, no dependency): `vim.ui.select = function(items, opts, on_choice)`
  in a small file, using `pickers.new(require('telescope.themes').get_cursor(), ...)`,
  `finders.new_table` with `opts.format_item`, `on_choice(item, idx)` on
  select and `on_choice(nil)` on close. Must lazy-require telescope.
- Option B: `nvim-telescope/telescope-ui-select.nvim`, ~10 lines of spec.
- Both also improve #17 and any other `vim.ui.select` caller.
- Outcome (d0881d0): option A. `lua/genja/ui-select.lua`, loaded with
  `Safeload` from `genja/init.lua`; telescope dropdown, telescope loads only
  when shown, `<Esc>` reports nil. Covers code actions, `:OverseerRun` and
  every other caller. Named local functions with LuaLS annotations.
  `.luarc.json` maps `Safeload` to `require` for LuaLS (e8b2f5d).
- Later (d8e497b, 573bba8): code actions by kind, `<leader>cq` quickfix,
  `ce` extract (visual), `cr` rewrite, `cs` source; in the cheatsheet.
  Search and replace moved to `<leader>cS` (9013eb0).

## 13. json/yaml key path in winbar

- `genja-statusline.nvim/lua/genja-statusline/winbar.lua` `M.render()`
  returns a string; add a component for json/jsonc/yaml/yaml.ansible.
- Path from treesitter:
  ```lua
  local node = vim.treesitter.get_node()
  while node do
  	if node:type() == 'pair' or node:type() == 'block_mapping_pair' or node:type() == 'flow_pair' then
  		local key = node:field('key')[1]
  		-- text via vim.treesitter.get_node_text(key, 0), strip quotes
  	end
  	-- arrays: index from position among named siblings -> '[3]'
  	node = node:parent()
  end
  ```
- Parsers: json and yaml must be in `load-treesitter.lua`.
- Cost: winbar renders often; cache by `(bufnr, changedtick, cursor row)`.
  Truncate long paths from the left.
- Per that plugin's CLAUDE.md, read it first and update its README/doc.
- Alternative: nvim-navic/dropbar with jsonls/yamlls symbols; adds a
  dependency, rejected per "prefer built-in".
- Outcome (789374c, ac28b09): `keypath.lua` in genja-statusline as `winbar_extra`, then dropbar crumbs
  embedded in genja's winbar (`lua/lazyp/new/genja-statusline.lua`, `lua/lazyp/ui/dropbar.lua`).
- Later (5bc3fb8): aerial's outline sidebar also toggles on `<C-s>`.

## 15. oil: `.oily` hidden set + hide key

- `view_options.is_hidden_file = function(name, bufnr) ... end` replaces oil's
  default dotfile rule, so keep the dotfile check inside it.
- Lookup: oil's current dir for `bufnr`
  (`require('oil').get_current_dir(bufnr)`), then parents up to
  `vim.fn.getcwd()`; todo says PWD, so decide: per-dir file vs one file at
  PWD with relative paths. One file at PWD with lines like `node_modules`
  or `sub/dir/build` is simpler.
- Cache parsed sets by path + `fs_stat().mtime`; `is_hidden_file` is called
  per entry.
- Hide-current-item key: append the entry (relative to the `.oily` dir) to the
  file, then `require('oil.actions').refresh.callback()`. Session-only
  variant: keep a Lua set instead of writing the file.
- `g.` (oil toggle hidden) shows everything again.
- No plugin needed; it's config.
- Outcome (a3f67a3): one `.oily` at `:pwd`. Bare names hide everywhere, paths
  hide one entry, globs via `vim.glob` (`*.log`, `lua/**/zold*`). `,M`
  appends the entry's path. Documented in `lua/genja/readme.md`.

## 17. `g.` catch-all action menu

- Build items at call time:
  - LSP: for each attached client, `client:supports_method(...)` for
    definition, declaration, implementation, type definition, references,
    rename, code action, hover, signature help, format.
  - Diagnostics: open float, to quickfix, if any on the line.
  - Treesitter: node under cursor type in the title; "select node" /
    incremental selection if configured.
  - Git: gitsigns hunk actions if #9 is done.
- Show via `vim.ui.select` (telescope dropdown after #12).
- Built-in alternative: Neovim's mouse `PopUp` menu. Add items with
  `vim.cmd.amenu('PopUp.Go\\ to\\ definition <Cmd>lua vim.lsp.buf.definition()<CR>')`
  and open from a key with `vim.cmd.popup('PopUp')`; real right-click gets
  the same menu. Neovim 0.11 already adds some LSP items to `PopUp`;
  check `:menu PopUp` first.
- `g.` is free in normal buffers; oil maps `g.` (toggle hidden) buffer-local,
  which wins there.
- Outcome (879f2a5): `lua/genja/actions.lua`, its own telescope picker on
  `g.` and `<LocalLeader>/` (in oil only `,/`). Built per call: `cur:` items
  for the cursor (supported LSP methods, line diagnostics, word, oil entry),
  unprefixed ones for buffer/editor (format, symbols, diagnostics, pickers,
  `<F2>`, overseer). No treesitter or gitsigns items (#9 not done). Notes in
  `doc-wip/idea-oct.catch-all.md`.

## Extras done along the way

- oil-git.nvim (f7d294a): git status symbols in oil
  (`lua/lazyp/explorer/oil-git.lua`); its cache is cleared after add,
  unstage and commit.
- oil `<C-S-p>` (5214207): diff preview when the entry has changes; `<CR>` in
  the diff opens the file at that line.
- oil commit popup `ggc`/`,c` (ba27d2c): `<C-CR>` inserts `updated <file>`,
  draft kept until a commit succeeds.
- oil E211 workaround (ac5b8cc, upstream oil #762): on `OilActionsPre`,
  unmodified buffers of deleted files are wiped, so no E211 and no hang.
- LuaLS: `Safeload` treated as `require` (e8b2f5d).
- focus.nvim (uncommitted, untested): `lua/lazyp/ui/focus.lua`, typed opts
  (`FocusOpts`, defined in the file; the plugin ships none). focus has no
  exclude option, so an autocmd sets `vim.b.focus_disable` for buftypes
  `terminal`, `nofile`, `prompt` and filetype `oil`.
- Go (5470ea8): organize imports, then format on save, with buffer and
  global opt-outs; a once-per-folder warning when gopls has no
  go.mod/go.work; settings trimmed to what differs from gopls v0.23.
- lua_ls (eecabb1): buffer diagnostics hidden until lua_ls has loaded the
  workspace (10 s at most), against startup `undefined-global` noise.
- Telescope pickers (0b48222): `<M-l>`/`<M-q>` send the marked entries to
  the location/quickfix list, `<M-L>`/`<M-Q>` append, `<C-l>`/`<C-q>` send
  all; `<C-/>` and `?` list the keys; a hint in the empty prompt.
- oil (0582cae, 8d3d47c): modules renamed by purpose, preview and
  undersort in `oil/plug/`; `<C-Right>` runs oil's `gx`.
- Dates (25e67ed, 16cf5ee, bb637bf): `<leader>id` appends the date;
  abbreviations moved to `abbreviations.vim`, `ymd!` and `ymdt!` insert
  the date and timestamp, `:g` is `:q`.
- `Makefile.runtimes.mk` (6a3cbef): `runs` and `mods` targets.
- copilot.vim (7d3d537, 53744b7, e02ab60): ghost text, keys in the
  cheatsheet; loads only for gitcommit, `<leader>at` toggles the other
  filetypes.
- urlview.nvim (a9ef21d, 4a3aed3, 082fd2d): visual `gx` and `<leader>gx`
  pick URLs in a telescope picker, `<Tab>` marks, `<CR>` opens all marked.
- genja-splitpad.nvim (4956074, 0bb1d95): padding column next to the
  separator in unfocused splits; spec moved to `lua/lazyp/no/`, disabled
  (6fdd7e3).
- Go (e3c61d5, 4a917a0): gopls `local` import groups from go.work/go.mod,
  code lenses (go.mod too), `<leader>cl` runs the lens on the line.
- `has()` fixes (a6abb33): `win32`/`unix`, compared with 1; a terminal now
  gets the non-GUI listchars.
- which-key (e6ffb52): `<F2>`/`<F3>` scroll the popup.
- focus.nvim (6fdd7e3): off by default.
- Small (4a917a0, 6fdd7e3): `~/.local/bin` on PATH, oil:// start dirs,
  `<S-Insert>` pastes the clipboard on the cmdline, `<leader>mxo` closes
  overseer.


# Closed in auto-todo-20261023-2048

## 18. `<F2>` context picker

- Dispatcher: `local handlers = { make = ..., oil = ... }`, pick by filetype
  or by `findfile('Makefile', '.;')`.
- make: parse targets from the Makefile and its includes
  (`Makefile.lazy.mk`, `Makefile.gitea.mk` exist here) with a regex like
  `^([%w_.%-/]+)%s*:[^=]` skipping `.PHONY` and pattern rules. `make -pRrq`
  is accurate but slow and noisy on Windows. Run the chosen target in
  floaterm (`:FloatermNew make <t>`) or `:terminal`. overseer exists under
  `lazyp/maybe/` — not in use.
- oil: `git status --porcelain=v1 -z` in oil's dir; telescope picker with
  previewer running `git diff -- <file>` (untracked: show file); multi-select
  `<Tab>`, `<CR>` runs `git add` on the selection (reuse #7).
- One module per context under `lua/genja/f2/` (update `lua/genja/readme.md`).
- Fallback: notify "F2: no context for <ft>".
- Outcome (6e169f6, partly): make context only, in one file
  `lua/genja/f2.lua`, not a `f2/` folder. Targets from `make -rRpq` after
  all (regex missed included files), telescope dropdown with the included
  file as prefix (`lazy: sync`), run as an overseer task (overseer is in use
  now). `<F2>` LSP rename commented out; rename lives in the #17 menu. The
  main `Makefile` includes the `.mk` files at the top, `.DEFAULT_GOAL :=
  refresh-spell`, `.PHONY`; cygwin `MAKE` in `Makefile.gitea.mk` commented
  out. Bug fixed: oil's dir had a trailing backslash, so no Makefile was
  found. Notes: `doc-wip/readme.overseer.md`.
- Oil context: partly covered by the extras `<C-S-p>` diff preview and the
  commit popup; the git status picker with multi-select add is still open.
- Sources (2026-10-19): `f2.lua` split into `lua/genja/f2/`. A source is
  `{ prefix, collect(ctx, done) }`; `done(items)` with `{ label, run }`, async
  for make (`make -rRpq`). `init.lua` lists sources explicitly, keeps their
  order, notifies only when all are empty. `adhoc.lua`: `go mod init
  <dirname>` when lang/go.lua's rootless check applies; on success the gopls
  clients for that dir stop and FileType re-fires (as in lang/Php.lua). The
  go.lua warning points to `<F2>`.
- Sources now return tasks (the add_tasks shape). `git.lua`, oil only: `git
  status --porcelain=v1 -z -uall` at the repo root; files with a worktree
  change or untracked; one `add (N files)` item opens a sub-picker (`XY path` coloured like git status,
  diff preview, untracked: file head; `<Tab>`
  marks, `<CR>` git add). Replaced a first try with a status picker plus
  per-file `add <path>` items (cap 20). Main picker: `<CR>` runs all marked
  items; `merge` joins same-key cmds.
- API: `f2.add_tasks(tasks, { buffer? })`: global or per buffer (dropped on
  BufWipeout); same group + label updates. `f2.remove_tasks({ group, label?,
  buffer? })`. `f2.group_order` sets group order, others after it A-Z;
  within a group `order`, then label. `cond(ctx)` errors are caught and hide
  the task. `autoremove`: function returned true / keys ran / cmd exit code
  (true = 0). Keys go through `nvim_feedkeys(..., 'm')`, i.e. with mappings.
  Floaterm exit codes come from TermClose.
- Tests (96c9375): mini.test unit tests in `tests/f2/` (registry, builder,
  run, sorting, make and git parsing, adhoc); `make test` in
  `lua/genja/f2/`. Manual checks in `lua/genja/f2/readme.testing-manual.md`.
  Not run yet. The gopls rootless warning points to `<F2>` (ae19812).
- Later (6fdd7e3): git add picker opens with the preview hidden, `<C-p>`
  toggles it, `<M-t>` opens the selection in tabs and keeps the picker,
  `<M-e>` edits; git add runs directly (no overseer task). `:F2Reload`
  unloads the f2 modules; overseer tasks can run quietly (notify only on
  failure).

## 20. Voice input

- Zero effort: Windows voice typing `Win+H` sends keystrokes to the focused
  terminal; in insert mode it types text. Test with Windows Terminal before
  building anything.
- Full build: record with `ffmpeg -f dshow -i audio="<mic>"` to a temp wav
  (start/stop via a toggle key using `vim.system` and kill), transcribe with
  whisper.cpp (`whisper-cli -m model.bin -f file.wav -otxt`) locally, insert
  the text at cursor. Needs ffmpeg, whisper.cpp binaries and a model
  download; device name discovery on Windows is fiddly.
- Plugins exist (whisper-based, some need OpenAI API or sox); check Windows
  support before choosing.
- Outcome: not started.

## 33. gitea to w11s-cut (XS, skipped 2026-10-23)

- Move `Makefile.gitea.mk` and its `include` to the w11s-cut project.

## 19a. codecompanion (S, spec open)

- Hourglass cursor while claude starts (4e79669): unconfirmed.
- Open questions: keep codecompanion next to the floaterm, or drop it?
  Does the ACP adapter work on Windows here (needs the npm adapter and a
  token)?


# Built in auto-todo-20261023-2048 (untested; guides doc-wip/readme.2026-10-23.*.md)

## 16. `<C-?>` AI popup

- Key: `<C-?>` is mapped to hover in insert mode (`map-lsp.lua:68`, marked
  "testing 2026-10"). In Windows Terminal and most terminals `<C-?>` sends
  DEL, so it may not be distinguishable; works in GUIs (Neovide, `ginit.vim`).
  Choose a different key or test first.
- Backend options:
  - `claude -p "<q>" --output-format text` if Claude Code CLI is on PATH: no
    key handling in config. Slower startup.
  - Direct API with `curl` via `vim.system`, `ANTHROPIC_API_KEY` from env,
    small fast model (Haiku), `max_tokens` ~200, system prompt: "Answer in at
    most 3 short sentences, plain text, no markdown." Use the claude-api
    reference when writing it.
- UI: `vim.ui.input` for the question; answer in a floating window
  (`nvim_open_win`, `wrap`, `q`/`<Esc>` close); spinner or "…" while waiting;
  strip any markdown that slips through.
- Place: `plugin/ai-ask.lua`, next to `plugin/perplexity-search.lua`.
- Outcome so far (wip, uncommitted, untested): no `<C-?>`, no answer float.
  The `<leader>pC` popup from #19 (`lua/genja/claude.lua`) sends into the
  running claude floaterm; `<C-b>` brief mode prepends the "at most 3
  sentences, plain text" line. The answer shows in the claude split.
- Direction (2026-10-18), spec still to write:
  - decouple the popup from the claude floaterm
  - multiple backends: a multi-agent simple prompt plugin
  - first backend: jaro's `claude -p` pwsh function, rewritten in Lua as
    the first cli backend
  - `<M-…>` keys in the popup for target, model and effort, each with a
    default
- Spec (2026-10-23, auto-todo):
  - Code: `lua/genja/ask.lua` (popup, session, log) and
    `lua/genja/ask/backends/<name>.lua`; no plug-wip plugin yet, may move
    later. genja-commit keeps its own CLI calls until then (a plug-wip
    plugin must not depend on the config).
  - Backend shape: `{ name, models?, efforts?, run(prompt, opts, on_done) }`,
    `opts = { model, effort, session_id?, cwd }`, `on_done(err, text,
    session_id)`. Backends: `claude_p` (claude -p, the pwsh claude-p
    rules: haiku/low default, terse plain-text system prompt,
    `--no-session-persistence` unless saved), `floaterm` (pastes into the
    claude floaterm, answer shows there), `gemini`, `copilot`, `aichat`.
  - Open: `<M-?>` in n/i/v (visual: the selection goes along),
    `<leader>pC` alias (replaces the claude.lua popup).
  - Popup keys: `<M-t>` target, `<M-m>` model, `<M-e>` effort (title shows
    `claude-p · haiku · low`), `<M-s>` save the session as
    `nvim yyyy.ww.d-ddd.hhmm`; the claude.lua popup keys stay (`<C-CR>`
    send, history, `<C-b>` brief).
  - Answer: the same float shows the answer under the prompt; `q`/`<Esc>`
    close, `y` yanks the answer, `<CR>` asks a follow-up in the same session.
  - Sessions: each popup opens a fresh one; follow-ups reuse it; saved ones
    resume from a picker.
  - Log: every Q&A appended to `~/.claude/p-logs/nvim.log`.

## 26. which-key / keymaps leftovers (S)

- Decided 2026-10-23: `<leader>jM` (telescope keymaps) gets the refine
  decorator plus `<M-r>` rotating the desc prefixes (`Area:`), then the
  item closes; custom picker stays in todo-2027.txt.
- Section order in abdul-keymaps stays by name (closed).

## 30/31. mouse in nvim and telescope (L)

- Spec (2026-10-23, auto-todo):
  - right-click PopUp entries per filetype: markdown (toggle checkbox,
    open link, F2 menu), oil (git add, open in tab), code (code action,
    rename, references); plus a `Morning` entry everywhere
  - clickable winbar/statusline: git branch -> Neogit, diagnostics count
    -> list, filename -> oil at its dir
  - `:Morning` buffer, command only (not on start): Start dirs, Recent,
    Todo, Untested; click or `<CR>` opens
  - mini.starter spec in `lua/lazyp/ui/`, same sections, `enabled = false`
  - scroll wheel in telescope: default; the selection doesn't move

- Survey first: telescope mouse mappings, `mousemodel=popup_setpos`,
  PopUp menu items per filetype, clickable statusline/winbar regions.
- Known (2026-10-23): telescope already clicks: `<LeftMouse>` selects,
  `<2-LeftMouse>` runs; the PopUp menu has `Actions (g.)` (17b).
- Open questions:
  - which pickers matter most with the mouse: code actions, F1/F2/F3 lists?
  - scroll wheel in pickers: move the selection, or scroll the list?
  - "lazy mornings": a clickable notes/todo dashboard, or PopUp entries
    per filetype (markdown: checklist toggle, open link)?
  - clickable winbar/statusline parts (git branch -> Neogit, diagnostics
    -> list)?

## 35. recent files plugin (L, spec open)

- Study telescope oldfiles and an MRU plugin; own rules for saving and
  ranking. Startdirs usage ranking (#36) can share the counter format.
- Open questions:
  - which rules: skip help/oil/temp/COMMIT_EDITMSG? per project (cwd/git
    root) or global?
  - ranking: recency, frequency, or frecency (both)?
  - storage: shada `v:oldfiles` plus own counts, or an own file only?
  - plug-wip plugin (like genja-startdirs), or part of genja-finder?
- Spec (2026-10-23, auto-todo): `plug-wip/genja-recent.nvim`, ranking
  shared with genja-startdirs. Record on `BufWinEnter` (view) and
  `BufWritePost` (edit), counted apart. Skip list option: non-file
  buftypes, `.git/`, `%TEMP%`, `nvim-data`. Frecency, edits ×2, decay ×4
  < 1 h, ×2 < 1 day, ×0.5 < 1 week, ×0.25 older. Picker on the current
  project (git root or cwd), `<M-a>` all. Data:
  `nvim-data/genja-recent.txt` (`path\tviews\tedits\tlast`), written on
  `VimLeavePre` and on a timer. `<C-F1>` opens it with the refine keys;
  oldfiles moves to a free `<leader>j…` key.

