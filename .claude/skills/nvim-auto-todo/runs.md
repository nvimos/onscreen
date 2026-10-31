# auto-todo runs

One row per run, added in step 8 above the two summary rows. Times are local, measured from the session start, the tag and the commit times.

| Date       | Project                | Type          | Languages / frameworks                                           | Built | Closed | Questions | Est. tokens | Question time | Build time |
|------------|------------------------|---------------|------------------------------------------------------------------|-------|--------|-----------|-------------|---------------|------------|
| 2026-10-23 | nvim config (genja)    | editor config | Lua, Neovim 0.11, lazy.nvim, telescope, oil, which-key; Windows | 8     | 5      | 16        | ~87k        | ~40 min (19:18–19:58, incl. writing the skill) | ~17 min (19:58–20:15) |
| 2026-10-23 | nvim config (genja)    | editor config | Lua, Neovim 0.11+, lazy.nvim, telescope, nvim-lint, mason, floaterm, claude CLI; Windows | 6     | 5      | 24        | ~152k       | ~52 min (20:48–21:40, incl. explaining 14e/actionlint) | ~26 min (21:40–22:06) |
| 2026-10-24 | nvim config (genja)    | editor config | Lua, Neovim 0.11+, lazy.nvim, nvim-lint, mason, floaterm, checkhealth; Windows | 4     | 2      | 6         | ~45k        | ~10 min (00:04–00:14) | ~6 min (00:14–00:20) |
| 2026-10-24 | nvim config (genja) | editor config + in-repo plugins | Lua, Vim script, lazy.nvim, telescope, nvim-lint, mini.test | 10 | 2 (#19, map-plugin) | 12 | ~146k | ~40 min (22:38-23:19) | ~33 min (23:19-23:52) |
| 2026-10-26 | nvim config (genja) | editor config + in-repo plugins | Lua, Vim script, telescope, nvim-lint, floaterm, mini.test | 5 | 1 (#48) | 13 (10 planned + 2 telescope + 1 explain) | ~28k | ~37 min (22:33-23:10) | ~13 min (23:11-23:24) |
| 2026-10-29 | nvim config (genja)    | editor config | Lua, Neovim 0.11+, lazy.nvim, which-key, telescope, mini.test, F2 picker; Windows; scope: todo-2026-neovim011.md only | 3     | 4      | 10        | ~60k        | ~33 min (21:38–22:11, incl. the :ClaudeFterm -ax detour) | ~4 min (22:12–22:16, commit times) |
| 2026-10-29 | nvim config (genja) | editor config + in-repo plugins | Lua, Vim script, telescope, which-key, abbreviations | 1 (unsaved picker) | 2 (<leader>; letters, telescope exploration) | 3 (of 6 planned; spec items skipped by request) | ~18k | ~7 min (23:00-23:07) | ~3 min (23:07-23:10) |
| 2026-10-31 | nvim config (genja) | editor config + in-repo plugins | Lua, lazy.nvim, blink.cmp, ollama, mason | 2 (netrw.nvim, minuet + llm.nvim) | 2 (vint to todo-2027, #14e) | 5 (4 planned + 1 pros/cons) | ~45k | ~20 min (~10 min on 2026-10-30 from 18:18, ~10 min on 2026-10-31 to 05:26) | ~6 min (05:26-05:32) |
| **total (8 runs)** | | | | **39** | **23** | **89** | **~581k** | **~239 min** | **~108 min** |
| **avg per built item** | | | | | | **2.3** | **~15k** | **~6.1 min** | **~2.8 min** |
