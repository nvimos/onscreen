# Untested features, 2026-10-24

For a later guided session: one feature per question. Each line: feature,
key or command to try, file, guide. Older ones: doc-wip/untested.2026-10-23.md.

## Session auto-todo-20261024-0014

- [x] ask popup to floaterm: <leader>pc, type, <M-p> (plug-wip/genja-ask.nvim) -> doc-wip/readme.2026-10-24.ask-floaterm-send.md
- [x] paste context: <leader>pC normal (@file) and visual (path:lines + code) (plugin/claude-fterm.lua) -> doc-wip/readme.2026-10-24.ask-floaterm-send.md
- [x] start dirs frecency: use a rare dir 2-3 times, it climbs in the ranked mydirs picker (plug-wip/genja-startdirs.nvim) -> doc-wip/readme.2026-10-24.startdirs-frecency.md
- [x] linters second wave: :MasonToolsInstall, then Dockerfile / .py / .vim / a .lua with space indent (lua/genja/ext/lint.lua) -> doc-wip/readme.2026-10-24.lint-second-wave.md
    - hadolint, ruff, editorconfig-checker ok (2026-10-24); vint disabled: crashes on Windows (#394, #378), todo-ideas.md 14e
- [x] map-plugin health: :checkhealth genja.map-plugin, then hide map-plugin/zenmode.lua and restart (lua/genja/map-plugin/health.lua) -> doc-wip/readme.2026-10-24.map-plugin-health.md
    - steps 1-2 by hand (2026-10-24); step 3 and the rest: `make test` in lua/genja/map-plugin/ (tests/map-plugin/test_health.lua, 10 cases)

## Session auto-todo-20261024-2315

- [x] outline keys: <leader>oo / <leader>oO, <Esc> closes the nav float (lua/genja/map-plugin/aerial.lua) -> doc-wip/readme.2026-10-24.aerial-outline-keys.md
    - ok (2026-10-25); then nav float winblend 5: untested
    - 2026-10-29: winblend ok (todo-done/tested-2026-10-29.md)
- [x] gitsigns off in markdown, <leader>mGs toggles per buffer (lua/genja/map-plugin/gitsigns.lua) -> doc-wip/readme.2026-10-24.gitsigns-skip-ft.md
    - failed 2026-10-25: <leader>mGs didn't attach; fixed (attach check), retest
    - 2026-10-29: retest ok
- [x] f2 item names: <F2> in markdown, with a claude running, in nvim-qt (lua/genja/f2/picker.lua) -> doc-wip/readme.2026-10-24.f2-item-names.md
    - ok (2026-10-25); then `group  label` with groups of 6 chars or less, right-aligned: untested
    - 2026-10-29: labels in one column, ok
- [ ] lint: gitleaks on any file, vale on markdown after :ValeSync (lua/genja/ext/lint.lua) -> doc-wip/readme.2026-10-24.lint-vale-gitleaks.md
- [x] diagnostics limit: 3 per severity, <leader>tt3, <F2> show all (lua/genja/ext/diag-limit.lua) -> doc-wip/readme.2026-10-24.diag-limit.md
    - ok (2026-10-25); then <F2> hide excess after show all: untested
    - 2026-10-29: covered by tests/ui/test_diagnostics-limit.lua
- [ ] zen: z1 <-> z2 reopens, z0 restores size and diag limit, z1 limit 2 (lua/genja/map-plugin/zenmode.lua) -> doc-wip/readme.2026-10-24.zen-toggles.md
    - 2026-10-29: z1 limit 2 ok; z0 left the window maximized, follow-up in todo-test/testink-now.md
- [x] markdown: <leader>mfx, fix on :w, abbreviations from md-abbrev.txt (lua/genja/ext/md-fix.lua) -> doc-wip/readme.2026-10-24.md-fix.md
    - 2026-10-29: fix on :w ok
- [x] :Messages -dump/-quick/-loc, <F2> messages (lua/genja/ext/messages.lua) -> doc-wip/readme.2026-10-24.messages.md
    - 2026-10-29: ok
- [-] telescope key footer (prototype): abandoned 2026-10-25, removed; <leader>jM, <F1>, <C-F1>; :TelescopeFooter (lua/genja/telescope-footer.lua) -> doc-wip/readme.2026-10-24.telescope-explore.md
- [ ] telescope key help in the empty results (key | m | description): <leader>jM, <F1>, <C-F1> (lua/genja/ext/telescope-virthelp.lua) -> doc-wip/readme.2026-10-24.telescope-explore.md
- [x] comps011 tests: make test D=comps011 G=gather, then make timings (tests/comps011/) -> doc-wip/readme.2026-10-24.comps011-tests.md
    - 2026-10-29: ok
