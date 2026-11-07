# Untested features, 2026-11-05 (auto-todo-20261105-2109)

One feature per question in the guided session. Earlier lists: doc-wip/untested.2026-10-2*.md.

- [ ] parsers css scss twig jsdoc regex gomod gosum gotmpl: needs `winget install LLVM.LLVM`, then open a .scss / .twig / go.mod (lua/lazyp/my/load-treesitter.lua) -> doc-wip/readme.2026-11-05.parsers-web-go.md
- [x] keymap usage counts: use some keys, then `:KeymapsStats` (plug-wip/abdul-keymaps.nvim/lua/keymaps/tracker.lua) -> todo-done/ideas-57-keymap-logger.md
- [ ] genja-commit untested parts: minuet staged diff, copilot/ollama `<M-g>`, bottom split (plug-wip/genja-commit.nvim) -> todo-done/ideas-14-gitcommit.md
    - [x] bottom split: works (2026-11-07)
    - [ ] minuet staged diff: ghost text doesn't fit the staged changes (2026-11-07); check lua/genja/ext/minuet-diff.lua with codestral
    - [ ] `<M-g>` with ollama: open; `<M-r>` now switches the backend (plug-wip/genja-commit.nvim, untested)
- [x] adding a language checklist: read readme.add-a-language.md against Go (readme.add-a-language.md) -> doc-wip/readme.2026-11-05.add-a-language.md
- [ ] golangci-lint only with a .golangci.* file: examples/go with the sample config (lua/genja/ext/lint.lua) -> doc-wip/readme.2026-11-05.lint-go-js-css.md
- [ ] eslint from the project's node_modules, only with an eslint config (lua/genja/ext/lint.lua) -> doc-wip/readme.2026-11-05.lint-go-js-css.md
- [ ] stylelint only with a stylelint config (lua/genja/ext/lint.lua) -> doc-wip/readme.2026-11-05.lint-go-js-css.md
- [x] aerial follows :e, splits and tabs: <leader>oo then :e another file (lua/lazyp/ui/aerial.lua) -> doc-wip/readme.2026-11-05.aerial-follow.md
- [x] <F2> script group: composer.json / package.json scripts, sub-picker runs them (lua/genja/f2/collect/scripts.lua) -> doc-wip/readme.2026-11-05.f2-scripts.md
    - [x] automated: tests/f2/test_scripts.lua, fixtures tests/f2/eff-two/ (composer, npm, :OverseerToggle), 2026-11-07
- [ ] Behat: :OverseerRun in a .feature file, this feature / this scenario, through ddev in WSL (lua/overseer/template/user/behat.lua) -> doc-wip/readme.2026-11-05.behat.md
- [ ] Go tests in neotest: <leader>Tr in a TestXxx, <leader>Ts summary (lua/lazyp/langs/php-neotest.lua) -> doc-wip/readme.2026-11-05.neotest-golang.md
- [ ] Drupal: .module is php inside a Drupal tree, phpactor indexes it, drupal-check on save (genja-completion011 lang/php.lua, ft/drupal.lua; lua/genja/ext/lint.lua) -> doc-wip/readme.2026-11-05.drupal.md
- [ ] cssls and html servers: open a .scss and a .html file, completion and K (genja-completion011 lang/css.lua, lang/html.lua) -> doc-wip/readme.2026-11-05.css-html-lsp.md
- [ ] C without a build: open kilo.c, gd works, no false errors; :CCompileDb (genja-completion011 lang/c_cpp.lua) -> doc-wip/readme.2026-11-05.c-navigate.md

## Q R S T worktree builds (not merged yet: `/prish-merge`, branches PR-zen-z3, PR-wsl-docker, PR-tasks-detach, PR-k8s-yaml)

Guided sessions: todo-test/zen-modes.md, todo-test/wsl-docker.md, todo-test/tasks-long-processes.md, todo-test/k8s-yaml.md.

- [ ] zen z2 limited diagnostics + z0 restore: `<leader>z2` / `<leader>z0` (lua/genja/map-plugin/zenmode.lua) -> doc-wip/readme.2026-11-05.zen-z3.md
- [ ] zen z3 layout: `<leader>z3` / `<leader>z0` (lua/genja/ext/zen-z3.lua) -> doc-wip/readme.2026-11-05.zen-z3.md
- [ ] zen z3 debug: dap-ui splits in the z3 tab on the first stop (lua/genja/ext/debug-ui.lua) -> doc-wip/readme.2026-11-05.zen-z3.md
- [ ] zen z3 tests: `make test D=ui` (tests/ui/test_zen_z3.lua) -> doc-wip/readme.2026-11-05.zen-z3.md
- [ ] wsl: `<leader>mw` / `:Wsl` picker, `<CR>` `<M-s>` `<M-t>` `<M-o>` `<M-D>` (lua/genja/ext/wsl.lua) -> doc-wip/readme.2026-11-05.wsl-docker.md
- [ ] wsl: `:WslFterm <name>` floaterm, completion, reuse (plugin/wsl.lua) -> doc-wip/readme.2026-11-05.wsl-docker.md
- [ ] docker: `<leader>mD` / `:Docker` picker, missing-docker warning, `vim.g.genja_docker_cmd` (lua/genja/ext/docker.lua) -> doc-wip/readme.2026-11-05.wsl-docker.md
- [ ] docker: `<CR>` live logs tab, `<M-e>` shell, `<M-r>`/`<M-s>`/`<M-d>` (lua/genja/ext/docker.lua) -> doc-wip/readme.2026-11-05.wsl-docker.md
- [ ] f2: `<F2>` compose up -d / down / logs -f (lua/genja/f2/collect/compose.lua) -> doc-wip/readme.2026-11-05.wsl-docker.md
- [ ] tasks output buffer + exit line: `<F2>` scripts, `<leader>ul`, `:messages` (lua/genja/tasks/outbuf.lua, lua/overseer/component/genja_exit_line.lua) -> doc-wip/readme.2026-11-05.tasks-detach.md
- [ ] tasks statusline count, red on failure: `⏵N` (lua/genja/tasks/status.lua, lua/lazyp/new/genja-statusline.lua) -> doc-wip/readme.2026-11-05.tasks-detach.md
- [ ] tasks picker: `:Tasks` / `<leader>uu` `<M-r> <M-s> <M-d> <M-i> <M-x>` (lua/genja/tasks/picker.lua) -> doc-wip/readme.2026-11-05.tasks-detach.md
- [ ] tasks detach log mode, reattach after restart: `<F2>` `<M-d>`, name patterns, `:Tasks` `<CR>`/`<M-s>` (lua/genja/tasks/detach.lua, lua/overseer/strategy/genja_detach.lua) -> doc-wip/readme.2026-11-05.tasks-detach.md
- [ ] tasks psmux mode: `<M-i>`, attach in floaterm (lua/genja/tasks/detach.lua) -> doc-wip/readme.2026-11-05.tasks-detach.md
- [ ] :Unsaved lists running attached tasks: `:qa` `<M-w>` leave / `<M-x>` stop (lua/genja/ext/unsaved.lua) -> doc-wip/readme.2026-11-05.tasks-detach.md
- [ ] yamlls + SchemaStore: `:EnableLang yaml` (plug-wip/genja-completion011.nvim/lua/genja/lang/yaml.lua) -> doc-wip/readme.2026-11-05.k8s-yaml.md
- [ ] yaml-companion schema per kind, Tekton/Gateway matcher: `<leader>cy` (lua/lazyp/new/yaml-companion.lua) -> doc-wip/readme.2026-11-05.k8s-yaml.md
- [ ] Kubernetes help files: `:K8sHelpBuild`, `:help k8s-index` (lua/genja/ext/k8s-help.lua) -> doc-wip/readme.2026-11-05.k8s-yaml.md
- [ ] field help at cursor: `gK` in YAML (lua/genja/map-plugin/yaml-companion.lua) -> doc-wip/readme.2026-11-05.k8s-yaml.md
- [ ] Kubernetes version override: `k8s.version` in local.lua (plug-wip/genja-completion011.nvim/lua/genja/lsp/config.lua) -> doc-wip/readme.2026-11-05.k8s-yaml.md
