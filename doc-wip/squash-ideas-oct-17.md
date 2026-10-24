# Squash ideas, 2026-10-17

Ideas from `todo-ideas.md`, cheapest first. Effort: XS < 30 min, S < 1 h,
M = a few hours, L = a day or more, spec = needs decisions first. Tokens:
rough Claude cost to implement. Details per idea in
`squash-ideas-oct-17.details.md` (same numbering). Done and tried ideas
moved to `squash-ideas-oct-17.done.md` (2026-10-23).

## Untested (implemented, not tried yet)

Checklist for trying them: `doc-wip/untested.2026-10-23.md`.

| #   | Idea                                          | Effort | Commit  | Done     |
|-----|-----------------------------------------------|--------|---------|----------|
| 14  | gitcommit: nvim-lint + gitlint                | M      | several | untested |
| 29b | visual `zf`: fold markers with a title        | XS     | 9bae096 | untested |
| 17b | right-click Actions (g.), source/claude items | XS     | 3b9b1ed | untested |
| 29a | `~` toggles true/false                        | S      | 4f73a32 | untested |
| 29a | dial.nvim, groups per filetype                | S      | 3b309f8 | untested |
| 34  | F2 markdown: selection to checklist           | S      | 554f5ad | untested |
| 25  | refine decorator: `<M-x>` exclude             | S      | 1ff3ec3 | untested |
| 28  | window sizes, resize mode; smart-splits off   | S/M    | 6e9c477 | untested |
| 32  | tabline: nvim-qt resize changed tabs          | M      | a4bca16, 8f2a667 | untested |
| 36  | startdirs plugin, oil keys, ranking           | M      | fe676f6 | untested |
| 14e | nvim-lint first wave (8 linters)              | M      | b5383bd | untested |
| 35  | genja-recent.nvim, `<C-F1>`                   | M      | 147e827 | untested |
| 30/31 | statusline clicks; PopUp per ft, :Morning   | M      | d015986, 00cbfb9 | untested |
| 16  | `<M-?>` ask popup, 5 targets, sessions        | M      | 507ab65 | untested |

## Open, ranked (auto-todo-20261024-2315)

Ask = questions (asked this round, so 0 left), Tokens = rough cost. Built easiest first.

| #   | Idea                                                       | Ask | Tokens |
|-----|------------------------------------------------------------|-----|--------|
| -   | gitsigns: skip filetypes (markdown), `<leader>mGs` toggle  | 0   | ~5k    |
| -   | f2 item names: display filter, labels rewritten            | 0   | ~10k   |
| 14e | gitleaks (any ft), vale (markdown, shared .vale.ini)       | 0   | ~12k   |
| -   | diagnostics: 3 per severity, `<leader>tt3`, F2 show all    | 0   | ~14k   |
| -   | zen: z1<->z2 reopen, z0 restores size, z1 limit 2          | 0   | ~6k    |
| -   | markdown: `<leader>mfx`, fix on save, abbreviations file   | 0   | ~14k   |
| -   | `:Messages -dump/-quick/-loc`, F2 messages, capture (off)  | 0   | ~22k   |
| -   | comps011 tests: lsp/cmp/lint, fast/slow/gather groups      | 0   | ~45k   |
| -   | telescope: key footer prototype + spec                     | 0   | ~12k   |
| 39  | claude session marker: enabled:false toggle, `!!` in txt   | 1   | ~4k    |
| 14  | genja-commit: try it (untested list)                       | 0 (you test) | 0 |

Closed in auto-todo-20261024-0014: #19 oil resume (`[-]`), #19 paste (`<M-p>`),
startdirs frecency, #14e second wave, map-plugin healthcheck.
Earlier round: #18, #19a, #20, #26, #33, #35, #30, #31, #16.

## 14. gitcommit lint
- Check gitlint's Windows support first; alternative: commitlint or a small custom nvim-lint linter.
- Spec `lua/lazyp/langs-comps/nvim-lint.lua`; `linters_by_ft.gitcommit`; lint on `BufEnter`/`InsertLeave`/`BufWritePost`.

## 16. `<M-?>` AI popup
- Spec 2026-10-23 in the details file: `lua/genja/ask.lua` + `ask/backends/`, the float turns into the answer, sessions, log.

## Extras done along the way

- Winbar: quickfix title instead of a duplicate `%q` (6f29b37).
- `<leader>j` regrouped: `jj1`/`jj2` quickfix/loclist, genja grep/find `jjJ`/`jjj`, builtins `<leader>jb`; which-key groups `<leader>j.`, `<leader>j/` (6aa5a7b, 73c4c3b).
- focus.nvim: `vim.g.focus_disable`, so `<C-w>=` sticks (28c80c0).
- `vim.notify` messages name their file via `SRC` (2aadf61).
- mylunsj: Telescope mydirs first (1151dfb).
- Cmdline completion: `<Tab>`/`<S-Tab>`, `<Up>`/`<Down>` pick items (b5173ad).
- `:F2Reload` renamed `:DevReloadF2` (bab761a).
- Cmdline: `<C-j>`/`<C-k>` pick items, `<Up>`/`<Down>` history (0de4d52).
- map-lsp: gr* descs, references on `gR`, `[d`/`]d` fixed (5e788aa).
- Markdown `<F2>` glow preview, Windows (21cfe96).
- Intro: eob `~` in column 0 (81a4659).
- GUI: nvim-qt toggles `<leader>mQ…`, GuiFuncs picker, right-click frameless; tested (3580a06, ad94a79).
- Zen: keys in `map-plugin/zenmode.lua`, `<leader>z0` stays closed; tested (2f5fdaa, 209380a).
- Edit: visual `<leader>w,` wraps lines as `"line",`; `<leader>wsT`, `<leader>wsp` (8f25155).
- f2 git: `<M-a>` git add, picker stays (e6c04ac).
- Hilite: darker search background (a1b0857).
- Startdirs: `<M-n>` by rank, not counted; `:Mydirs`, `:Mydirs reset`; tested (1132d6b).

