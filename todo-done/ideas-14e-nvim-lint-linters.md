From: todo-ideas.md

- [x] 14e. nvim-lint: further linters (not covered by an LSP)
  - yaml / ansible: ansible-lint, yamllint
  - dockerfile: hadolint
  - markdown: markdownlint-cli2, vale (prose)
  - lua: selene or luacheck
  - make: checkmake
  - github workflows: actionlint
  - any filetype: codespell or typos, gitleaks (secrets), editorconfig-checker
  - python: ruff (pyright covers types only)
  - php: phpcs (phpactor runs phpstan, maybe not phpcs)
  - vim: vint (old)
  - skip: shellcheck (bashls), eslint (LSP)
  - check Windows support per tool; non-stdin linters run only after :w
  - [x] first wave (decided 2026-10-23): markdownlint-cli2, typos (markdown, gitcommit), yamllint,
      ansible-lint (WSL, like phpactor), selene, checkmake, phpcs, actionlint
    - install: mason-tool-installer (all but ansible-lint)
    - lua/genja/ext/lint.lua; untested, doc-wip/readme.2026-10-23.lint-first-wave.md (b5383bd)
  - later: hadolint, vale, ruff, gitleaks, editorconfig-checker, vint
  - [x] second wave (decided 2026-10-24): hadolint, ruff (only without the ruff LSP),
      editorconfig-checker (any filetype, below a .editorconfig), vint
    - untested, doc-wip/readme.2026-10-24.lint-second-wave.md
    - tested 2026-10-24: hadolint, ruff, editorconfig-checker ok (.editorconfig got indent_style)
    - vint: moved to todo-2027.md (2026-10-31)
  - still later: vale, gitleaks
    - [x] done 2026-10-24: gitleaks on every filetype; vale on markdown, project .vale.ini or the shared
          lint/.vale.ini (Microsoft, write-good; :ValeSync downloads the styles); untested,
          doc-wip/readme.2026-10-24.lint-vale-gitleaks.md (9853946)
  - [x] checkmake works on Windows: own --format and parser (8dd25c3)
  - [x] exit-code warnings name the linter, not cmd.exe (09cc345)
