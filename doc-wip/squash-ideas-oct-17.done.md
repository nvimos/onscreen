# Squash ideas, 2026-10-17: done

Ideas from `squash-ideas-oct-17.md` that are done and tried (Done = yes),
moved here on 2026-10-23. Details in `squash-ideas-oct-17.details.done.md`.

| #  | Idea                                      | Effort | Tokens | Done |
|----|-------------------------------------------|--------|--------|------|
| 1  | genja-finder.nvim: move live grep/find    | done   | ~1k    | yes  |
| 2  | quickfix: close with `x`                  | XS     | ~3k    | yes  |
| 3  | remove charity nag, keep startup message  | XS     | ~4k    | yes  |
| 4  | LSP hover: close with `<Esc>`             | XS     | ~5k    | yes  |
| 5  | LSP hover: scroll from the buffer         | S      | ~6k    | yes  |
| 6  | oil: auto confirm single create           | S      | ~6k    | yes  |
| 7  | oil: `gga` -> git add                     | S      | ~6k    | yes  |
| 8  | oil: `<S-F1>` from oil's current dir      | S      | ~8k    | yes  |
| 9  | gitsigns: stage/reset hunks (with #37)    | S      | ~8k    | yes  |
| 10 | cmp: popup flash on `:w`                  | S      | ~10k   | yes  |
| 11 | fold commands with «Fold: …» descriptions | S      | ~10k   | yes  |
| 12 | code actions in telescope                 | S/M    | ~12k   | yes  |
| 13 | winbar: json/yaml: key path               | M      | ~15k   | yes  |
| 15 | oil: hide folders via `.oily` + hide key  | M      | ~18k   | yes  |
| 17 | `g.`: catch-all action menu               | M      | ~20k   | yes  |
| 26b | telescope keymaps: refine, `<M-r>` groups     | S      | 2322c3b | yes (2026-10-24) |
| 19  | claude floaterm per project, `<leader>pt`     | M      | 80f96ba | yes (2026-10-24) |
| 19  | ask popup `<M-p>` to floaterm; `<leader>pc`   | XS     | a289890 | yes (2026-10-24) |
| -   | startdirs ranking by frecency                 | XS     | 26ed71f | yes (2026-10-24) |
| 14e | nvim-lint second wave (hadolint, ruff, ec, vint) | S   | 608ad0f | yes (2026-10-24) |
| -   | map-plugin miss log, `:checkhealth genja.map-plugin` | S | 89e227d | yes (2026-10-24) |
| -   | map-plugin item closed (todo-done/ideas-38)    | -      | af13aed | yes (2026-10-24) |
| 19  | claude from nvim closed (todo-done/ideas-19)  | -      | 63800da | yes (2026-10-24) |
| 40  | aerial: <leader>oo / <leader>oO, <Esc> closes nav | S | auto-todo-20261024-2315 | untested |
| 41  | gitsigns: skip filetypes (markdown), <leader>mGs | S | auto-todo-20261024-2315 | untested |
| 42  | f2 item names: display filter, labels rewritten | S | auto-todo-20261024-2315 | untested |
| 14e | gitleaks (any ft), vale (markdown, shared .vale.ini) | S | auto-todo-20261024-2315 | untested |
| 43  | diagnostics: 3 per severity, <leader>tt3, F2 show all | S | auto-todo-20261024-2315 | untested |
| 44  | zen: z1<->z2 reopen, z0 restores size, z1 limit 2 | S | auto-todo-20261024-2315 | untested |
| 45  | markdown: <leader>mfx, fix on save, abbreviations | S | auto-todo-20261024-2315 | untested |
| 46  | :Messages -dump/-quick/-loc, F2 messages, capture (off) | M | auto-todo-20261024-2315 | untested |

## 1. genja-finder.nvim move — done
- Already landed in fc271a7 and 0f08579 (`lua/lazyp/new/genja-finder.lua`, mappings in `map-telescope.lua`).
- Check `move-plan.md` is gone/obsolete, delete the todo line.

## 2. quickfix: close with `x` — done
- New `after/ftplugin/qf.lua`.
- Buffer map `x`: `lclose` if the window is a location list, else `cclose`.

## 3. Charity nag — done
- `opt.lua`: add `I` to `shortmess` (today it is removed on purpose).
- `VimEnter` autocmd, only when started with no args: echo own one-liner from `vim.version()`.
- Done differently: `lua/genja/intro.lua` redraws Nvim 0.13's intro (logo, colors, separators) without the charity lines, as virtual lines on the empty start buffer.

## 4. LSP hover: `<Esc>` closes — done
- Normal-mode `<Esc>` in `map-lsp.lua`: close the hover float if one is open, else plain `<Esc>`.
- Find the float through the buffer var Neovim's `open_floating_preview` sets.

## 5. LSP hover: scroll — done
- `<C-f>`/`<C-b>` (or `<C-d>`/`<C-u>`) in the source buffer scroll the open float via `nvim_win_call`.
- Fall back to the normal key when no float is open. Shares the helper with #4.

## 6. oil: auto confirm single create — done
- `skip_confirm_for_simple_edits = true` is already set; reproduce first.
- If it still prompts, read oil's "simple edit" rule; else wrap the save with a check on the pending actions.
- Done: the prompt was oil's "Save changes?" on `<CR>`. `<CR>` on a new entry now saves, then opens it by path.

## 7. oil: `gga` -> git add — done
- Add `gga` to `O.keymaps` in `lua/lazyp/explorer/oil.lua`, callback in `fn-oil.lua`.
- Reuse `F.get_oil_entries()` (supports visual range); `vim.system({'git','add','--',...},{cwd=dir})`; notify result.
- Done, plus `,a`; unstage with `ggr`/`,r`; both jump to the next unstaged file.

## 8. `<S-F1>` from oil dir — done
- In `map-telescope.lua`, when `filetype == 'oil'` pass oil's current dir as the root to `live_find`.
- If genja-finder has no root/cwd option, add one (plugin must not require oil; config passes the dir).
- Done with genja-finder's existing `cwd` option; `<F1>` grep too.
- genja-finder follow-ups (`scope.lua`): a passed `cwd` is root `arg` (`from:arg`, first in the `<M-r>` cycle, kept through reopens and the `<F1>` switch); prompt title shows the scanned dir, last three parts; all path labels unix style (`c:/foo/bar`). The last round of these is untested.

## 9. gitsigns
- New spec `lua/lazyp/git/gitsigns.lua`, late event, `on_attach` buffer maps.
- Maps: `]h`/`[h`, stage, reset, preview, undo stage; visual stage/reset.

## 10. cmp: popup flash on `:w` — done
- Find who types `:w` (autosave plugin, a `:w<CR>` mapping).
- Fix at source with `<Cmd>write<CR>`; fallback: cmdline cmp `enabled` returns false while the cmdline starts with `w`.
- Done: normal-mode `:w<CR>` -> `<Cmd>write<CR>` in `map-zero.lua` (no cmdline, no popup); which-key `filter` keeps `:` mappings out so `:` still opens the cmdline. Nothing typed `:w` automatically.

## 11. Fold commands with descriptions
- Table of `z` fold commands -> «Fold: …» text, loop with `vim.keymap.set(lhs, lhs, {desc})`.
- Put it in the `Folds` block of `map-zero.lua` or a small new file; check which-key presets first.

## 12. Code actions in telescope — done
- Override `vim.ui.select` with a small telescope dropdown (cursor theme), or add telescope-ui-select.
- Prefer the in-config override (no new dependency).
- Done (d0881d0): `lua/genja/ui-select.lua`, loaded from `genja/init.lua`. Telescope dropdown for every `vim.ui.select` caller (code actions, `:OverseerRun`); telescope loads only when shown; `<Esc>` reports nil.

## 13. json/yaml key path in winbar
- Treesitter walk from cursor node to root, collecting pair keys (`pair` in json, `block_mapping_pair`/`flow_pair` in yaml).
- New component in `genja-statusline.nvim` `winbar.lua`, only for json/jsonc/yaml; cache per cursor position.

## 15. oil: `.oily` hidden set + hide key — done
- `view_options.is_hidden_file`: hide names listed in `.oily` (oil's dir, then parents up to PWD), cached by mtime.
- Keymap appends the entry name to `.oily` and refreshes; oil's `g.` still shows everything.
- Done with one `.oily` at `:pwd`: bare names hide everywhere, paths hide one entry. `,M` appends the entry's path.
- Globs too (`vim.glob`: `*.log`, `lua/**/zold*`). Documented in `lua/genja/readme.md`.

## 17. `g.` catch-all action menu — done
- Build the item list at call time: LSP methods the clients support, treesitter node actions, git hunk actions if gitsigns.
- Show with `vim.ui.select` (gets telescope via #12), or with nvim's built-in `PopUp` menu (`:popup`).
- Done (879f2a5): `lua/genja/actions.lua` on `g.` and `<LocalLeader>/`, its own telescope picker. `cur:` items for the cursor (LSP methods the server supports, line diagnostics, word, oil entry); unprefixed ones for buffer/editor (format, symbols, diagnostics, pickers, `<F2>`, overseer). No gitsigns yet (#9). In oil, `g.` stays oil's; use `,/`. Notes: `doc-wip/idea-oct.catch-all.md`.

## Extras done along the way (not in the original list)
- oil-git.nvim: git status symbols in oil (`lua/lazyp/explorer/oil-git.lua`); refreshed after add/unstage/commit.
- oil `<C-S-p>`: diff preview when the entry has changes, `<CR>` in the diff opens the file at that line.
- oil `ggc`/`,c`: commit popup; `<C-CR>` inserts `updated <file>`, draft kept until a commit succeeds.
- oil: E211 workaround (oil #762), buffers of deleted files are wiped before the delete.
- focus.nvim (untested): typed opts; excluded buftypes `terminal`, `nofile`, `prompt` and oil get `vim.b.focus_disable`.
- Go: organize imports + format on save, once-per-folder warning when gopls has no go.mod/go.work.
- lua_ls: diagnostics hidden until the workspace is loaded (slow-PC false `undefined-global`).
- Telescope pickers: send marked or all results to the location/quickfix list; `<C-/>` key list; hint in the empty prompt.
- oil: `<C-Right>` runs `gx`; modules renamed by purpose.
- Dates: `<leader>id` appends the date; abbreviations `ymd!`, `ymdt!` (in `abbreviations.vim`).
- `Makefile.runtimes.mk`: `runs`, `mods` (installs the Neovim npm package).
- copilot.vim: ghost text, `<M-f>` accepts; loads only for gitcommit, `<leader>at` toggles the other filetypes.
- urlview.nvim: visual `gx` and `<leader>gx` open several marked URLs.
- genja-splitpad.nvim: padding column in unfocused splits (spec disabled for now).
- Go: gopls local import groups, code lenses, `<leader>cl` runs one.
- `has()` checks fixed (`win32`/`unix`, compared with 1); terminal gets the non-GUI listchars.
- which-key: `<F2>`/`<F3>` scroll the popup.
- focus.nvim off by default.
- `<S-Insert>` pastes the clipboard on the cmdline too; `~/.local/bin` on PATH; oil:// start dirs.

## Closed in auto-todo-20261023-2048

- #18 `<F2>` context picker: all sub-items done, 50 unit tests green; manual checks on the untested list.
- #19a codecompanion: spec kept; ACP trial and hourglass check untested.
- #20 voice input: stop at Win+H; whisper.cpp spec in todo-2027.txt.
- #26a abdul-keymaps section order: stays by name.
- #33 gitea to w11s-cut: moved to todo-2027.txt. Done 2026-10-24: Makefile.gitea.mk now in C:/_setup.new/setup-2026-cut.

Notes moved from the summary:

## 18. `<F2>` context picker
- Dispatcher by filetype/buffer: Makefile -> targets picker -> run in floaterm/terminal; oil -> `git status --porcelain` picker with diff preview, multi-select -> git add.
- Done (6e169f6): make context. Sources (2026-10-19): `lua/genja/f2/` with `make.lua`, `adhoc.lua`, `run.lua`, `git.lua`, `registry.lua` (`f2.add_tasks` / `f2.remove_tasks`, `f2.group_order`). Usage notes: `doc-wip/readme.overseer.md`, `doc-wip/readme.idea18-f2-context.md`.

## 20. Voice input
- Free now: Windows voice typing (`Win+H`) types into the terminal in insert mode. Try it first.
- Full: record (ffmpeg) -> whisper.cpp local -> insert text at cursor. Spec in todo-2027.txt.

## 19. Claude from nvim
- So far (wip, untested): `claude` in a floaterm (`lua/genja/claude.lua`): `:ClaudeFterm`, `<leader>pc` context paste, `<leader>pC` prompt popup; codecompanion spec as an alternative.
- Session marker: `/rename` in claude writes `claude-session: <uuid> <title>` as a comment into the buffer claude was started from; `:ClaudeFterm` from a file with a marker resumes that session in its cwd.
- Later (2026-10-24): close on exit (14cd1f8), `<C-Up>` normal mode (45c94fe); moved into genja-ask.nvim / genja-claudefterm.nvim (6ebff35); keys `<leader>pc` ask, `<leader>pC` paste, `<leader>mC` terminals (7452969); `<F2>` claude source (4f57a26); `:ClaudeFterm -one` in the current window, tested (1d15d43).
- Later: one floaterm per project root, picker `<leader>pt` / `:ClaudeFterm!` (80f96ba); terminal `<M-]>`/`<M-[>` tabs, `<M-{>` previous window (af9c7a4, 6a4c414); `:DevReloadClaude` (bab761a); prompt popup `<C-CR>` sends (55140b2, 96562ed).

