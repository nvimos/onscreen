# genja-commit.nvim

Commit message popup, gitcommit linting, message generation. Loaded from disk by
the config's `../../lua/lazyp/new/genja-commit.lua` (`ft = 'gitcommit'`, and on
`require('genja-commit')` from the oil popup in `lua/genja/oil/git-commit.lua`).
README.md lists keys and options.

How this file is kept: one heading per feature, one bullet per decision.
Unmarked bullets were stated by jaro. `(inferred)` marks Claude's reading of the
code or history: confirm or delete. `Hint:` is a working note for Claude.

## Layout

- `init.lua`: `setup(opts)`, `open(dir)`, `attach(buf)` (FileType gitcommit).
- `config.lua`: defaults and types; `popup.lua`, `lint.lua`, `generate.lua`, `git.lua`.
- The popup float comes from `genja-util.float` (`plug-wip/genja-util.nvim`, a spec dependency); the split is opened in `popup.lua`.
- The plugin must not require `genja.*`; the config passes `on_commit` (oil-git refresh). (inferred: same rule as genja-oily)
- Keys are buffer-local and set from `opts.keys`, so there is no `map-plugin/` file. (inferred)
- Hint: nothing here was run or tested yet (2026-10-22).

## Popup

- Moved out of `lua/genja/oil/git-commit.lua` (todo 14); oil only calls `open(dir)`.
- `<C-CR>`, `<M-CR>` and `<C-s>` commit (`<C-CR>` does not reach nvim through Windows Terminal; Alt+Enter there must be unbound from fullscreen), `<CR>` is a newline, `<Esc>` in insert goes to normal, `<Esc>`/`q` in normal aborts.
- `<M-u>` inserts `update: <first file>` (was `<C-CR>`); other staged files go in the body.
- `<C-CR>` with ERROR diagnostics asks once (`confirm()`); warnings don't ask.
- `window = 'split'` (default since 2026-10-31: the float was awkward to use) or `'float'`.
- Split: `botright` across the bottom, `winfixheight`, title in a window-local winbar; it stays open when you leave it; closing it any way keeps the draft (WinClosed).
- Float: leaving the window closes it (WinLeave), as before.
- An empty message aborts.
- Buffer is named after `git rev-parse --path-format=absolute --git-path COMMIT_EDITMSG` with `buftype=acwrite`; `:w` writes that file.
- Before `:w` text is kept in memory per repo (key: the COMMIT_EDITMSG path); after `:w` the in-memory copy is dropped.
- Reopening refills from the newer of draft and file ("newest wins").
- Only edits count: an untouched popup keeps the old draft. (inferred: `modified` check)
- git writes every commit's message into COMMIT_EDITMSG, so the file refills only when its mtime is newer than HEAD's committer time; `#` lines and the scissors part are dropped. (inferred)
- A successful commit clears the draft and empties the file.
- If COMMIT_EDITMSG is already open in another buffer, naming fails: the popup warns and `:w` is off. (inferred)
- Commits with `git commit -F -`, which keeps `#` lines (cleanup=whitespace); the Lua rules count them in the popup. (inferred)

## Lint

- Runs while typing (TextChanged, TextChangedI, InsertLeave), debounced 300 ms.
- nvim-lint + gitlint when both exist, else Lua rules; never both. Must work without Python.
- Own linter `genja_gitlint` reads stdin: nvim-lint's `gitlint` passes `--msg-filename <bufname>`, stale while typing and empty in the popup. Drops `--staged` too. (inferred)
- Limits: title 65, body 72 (`-c title-max-length.line-length`, `-c body-max-line-length.line-length`).
- Severity: title too long WARN, body line too long WARN, non-blank line 2 ERROR. gitlint's T1/B1 are remapped to WARN; its other rules stay ERROR.
- Mason installs gitlint (pypi package) once per session when Python is on PATH; the WindowsApps `python` stub doesn't count. (inferred: stub check)
- nvim-lint has its own spec, `lua/lazyp/new/nvim-lint.lua` (14e grows there); this plugin doesn't touch `linters_by_ft`.
- Not knowing which linter is active is fine.
- gitlint's B5 (body < 20 chars) and B6 (body missing) are ignored: title-only messages are fine.

## Generate

- `<M-g>` in every gitcommit buffer writes a message from the staged diff, inserted at the cursor.
- Async; `<C-c>` cancels (not `<Esc>`); timeout 60 s, configurable (`generate.timeout`, seconds).
- Input: built-in prompt (limits from `lint`), last 15 commit subjects, staged diff cut at 20 KB.
- Backend order configurable, first on PATH wins: `claude` (`-p --tools ""`, model `haiku`, effort `low`), `copilot` (`-p -s --no-ask-user`, `--model` optional), `gemini` (`-p` appended to stdin, `-o text`, `-m` optional), `aichat` (`-S`, `-r gitcommit` if `--list-roles` has it, else no role; `-m` optional).
- `gh copilot` is not a backend: the extension was retired on 2025-10-25 in favour of the standalone `copilot` CLI (needs a paid Copilot plan).
- The whole prompt goes on stdin: npm `.cmd` shims limit the command line to 8191 chars. (inferred)
- `exepath()` gives the full path so `.cmd` shims spawn on Windows. (inferred)
- Repo dir: the popup's dir, else nvim's cwd (git starts the editor in the work tree). (inferred)
- The copilot backend is untested.
- The gemini backend is untested; per its CLI reference, `-p` text is appended to stdin.
- Backends stay as `if` branches in `command_for()`; a wrapper per CLI only if it gets messy.
- Flags checked against the docs (2026-10-22), written as if both CLIs were installed.
- Hint: unverified: whether `copilot -p` also reads piped stdin (docs mention piped input, show no example). If not, the prompt has to move into the `-p` argument (8191-char limit through a `.cmd` shim).

## Conventional Commits

- Opt-in mode: `conventional` (plugin), overridable for all repos and per repo.
- `<M-g>` infers `type(scope): description` from the diff; that's the point of the mode. The prompt says the format wins over the log's style.
- Order, first set wins: `git config --local genja-commit.conventional`, project files (commitlint, commitizen, `.gitlint` with CT1), `git config --global`, the plugin opt.
- Release-tool files (semantic-release, release-please) don't count.
- Types: the standard list plus opt `conventional_types`; not read from project configs.
- A title not matching the format is an ERROR, so `<C-CR>` asks once. gitlint: `--contrib CT1` with the same types (`genja_gitlint_cc`).
- Decided once per buffer in `attach()` (git config calls are too slow for every lint run). (inferred)
- Empty title: no format error. (inferred: no noise in a fresh popup)
- Message language: English only, no option.
- Completion for types, scopes and footers is the `gitcommit` source in genja-completion011.nvim.
- Completion is on in the popup again: commit moved to `<C-CR>`, which blink.cmp doesn't map; `<CR>` accepts blink's preselected item while the menu is open.

## Ghost text

- minuet gives ghost text in gitcommit buffers (config's `lua/lazyp/langs-comps/minuet.lua`, `ft` + `auto_trigger_ft`), `<M-A>` accepts; since 2026-10-31.
- copilot.vim moved to the config's `lua/lazyp/unused/copilot.lua` (minuet won).
- minuet only sees the buffer, not the staged diff, so its suggestions are random; todo #14 in the config's `todo-ideas.md`.
- `attach()` still sets `b:copilot_enabled = true` (opt `copilot`), for other setups. (inferred)
