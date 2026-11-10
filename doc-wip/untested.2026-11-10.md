# Untested, 2026-11-10 (auto-todo-20261110-0032)

One feature per line, in the order to try them. Mechanical checks were run by Claude (below);
the lines left open are for trying the features by hand, to learn them.

## Checked by Claude (2026-11-10 00:50, headless)

- [x] passed: `make test D=md` (incl. tests/md/test_md_links.lua), `D=f2`, `D=startup`
- [x] passed: templ and proto parsers build and load (`vim.treesitter.language.add`)
- [x] passed: F2 source gives `AI  claude`; F2 `view  colorcolumn on`; `<leader>tC` toggles 4,8 off and back
- [x] passed: md-fix status is '' when idle; genja-statusline has one statusline_extra part
- [x] passed: neotest-vitest and neotest-jest load and have is_test_file
- [x] passed: treesitter svelte, astro, angular build and load; vue_ls, vtsls, angularls, svelte, astro, tsc exist in nvim-lspconfig
- [x] passed: tests/reload (new: :ReloadLua keeps the old module, :ReloadLuaGenja keeps the cwd)
- [ ] failing: full `make test` (01:15): 265 of 267 pass. `comps011 mason: linters installed`: eslint, stylelint,
      golangci-lint, drupal-check not installed on this machine (`:MasonToolsInstall`). `startup below 1 s: a lua file`:
      1.04-1.47 s (it was just under 1 s at 00:50; tonight's svelte/astro/angular parsers cost at most ~50 ms in a quick
      comparison, the rest is noise or older); look at `nvim --startuptime` (lazy-plug-spec ~300 ms, opening buffers ~380 ms)
- [ ] not checked: PR branch changes (zen z3, tasks, docker, k8s) beyond syntax; run their test dirs after merging

## To try by hand

- [ ] F2 AI claude: `<F2>` > `ai  claude` from a file, then from oil (lua/genja/f2/collect/claude.lua)
- [ ] Go parsers templ, proto: open a `.templ` and a `.proto` file, `:InspectTree` (lua/lazyp/my/load-treesitter.lua) -> doc-wip/readme.2026-11-10.go-parsers.md
- [ ] F2 markdown links: `<F2>` > `inline links from urls` on a line with a bare URL (lua/genja/ext/md-links.lua) -> doc-wip/readme.2026-11-10.md-links.md
- [ ] md-fix busy mark: `:w` in a markdown file, `md-fix…` in the statusline until the reload (lua/genja/ext/md-fix.lua) -> doc-wip/readme.2026-11-10.md-fix-indicator.md
- [ ] colorcolumn toggle: `<leader>tC` twice, then `<F2>` > `view` (lua/genja/ext/colorcolumn.lua) -> doc-wip/readme.2026-11-10.colorcolumn.md
- [ ] JS tests vitest/jest: run the nearest test in a `*.test.tsx` of a vite project, then a jest project (lua/lazyp/langs/php-neotest.lua) -> doc-wip/readme.2026-11-10.js-tests.md
- [ ] TypeScript out of the box: `:EnableLang typescript` + vue / angular / svelte / astro in a sample app each, `<leader>dc` Node and Chrome (lua/genja/ext/debug-js.lua) -> doc-wip/readme.2026-11-10.typescript.md
