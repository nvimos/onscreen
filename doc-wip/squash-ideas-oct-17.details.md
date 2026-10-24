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

- `lua/genja/winsize.lua`: `<M-=>`/`<M-->` grow/shrink by percent or fixed
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
- Outcome: 29b (9bae096) `lua/genja/wrapfold.lua`; 29a (4f73a32) `lua/genja/tilde.lua`, also left/right, up/down, min/max, first/last; dial (3b309f8). Alma copies marked "duplicated". Guides: `readme.2026-10-23.wrapfold.md`, `readme.2026-10-23.tilde-dial.md`.

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
- Outcome (554f5ad): `lua/genja/md-checklist.lua`, per markdown buffer from `after/ftplugin/markdown.lua`; visual `<F2>` stores `vim.b.f2_range`; all boxed -> boxes removed. Guide: `readme.2026-10-23.md-checklist.md`.

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
- Outcome (b5383bd): first wave as specced, `lua/genja/lint.lua`, tools in
  the mason-tool-installer list. Untested.
- Second wave (608ad0f, 2026-10-24): hadolint (dockerfile), ruff (python,
  skipped while the ruff LSP is attached), editorconfig-checker (`M.any`,
  below a `.editorconfig`), vint (vim). Still later: vale, gitleaks. Untested.

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

## Last scanned commit

Commits up to and including this one are in the files above. The next
update starts after it (`git log <hash>..HEAD`).

    de5c652f73410d7c54c9afee17035f0cd1095477  todo: ideas and squash files up to 81a2844
