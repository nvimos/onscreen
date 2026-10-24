# Untested features, 2026-10-24

For a later guided session: one feature per question. Each line: feature,
key or command to try, file, guide. Older ones: doc-wip/untested.2026-10-23.md.

## Session auto-todo-20261024-0014

- [x] ask popup to floaterm: <leader>pc, type, <M-p> (plug-wip/genja-ask.nvim) -> doc-wip/readme.2026-10-24.ask-floaterm-send.md
- [x] paste context: <leader>pC normal (@file) and visual (path:lines + code) (plugin/claude-fterm.lua) -> doc-wip/readme.2026-10-24.ask-floaterm-send.md
- [x] start dirs frecency: use a rare dir 2-3 times, it climbs in the ranked mydirs picker (plug-wip/genja-startdirs.nvim) -> doc-wip/readme.2026-10-24.startdirs-frecency.md
- [x] linters second wave: :MasonToolsInstall, then Dockerfile / .py / .vim / a .lua with space indent (lua/genja/lint.lua) -> doc-wip/readme.2026-10-24.lint-second-wave.md
    - hadolint, ruff, editorconfig-checker ok (2026-10-24); vint disabled: crashes on Windows (#394, #378), todo-ideas.md 14e
- [x] map-plugin health: :checkhealth genja.map-plugin, then hide map-plugin/zenmode.lua and restart (lua/genja/map-plugin/health.lua) -> doc-wip/readme.2026-10-24.map-plugin-health.md
    - steps 1-2 by hand (2026-10-24); step 3 and the rest: `make test` in lua/genja/map-plugin/ (tests/map-plugin/test_health.lua, 10 cases)

## Session auto-todo-20261024-2315

- [ ] outline keys: <leader>oo / <leader>oO, <Esc> closes the nav float (lua/genja/map-plugin/aerial.lua) -> doc-wip/readme.2026-10-24.aerial-outline-keys.md
- [ ] gitsigns off in markdown, <leader>mGs toggles per buffer (lua/genja/map-plugin/gitsigns.lua) -> doc-wip/readme.2026-10-24.gitsigns-skip-ft.md
