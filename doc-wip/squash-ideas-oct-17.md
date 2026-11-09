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

## Open, ranked (auto-todo-20261110)

Ask = questions left (40 asked 2026-11-09 23:58 - 2026-11-10 00:31 by audible-wizard, so 0), Tokens = rough cost.
Q-T were built 2026-11-05 on PR branches (untested); this round applies the answers there.

| #  | Idea (from todo-ideas.md)                          | Where            | Decision 2026-11-10                                                        | Ask | Tokens |
|----|----------------------------------------------------|------------------|----------------------------------------------------------------------------|-----|--------|
| 1  | Go: parsers templ, proto                           | v2026            | both; sql on PR-langs, dockerfile on PR-wsl-docker                         | 0   | ~3k    |
| 2  | F2 markdown: URLs to inline links                  | v2026            | visual range or cursor line; path > 60 chars -> basename, no query         | 0   | ~8k    |
| 3  | React: JS test runner                              | v2026            | neotest-vitest and neotest-jest, picked by the project's config file       | 0   | ~14k   |
| 4  | statusline indicator while md-fix runs             | v2026            | md-fix `<leader>tm`                                                         | 0   | ~8k    |
| 5  | colorcolumn toggle                                 | v2026            | F2 item + `<leader>t` key (new, from zen Q7)                               | 0   | ~4k    |
| S  | zen modes by task                                  | PR-zen-z3        | z3 maximizes nvim-qt, no colorcolumn; rest as built                        | 0   | ~4k    |
| T  | nvim as the interface to the OS (long tasks)       | PR-tasks-detach  | statusline_extra hook, `<M-d>` asks first, names dev watch serve start     | 0   | ~10k   |
| Q  | WSL and Docker control                             | PR-wsl-docker    | docker in the phpactor distro by default; more pickers to todo-ideas       | 0   | ~4k    |
| R  | Kubernetes YAML                                    | PR-k8s-yaml      | kubectl explain, ingress-nginx + metrics-server, .k8s-version, SchemaStore.nvim, status fields | 0 | ~20k |

Skipped this round: PHP debugging (own session), diff viewers (try first), LLM chat (survey later).

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
- Telescope keymaps: `<M-r>` after `<M-f>`/`<M-x>` cycles the refined list; tested (2debb3b).
- Tests: map-plugin (af13aed), claudefterm (63800da), comps011 lsp/cmp/lint (9f5f014).
- Telescope: key footer prototype, `:TelescopeFooter`, spec with 6 questions (9829d55). Footer abandoned 2026-10-25, removed; key help in the results buffer kept.
- Lint (#14e): vint off (266485f), gitleaks + vale (9853946), checkmake on Windows (8dd25c3), warnings name the linter (09cc345).
- Terminal (#48): bar cursor in StatusLine color, `:TermCursorShape`, `<S-Insert>` paste (51a1942).
- Aerial: nav float winblend 5 (cbe6c13).
- Gitsigns: `<leader>mGs` attaches skipped buffers (e9e50f7).
- f2: groups ≤ 6 chars, `group  label` columns (5edddfa).
- `:PwshFterm` (50e4b8a); `make mason-luals` (19d67f5); `:ToggleDiagnostics` (38e3d2d).
- f2 diag hide/show (620545d); picker matches in Visual fg (00b05e5); finder `<M-Up>` parent rescan, `<C-]>` opens entry (93a8b69, 7bc4759, 31b74cd).
- Statusline `[Nameless]` (eddb6e5), plain separators in terminals (487aec2); md key-notation backticks (c4d6b26); commit popup on `<leader>gcm`, `<leader>C` (39dab59); nvim-qt.qss (41e5bb6); `<leader>ei` (7b05312).
- auto-todo 2026-10-26 items with hashes: checkmake.ini (9152813), popup submit keys (776f78a), telescope default keys (2f85171), marker toggle (a5ae869), f2 git staged (5e81cdf); `:Ct` (9073fcb); guifont (ac41882); mason-make autotools_ls (170ba57).
- blink.cmp replaces nvim-cmp, blade-nav source, tests/completion (2d6b4bd, 00268c4, 191c6cf, 55c1296); genja-util float and text helpers (b34a1a8, f16695b); gen.nvim `<leader>ai` (2bd7b6f).
- LSP rename float (527755d); `:EnableLang` (03ce43e); menu colours (e45657e); cmdline `<Down>`/`<Up>` (dbd3c64); term scrolloff 0 (db72fa3); `:help you` (b7337e9); `<leader>ts` (fda9e2e); GUI colors (6adb2ed); MD012 off (ce73378).
- ccc `<leader>ic`/`<leader>tc` (e26d31e); paste search right-click and genja-paste-ai.nvim (cbeef81, 80b9277, 5e70490, f9854f3); terminal keys, `` <C-`> `` float (f4675f6); md-fix `<leader>tm` (420d58c, 893ff63); formatlistpat (d69e644); diag-align (5b579f9); diagnostic colours (d778534); md link underline (42d9f18).
- legendary 0king fork `<leader>jl` (14a73da, b366920); `:ClaudeFterm -ax` (0db2b57); which-key helix, fixed height (da8581b, 5eb0576, a143fca), groups test (f7a9970).
- Unsaved picker (58316bd, 4ccf5bc); `b:telescope_hint` (bb164fe); `:Messages -yank` (1270b29); abbrev `g` (a3e07a3).
- netrw.nvim icons (c30c591); ghost text: minuet-ai.nvim and llm.nvim on ollama (d7d084f).
- Terminal: bare `:terminal` opens pwsh/bash (80c8fa1), sessions keep shells under a wrapper (140ed09), `<S-Insert>` to pwsh (df0a668).
- Cmdline: history until a menu walk, no preselect (fc6cd99); `<C-BS>` (8351d8f); `<M-j>`/`<M-k>` (aa7cdc5); `<M-f>`/`<M-w>`/`<M-s>` (9693171); no menu on one-char commands (c655f23); shell names from a disk cache, `:ResetPathCache` (abfb666); abbrev `<CR>` outside `:` (82cd9a4).
- Minuet: `<M-y>` only (6dead7f); providers, keys from `local/secrets.lua` (3e90c60, 6122927); `:CheckHealthSimpleMinuet` (3e5a645); Codestral default (a300cea); provider guide (0c3e3a3).
- `:HiInspect` (17dceca); `:CheckHealthSimpleLsp` (7d43221); completion doc window colours, frame, padding (29e8c26, 08a6f5c, 7390836).
- Lint: cancelled runs not reported (cd4a0ab); `:ValeSync` on its own (1c67fc5); `<leader>cx` rule off (01f7cda).
- Tests: go warmup (a3f049a), timings order (cd57bdf), linters installed (ef9867a), llm/minuet (ae71dd3), key help (48936c2), md-mixed (3d74e10), copilot skip (9244bc1), yellow NOTE (9bebc59).
- ecolog2 or v1 (d7842a2, ca842c0); copilot.vim and llm.nvim shelved (18ed193, 1185287); oil `:Lexplore` (e7b8ece).
- Markdown: `gq` wraps checkboxes (58538ea); md-fix follows editorconfig (aeab075); `]j`/`[j` open checkboxes (70a20a1); `~` cycles checkbox states (c773959).
- diag-align `<leader>tta`, `<F2>` (27648c7); paste search with a picked provider (fa42e84); hilite diagnostics and links (698b3a6, 65812bb); zen z1/z2 hide diagnostics (333bf79).
- keymaps spec on VeryLazy (06bca1b); `:Ct` takes the current window (3911a0b); `<leader>'` oldfiles (5c637f8).
- Mason: cut-off installs repair on open, `make` kills lua_ls first (eef2590); `update-treesitter` prerequisite again (3480b0d).
- PHP/Go out of the box (auto-todo 2026-11-05): parsers (9a8aa25), cssls/html (0ed9ee4), eslint/stylelint/golangci-lint (e7bad3d), drupal-check (dbc21f8), `<F2>` scripts (bac05c1, test 5fe22f0), Behat template (23d563c), neotest-golang (1037aa2); add-a-language and C guides (7b69862, cbb8df5).
- PHP debug: dap-ui tab, F-key flip, `:DdevXdebugHost` (17e6c2b); dap-view `<leader>dv` (8f5b8d2); zen z0 restores size (98aa8a4); checkmake off (fdbf5e3).
- plug-wip own repos, `Wip.dir` (2492965, 43c806f, 90814fb); tests/startup (f1951ca); oil `]c`/`[c`, `ggC` (f5ce192); `~` cycle x . ~ n (0862b18); aerial follow test (ed46209).
- mini.ai textobjects (09eb281); node select `<C-s>`/`<BS>` (3bed5be); `<leader>ttt` global (b829ae5); `ymdd!` (c6143cd); tests cmdline shellcmd, which-key groups (53d9252, aa538e9).
- Oil preview `<C-M-y>`, `å` (70c8803, 7aa1a62); claudefterm markers removed, paste without a file (54ffee2; plugin ff46a75, ea2d156).

