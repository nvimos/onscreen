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

# Open

## 19. Claude from nvim

- Claude Code: coder/claudecode.nvim implements the IDE integration
  (WebSocket MCP server in nvim; Claude Code sees selection, opens diffs in
  nvim). Check its Windows issues before adopting. Simpler: run `claude` in
  floaterm/toggleterm (`:ClaudeFterm` per the `Fterm` naming rule) and map a
  key that sends the visual selection with file:line to that terminal.
- Claude Desktop: has no API to inject a prompt from outside; only possible
  link is MCP (Desktop calling a server that reads nvim state via
  `--listen`/`nvim --server`). Not worth it; note and skip.
- Overlaps with #16; #16 is a one-shot question, #19 is a session.
- Options (2026-10-18), cheapest first:
  - A. `claude` in a floaterm, no plugin (picked, done)
    - `:ClaudeFterm`, `<leader>pc` pastes file/selection context, `<leader>pC` prompt popup
    - Claude edits files directly; floaterm's checktime refreshes open buffers
    - no live cursor/selection sharing, no in-nvim diffs
  - B. coder/claudecode.nvim (not picked for now)
    - same protocol as the VS Code/JetBrains extensions, over a local WebSocket
    - live file/selection context, edits shown as nvim diffs (`:w` accept, `:q` reject)
    - native terminal provider, no snacks needed
    - beta; native Windows undocumented (pure Lua, no Windows bug in issue titles)
  - C. codecompanion.nvim, «idea 19 companion» (picked, spec added)
    - chat buffer in nvim; Claude Code through ACP (`claude-agent-acp`)
    - or the Anthropic API with a key, billed apart from the subscription
    - big plugin with its own workflow; Windows undocumented
  - D. Claude Desktop: no inbound prompt API, only MCP plumbing; skipped
- `claude -p` is print mode: one prompt, print, exit. Each call starts a new
  process (settings, CLAUDE.md, hooks, MCP), so seconds before the model even
  runs; `--bare` and `--model` trim it. The `<leader>pC` popup pastes into the
  running session instead: no startup, context kept.
- Outcome so far (wip, uncommitted, untested):
  - A: `lua/genja/claude.lua`, keys in `plugin/claude-fterm.lua`.
    `:ClaudeFterm` (auto-alias.vim) passes the floaterm options as a dict,
    so they stay out of `claude.lua`; claude starts in a right vsplit.
    `<leader>pc` pastes `@file` or `path:lines` + fenced code (fence longer
    than any backtick run; no paste from oil/terminal buffers).
    `<leader>pC` popup: draft kept, history `<C-p>`/`<C-n>`, brief mode
    `<C-b>`, snacks-style `<Esc>`. Text goes in as one bracketed paste.
    `<C-q>`/`<C-j>` in the claude terminal: back to the previous window.
    Still floaterm calls inside `claude.lua` (bufnr, show, hide, kill).
  - A, session marker (`claude.lua`, "session marker" section):
    - A new claude gets `--session-id <uuid>`, so its transcript
      `~/.claude/projects/<cwd, non-alnum -> '-'>/<uuid>.jsonl` is known.
    - `/rename` appends a `custom-title` line there. A 2 s timer reads what
      was appended and writes `claude-session: <uuid> <title>` (with
      `commentstring`) into the buffer claude was started from: replaces an
      older marker, else appends at the end; not saved.
    - Starting from a buffer with a marker in its first or last 5 lines:
      `--resume <uuid>`, floaterm `--cwd` from the transcript's `"cwd"`
      (fallback: the file's parent that encodes to the project dir name).
    - Polled, not `fs_event`: a new session's transcript doesn't exist until
      claude writes it.
    - Limits: `--resume` of a session open elsewhere makes a copy with a new
      id, so its renames don't reach the marker; a space in the cwd is
      escaped for floaterm, unchecked.
  - C: `lua/lazyp/langs-comps/codecompanion.lua` (v20, `claude_code` ACP
    adapter, `<leader>ac`/`<leader>aa`); setup and quirks in
    `doc-wip/readme.idea19-companion.md`. Needs the npm adapter and a token.
  - Open: a spec (see #16 for the popup's direction).
  - Later:
    - terminal buffer named `claude-ft «<session title>»`, else the cwd
      basename; title capped at 16 chars (bfd6eef)
    - `<C-Left>` in the claude terminal: window on the left; claude's
      terminal title updates off while it starts, against the hourglass
      cursor flicker (4e79669)
    - `:ClaudeFterm [flags]` (`--chrome`, `--model`, `--effort`,
      `--permission-mode`, ...) at start, with `<Tab>` completion (55240fa)
    - `<C-Right>` in the claude terminal: next tab (4a917a0)
    - `<M-]>`/`<M-[>` next/previous tab, `<M-{>` previous window in the
      claude terminal (af9c7a4, 6a4c414)
    - `:DevReloadClaude` drops the cached claude modules (bab761a)
    - prompt popup 90x8, placed up-left (55140b2); `<C-CR>` sends, `<CR>`
      adds a newline (96562ed)
    - one floaterm per project root as specced below; `<leader>pt` (not
      `<leader>pl`, that is Perplexity) and `:ClaudeFterm!` pick running
      ones (80f96ba). Untested.
- Spec (2026-10-23, auto-todo): one floaterm per project root. Root: the
  session marker's cwd, else the git root, else cwd. Name
  `claude-<root basename>`. `:ClaudeFterm` shows the current project's
  terminal or starts it; `<leader>pc` / `<leader>pC` send to it.
  `<leader>pl` ("Claude: list terminals") and `:ClaudeFterm!` open a
  telescope dropdown of running ones: `<CR>` shows, `<M-d>` kills.
  Oil resume: not needed.

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

## 19. paste / ask popup (2026-10-24)

- `<leader>pC` opens the ask popup, whose default target is claude-p; sending
  to the claude terminal needed `<M-t>`. `<M-p>` in the popup now sends to
  the floaterm whatever the target (a289890). `<leader>pc` unchanged, untested.
- Oil resume closed `[-]`: not needed.

## startdirs frecency (2026-10-24)

- `ranked()`: count x recency (genja-recent's weights, copied); usage file
  `count<Tab>time<Tab>path`, old lines read with time 0 (26ed71f). Headless-tested.

## map-plugin miss log and healthcheck (2026-10-24)

- Misses: once per kind+name per session, to `stdpath('log')/genja-map-plugin.log`
  with the caller's file, no notify. `:checkhealth genja.map-plugin`: runtime
  only (misses, keys not asked for, mappings not run yet) (89e227d).

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

## Last scanned commit

Commits up to and including this one are in the files above. The next
update starts after it (`git log <hash>..HEAD`).

    8f2a667930af2c2cf38056577dcf8b4e4a7063db  resize: stay on the current tab after VimResized's tabdo wincmd =; augroup _resize_equalize_tabs (idea 32)
