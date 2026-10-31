# Squash ideas, 2026-10-17: details

Approach notes behind `squash-ideas-oct-17.md`. Nothing here was run or
tested; file paths and current state were read from the repo on 2026-10-17.
Each idea ends with an "Outcome" list (refreshed 2026-10-18): what was
actually done, where it differs from the plan, and the commit.
Done and tried items moved to `squash-ideas-oct-17.details.done.md`
(2026-10-23). Order: untested first, then open work.

## How the estimates were made

- Effort counts editing plus one round of jaro testing on Windows.
- Token cost assumes Claude reads the touched files, writes the change, and
  fixes one problem. Ideas that need upstream research (plugin choice,
  platform support) get extra for web reads.
- Ideas that only add a keymap or an option to an existing file are XS/S.
  New plugins and new UI are M. Anything with external processes (AI, audio)
  or several contexts is M/L.

# Untested

## 14. gitcommit lint

- Platform check needed: gitlint's docs have said Windows is not officially
  supported (it shells out via `sh`). Verify current state on its GitHub
  issues before installing. Python is also required.
- Alternatives: commitlint (Node, works on Windows, needs a config file), or
  a custom nvim-lint linter in Lua (subject length ≤ 50, blank line 2, body
  wrap 72) — no external tool, fits "prefer built-in". A pure-Lua
  `vim.diagnostic.set` check in `after/ftplugin/gitcommit.lua` needs no
  nvim-lint at all; cheapest option.
- If nvim-lint is still wanted (other non-LSP linters later): spec in
  `lua/lazyp/langs-comps/nvim-lint.lua`, `event = 'VeryLazy'`,
  `config` sets `linters_by_ft` and an autocmd calling `try_lint()`;
  install the tool via mason-tool-installer list.
- Outcome: not started.
- Later (64baa3b, 3d5dc8c, e02ab60, fdc634c): `plug-wip/genja-commit.nvim`.
  The oil commit popup moved there (`<C-CR>` commits, `:w` saves to
  COMMIT_EDITMSG, draft refilled). gitcommit buffers lint while typing
  (nvim-lint + gitlint, Lua rules without Python); `<M-g>` writes the
  message from the staged diff (claude, copilot, gemini, aichat); opt-in
  Conventional Commits mode from git config or commitlint/commitizen files;
  cmp source for types, scopes, footers. Copilot ghost text in commit
  buffers. nvim-lint has its own spec for later linters (14e). Untested.

## 25. telescope refine decorator: `<M-x>` exclude (S)

- `genja-finder` `refine.lua` has `<M-f>` filter, `<BS>` undo, `<M-n>` fuzzy/exact.
- `<M-x>`: same as `<M-f>`, but keeps the entries that don't match the prompt.
  Shares the undo stack with `<M-f>`.
- Earlier (2f56848, 65de557, fdc6e86, f8eacab, 88e7355, 9a92404): refine
  and Telemap live in genja-finder; `attach_shared_keys(map)` /
  `enhance(picker)` give `<M-f>` to the f2, ui-select, mylunsj, finn,
  mydirs, undersort and `<C-F1>` oldfiles pickers; `<BS>` undo, `<M-n>`
  fuzzy/exact.
- Outcome (1ff3ec3): `refine.lua` `M.exclude`, any word, smartcase, prefix `!word > `; static finders or after `<M-f>`. Headless-tested. Guide: `readme.2026-10-23.refine-exclude.md`.

## 17b. right-click entry for the `g.` menu (XS)

- `:amenu PopUp.Actions\ (g.) <Cmd>…<CR>` adds the menu to the mouse popup.
- Clicking items in telescope: `<LeftMouse>` selects, `<2-LeftMouse>` runs
  (telescope has mouse support through `mappings`; check before adding).
- Outcome (3b9b1ed): `Actions (g.)` in `lua/genja/fn.vim`; telescope already clicks. New actions: source this file, claude (floaterm). Guide: `readme.2026-10-23.popup-actions.md`.

## 28. window sizes (S)

- `lua/genja/ext/winsize.lua`: `<M-=>`/`<M-->` grow/shrink by percent or fixed
  steps, `<M-0>` cycles 50/50 → 30/70 → 70/30 → 60/40 in a vertical
  two-window split.
- `<leader>wr` resize mode as a which-key loop (`hydra`), `h/j/k/l`, `=`, `0`.
- smart-splits.nvim spec, disabled, typed opts.
- Outcome (6e9c477): as planned; `<leader>W…` keys behind the loop, `<leader>Ws` step toggle. Headless-tested share cycle. Guide: `readme.2026-10-23.winsize.md`.

## 29. alma behaviours in lua (XS–S)

- a. `~` toggles true/false, on/off, yes/no, `+`/`-`, `<`/`>`, else case.
  Module in `lua/genja/`. Plus dial.nvim on `<C-a>`/`<C-x>` with augends
  from LazyVim / AstroNvim.
- b. visual `zf` asks for a title and writes `{{{ title` / `}}}` markers
  with `commentstring`; `:WrapFold`, `<leader>wwf` paragraph (alma's
  `WrapFold`). Alma's copies get a "duplicated" comment.
- Outcome: 29b (9bae096) `lua/genja/ext/wrapfold.lua`; 29a (4f73a32) `lua/genja/ext/tilde.lua`, also left/right, up/down, min/max, first/last; dial (3b309f8). Alma copies marked "duplicated". Guides: `readme.2026-10-23.wrapfold.md`, `readme.2026-10-23.tilde-dial.md`.

## 32. tabline: resizing nvim-qt activates the right-most tab (M)

- `ginit.vim` sets `GuiWindowFrameless(1)`: dragging the top edge sends
  clicks into row 0, the tabline. The fill area right of the labels has no
  click region (`tabline.lua`); Vim treats a click outside labels as "next tab".
- Repro: `GuiWindowFrameless(0)`, resize again. Fix: a no-op `%@…@` click
  region over the fill area.
- Outcome (a4bca16): `autoload/genja_statusline.vim` noop handler on the left edge and fill. Click not tested. Guide: `readme.2026-10-23.tabline-click.md`.
- Later (8f2a667): VimResized's `tabdo wincmd =` returns to the current tab; augroup `_resize_equalize_tabs`.

## 34. F2 context: markdown selection to checklist (S)

- First caller of `f2.add_tasks`: a markdown task that prefixes the
  selected lines with `- [ ] ` (keeps indent, skips existing boxes).
- Outcome (554f5ad): `lua/genja/ext/md-checklist.lua`, per markdown buffer from `after/ftplugin/markdown.lua`; visual `<F2>` stores `vim.b.f2_range`; all boxed -> boxes removed. Guide: `readme.2026-10-23.md-checklist.md`.

## 36. startdirs plugin (M)

- `plug-wip/genja-startdirs.nvim`; `START_DIRS` global removed.
- Spec `opts.dirs` keeps home and the config dir; `opts.groups` switches
  `[group]` sections on/off (boolean or function).
- File `lua/genja/local/startdirs.txt` (gitignored): `CONFIG/`, `DATA/`,
  `HOME/` expand at line start; `#` comments; `oil://` stripped.
- Oil `,s`/`,S` add/remove, `:StartdirsEdit`, `<M-1>`…`<M-4>` jump,
  usage ranking in `stdpath('data')/startdirs.usage`,
  `<leader>s…` and `<leader>jA`/`je`/`jD`.
- Outcome (fe676f6): as planned; `add()` writes `CONFIG/`/`DATA/`/`HOME/` back; groups `windows` (function), oni, fonv, openmw, movies. Guide: `readme.2026-10-23.startdirs.md`.
- Later (1132d6b): `<M-1>`…`<M-4>` jump to the most used dirs (`ranked()`) and don't count a use;
  `:Mydirs` opens the picker, `:Mydirs reset` deletes the usage file. Tested.

# Open

## 14e. nvim-lint: further linters (M)

- Per tool: Windows support, install path, stdin or file. Skip for now.
- Open questions:
  - install through mason-tool-installer, or only use what's on PATH?
  - first wave: which filetypes are edited most (yaml/ansible, markdown,
    lua, make)?
  - typos/codespell on every filetype, or only prose (markdown, gitcommit)?
- Spec (2026-10-23, auto-todo): markdownlint-cli2 (markdown), typos
  (markdown, gitcommit), yamllint (yaml), ansible-lint (yaml.ansible, via
  WSL like phpactor), selene (lua), checkmake (make), phpcs (php),
  actionlint (`.github/workflows/*.yml`). mason-tool-installer installs
  all but ansible-lint. None were on PATH; mason has phpcs already.
- Outcome (b5383bd): first wave as specced, `lua/genja/ext/lint.lua`, tools in
  the mason-tool-installer list. Untested.
- Second wave (608ad0f, 2026-10-24): hadolint (dockerfile), ruff (python,
  skipped while the ruff LSP is attached), editorconfig-checker (`M.any`,
  below a `.editorconfig`), vint (vim). Still later: vale, gitleaks. Untested.
- Later (266485f): vint off, broken on Windows (Vimjas/vint#394, #378).
- Later (9853946): gitleaks on every filetype; vale on markdown with the
  project's `.vale.ini` or the shared `lint/.vale.ini`, `:ValeSync`. Untested.
- Later (8dd25c3): checkmake works on Windows (own `--format` and parser).
- Later (09cc345): exit-code warnings name the linter instead of `cmd.exe`.

## Extras done along the way

- Winbar (6f29b37): quickfix windows show `w:quickfix_title`; the
  duplicate `%q` is gone.
- `<leader>j` keys (6aa5a7b, 73c4c3b): helpers in `map-telescope/fn.lua`;
  `jj1`/`jj2` quickfix/loclist, genja grep/find on `jjJ`/`jjj`, builtin
  pickers under `<leader>jb`; which-key groups `<leader>j.`, `<leader>j/`.
- focus.nvim (28c80c0): `vim.g.focus_disable`, so `<C-w>=` sticks and
  `<leader>tPf` can turn focus on.
- Notifications (2aadf61): every `vim.notify` starts with the file's `SRC`
  prefix.
- mylunsj (1151dfb): Telescope mydirs listed first.
- Cmdline completion (b5173ad): `<Tab>`/`<S-Tab>` next/previous item,
  `<Up>`/`<Down>` pick while the menu is open, else history.
- f2 (bab761a): `:F2Reload` renamed `:DevReloadF2`.
- Cmdline (0de4d52): `<C-j>`/`<C-k>` pick items, `<Up>`/`<Down>` history.
- map-lsp (5e788aa): descs for the nvim 0.11 `gr*` defaults, references on
  `gR`, `[d`/`]d` and `<F4>`/`<S-F4>` go the way their descs say.
- Markdown (21cfe96): `<F2>` glow preview in a new pwsh window, Windows only.
- Intro (81a4659): eob `~` in column 0 like vanilla.
- GUI (3580a06, ad94a79): nvim-qt toggles on `<leader>mQ…`, GuiFuncs
  picker (`<F3>`, `<F2>` gui), right-click frameless, one shared state per
  Gui* function; neovim-gui-shim on again. Tested.
- Zen (2f5fdaa, 209380a): `<leader>z0/z1/z2` in `map-plugin/zenmode.lua`;
  `<leader>z0` closes zen and unsets frameless. z1/z0 tested.
- Edit (8f25155): visual `<leader>w,` wraps lines as `"line",`; title case
  on `<leader>wsT`, sort paragraph on `<leader>wsp`.
- f2 git (e6c04ac): `<M-a>` git adds the file, picker stays open.
- Hilite (a1b0857): darker Search/IncSearch/CurSearch background.
- Telescope keymaps (2debb3b): `<M-r>` after `<M-f>`/`<M-x>` cycles the
  groups of the refined list; the title keeps the group. Tested.
- Tests (af13aed, 63800da, 9f5f014): map-plugin miss log and health,
  claudefterm per project, comps011 lsp/cmp/lint with groups and timings;
  `tests/Makefile` runs every dir.
- Telescope (9829d55): key footer prototype, `:TelescopeFooter`; spec with
  6 questions in `readme.2026-10-24.telescope-explore.md`. Footer abandoned 2026-10-25 and removed; key help in the results buffer kept.
- Terminal (51a1942, #48 in todo-ideas): bar cursor without blink in the
  StatusLine color, `:TermCursorShape bar|block`; `<S-Insert>` pastes `"+`
  in terminal mode. Hollow box still open.
- Aerial (cbe6c13): nav float winblend 5.
- Gitsigns (e9e50f7): `<leader>mGs` attaches skipped buffers again.
- f2 (5edddfa): groups of at most 6 chars (`diag`, `msgs`, `md`); the main
  list shows `group  label` with the labels in one column.
- Floaterm (50e4b8a): `:PwshFterm`.
- Mason (19d67f5): `make mason-luals` reinstalls lua-language-server headless.
- fu (38e3d2d): `:ToggleDiagnostics` for the current buffer.
- Pickers (620545d, 00b05e5, 93a8b69, 7bc4759, 31b74cd): f2 diag hide undoes show all; matched chars
  in Visual fg, bold; genja-finder `<M-Up>` rescans the parent dir, `<C-]>` opens the entry.
- Statusline (eddb6e5, 487aec2): `[Nameless]` for unnamed buffers; plain separators in terminals.
- Small (c4d6b26, 39dab59, 41e5bb6, 7b05312, 9073fcb, ac41882, 170ba57): md key-notation backticks;
  commit popup on `<leader>gcm`, `<leader>C`; nvim-qt.qss; `<leader>ei`; `:Ct`; guifont; mason-make autotools_ls.
- auto-todo 2026-10-26 (9152813, 776f78a, 2f85171, a5ae869, 5e81cdf): checkmake.ini, popup submit keys,
  telescope default keys, claudefterm marker toggle, f2 git staged picker.
- Completion (2d6b4bd, 00268c4, 191c6cf, 55c1296, e45657e, dbd3c64): blink.cmp replaces nvim-cmp, own
  sources on one builder, blade-nav source, tests/completion; menu colours from StatusLine; cmdline
  `<Down>`/`<Up>` walk the menu.
- genja-util (b34a1a8, f16695b): shared centred float and text helpers. gen.nvim (2bd7b6f): `<leader>ai`.
- LSP (527755d, 03ce43e): rename typed in a float (`grn`, `<leader>c2`); `:EnableLang` per session, `-save`.
- Misc 2026-10-28 (db72fa3, b7337e9, fda9e2e, 6adb2ed, ce73378): term scrolloff 0; `:help you`;
  `<leader>ts` spelling; colorscheme in init.vim; markdownlint MD012 off.
- 2026-10-29 (e26d31e, cbeef81, 80b9277, 5e70490, f9854f3, f4675f6): ccc `<leader>ic`/`<leader>tc`;
  paste search right-click and genja-paste-ai.nvim (`:PasteSearch`, `:Wot`, `:Google`, `:Perplexity`,
  `:Xty`, `<F2>`); terminal keys and `` <C-`> `` floaterm toggle.
- Markdown and diagnostics (420d58c, 893ff63, d69e644, 5b579f9, d778534, 42d9f18): md-fix `<leader>tm`;
  formatlistpat; diag-align one column per paragraph; colours per severity; dim link underline.
- UI (14a73da, b366920, 0db2b57, da8581b, 5eb0576, a143fca, f7a9970): legendary 0king fork `<leader>jl`;
  `:ClaudeFterm -ax`; which-key helix preset, left-centred, fixed height; groups test.
- Unsaved picker (58316bd, 4ccf5bc); `b:telescope_hint` (bb164fe); `:Messages -yank` (1270b29); abbrev `g` (a3e07a3).
- netrw.nvim (c30c591): icons from nvim-web-devicons. Ghost text (d7d084f): minuet-ai.nvim
  (`<leader>am`, blink `<M-y>`) and llm.nvim (`<leader>al`, llm-ls via mason) on ollama qwen3.5.

## Last scanned commit

Commits up to and including this one are in the files above. The next
update starts after it (`git log <hash>..HEAD`).

    f14feb12e31d9e12b24fba624cafa08ab1010b42  todo: keymap logger, both fork tracker and own Lua-native logger
