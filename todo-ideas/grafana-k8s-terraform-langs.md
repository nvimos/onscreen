# Languages and tooling for the Grafana / Terraform / Kubernetes exercise repo

Found 2026-11-07 by opening a generated demo repo in a headless nvim: `~/es/grafana-cloud-minikube-terraform.claude`
(71 tracked files; phases 0-6 of its PLAN.md, no accounts). Reproduce: `make check-filetypes` there writes
`.tmp/filetypes.txt` (file, filetype, treesitter parser, linters). The CLIs it needs are installed (`make tools`),
and these pass there: terraform validate, helm lint, kubeconform, golangci-lint, ruff, yamllint, alloy fmt, promtool.

## Status 2026-11-07: built on branches (rebased onto v2026), untested in a real session

All four PR branches (k8s-yaml, wsl-docker, tasks-detach, zen-z3) were rebased onto `v2026`; zen-z3 had two comment/todo conflicts.
New language modules are off by default (`lua/genja/lsp/local.lua` or `:EnableLang <name>` turns them on). Checked headless
only: Lua syntax and filetype detection. Not run: any server attaching, lint output, parsers highlighting.
Installed on this machine (shared nvim-data, so the main config sees them): LLVM (winget), 16 parsers built (terraform hcl toml sql
promql python dockerfile helm, plus css scss twig gomod gosum gotmpl jsdoc regex that were listed but missing), Mason packages
terraform-ls tflint helm-ls taplo systemd-lsp sqlfluff docker-compose-language-service (npm warned EBADENGINE for the last one).
Before the code, LazyVim's lang extras were read (terraform, docker, helm, toml, sql); the picks match theirs.

| branch (config / plugin) | what |
|--------------------------|------|
| `PR-k8s-yaml` / `PR-yaml-lang` | `helm` filetype for chart templates, `yaml.helm-values`, `.helmignore`; `lang/helm.lua` (helm_ls); `helm` parser. yamllint no longer sees templates |
| `PR-wsl-docker` / `PR-docker-lang` | `lang/docker.lua` (dockerls + compose service); `dockerfile` parser |
| `PR-langs` / `PR-langs` | filetypes alloy, promql, systemd, jinja; `lang/terraform.lua` (+tflint), `toml.lua`, `systemd.lua`; parsers terraform hcl toml sql promql python; `tf`/`terraform-vars` and alloy parser registration; tflint, terraform validate, sqlfluff in `lint.lua` (only where `.tflint.hcl`, `.terraform`, `.sqlfluff` exist) |

Corrections to the list below: actionlint is already limited to `.github/workflows` (`COND.actionlint` in lint.lua), so that item
was wrong. Grafana Alloy has no language server: nvim-lspconfig's `alloy_ls` is the unrelated Alloy Analyzer (`*.als`), and the
`alloy` binary has no `lsp` command (1.21.2); only `alloy fmt` and `alloy validate`. Not done: sql LSP (LazyVim has none either,
only a DB client), `terraform fmt` on save, PSScriptAnalyzer, a PromQL server, `.tftpl`/`*.example` filetypes, an `alloy validate` linter.

Related, already open (don't duplicate):

- `todo-2026-neovim011.md` item 8 and the Kubernetes YAML item in `todo-ideas.md`: yamlls + schemas, built on branch `PR-k8s-yaml`, not merged into `v2026`.
- Item 16 and the WSL/Docker item: branch `PR-wsl-docker`, not merged.
- `todo-ideas.md` Go section: "parsers templ, sql, proto, dockerfile: not decided yet".
- `readme.add-a-language.md`: the checklist to follow per language below.

Measured with the real config, headless (no server was started). Checked means seen in the report; "not measured" means a
headless run can't tell (genja enables servers lazily on buffer events, so the LSP column of the report is empty).

## 1. Filetype detection

Filetype `NONE` in nvim 0.13-dev:

- [ ] `*.alloy` (Alloy configs): no filetype
- [ ] `*.promql`: no filetype
- [ ] systemd units `*.service`, `*.timer` outside /etc/systemd: no filetype
- [ ] `*.tftpl` (Terraform templates), `values.yaml.tftpl`: none; `*.tfvars.example`, `*.yaml.example`: none
- [ ] `*.j2` (Ansible/Jinja templates): none
- [ ] `.helmignore`: none
- [ ] Helm templates (`helm/*/templates/*.yaml`) are `yaml`, not `helm`; `_helpers.tpl` is `smarty`, `NOTES.txt` is `text`
- [ ] Terraform: `.tf` is filetype `tf` and `.tfvars` is `terraform-vars` (nvim 0.13), while the parser is `terraform`
- [ ] `ansible/*.yml` should be `yaml.ansible` (config maps `yml`), check it holds for a playbook in a subfolder and not for `.github`

## 2. Treesitter parsers

Not found in `nvim-data/site/parser`:

- [ ] terraform + hcl: and `vim.treesitter.language.register('terraform', 'tf')` for the 0.13 filetype names (get_lang('tf') returns `tf`)
- [ ] dockerfile, sql, toml, python: not in `lua/lazyp/my/load-treesitter.lua` at all (python has pyrefly + ruff but no highlighting parser)
- [ ] helm / gotmpl for Helm templates; promql; alloy (check whether a maintained parser exists)
- [ ] listed in load-treesitter.lua but not installed: css, scss, twig, jsdoc, regex, gomod, gosum, gotmpl, batch, c, cpp
      (the 2026-11-05 auto-todo added them untested; they need a C compiler, `winget install LLVM.LLVM`)
- [ ] `editorconfig`, `ssh`-style small ones: only if cheap

## 3. LSP (not measured; from the lang modules in `plug-wip/genja-completion011.nvim/lua/genja/lang/`)

Modules exist for bash, c_cpp, css, go, html, json, lua, make, php, powershell, python, typescript, vim. No module for:

- [ ] Terraform: terraform-ls (or tofu-ls); Mason package, root marker `.terraform.lock.hcl` / `*.tf`, several roots under `terraform/*`
- [ ] Helm: helm-ls (needs the `helm` filetype above)
- [ ] Dockerfile: `docker-langserver` is already in Mason's bin but there is no module (hadolint lints only)
- [ ] YAML / Kubernetes: yamlls in `PR-k8s-yaml` (off by default, not merged); also kustomize, GitHub Actions schema, Ansible (`ansible-language-server`)
- [ ] TOML (taplo), SQL (sqls or similar), systemd (systemd-language-server), PromQL (promql-langserver, check it is maintained)
- [ ] Alloy: nothing known; at least format with `alloy fmt`
- [ ] Go: gopls with a `go.mod` in a subfolder of the repo (`demo-app/`, no go.work at the root): does the root resolve?

## 4. Linters and formatters

In `lua/genja/ext/lint.lua` today: yaml = yamllint + actionlint, dockerfile = hadolint, python = ruff, go = golangci-lint.
Seen on the demo repo:

- [ ] actionlint runs on every yaml file; restrict it to `.github/workflows/`
- [ ] yamllint runs on Helm templates (Go template syntax): false errors; skip `helm` and `*/templates/*`
- [ ] Terraform: tflint (Mason: `tflint`), `terraform fmt -check` / `validate`, format on save with `terraform fmt`
- [ ] Helm: `helm lint` as a project linter; kubeconform for rendered manifests and kustomize output
- [ ] SQL: sqlfluff (SQLite dialect) for `poller/rollups.sql`
- [ ] TOML: taplo; PowerShell: PSScriptAnalyzer for `*.ps1`
- [ ] Alloy: `alloy fmt --test` and `alloy fmt -w` (the binary is not on PATH after the winget install; path is `C:/Program Files/GrafanaLabs/Alloy/alloy-windows-amd64.exe`)
- [ ] PromQL: `promtool check`: `promtool` has no stdin/file linter for bare queries; see whether the language server covers it
- [ ] The tools above that winget provides (terraform, tflint, helm, kubectl, kustomize, kubeconform, golangci-lint, ruff): a
      `tools` target in the demo Makefile installs them; consider listing the same winget ids in `make status` in `tests/`

## 5. Project awareness and tasks

- [ ] ROOT_MARKERS for terraform (`.terraform.lock.hcl`), helm (`Chart.yaml`), kustomize (`kustomization.yaml`), `.tflint.hcl`, `.golangci.yml` in a subfolder
- [ ] overseer / `<F2>` tasks from a Makefile with a pwsh `SHELL` (the demo Makefile has `check-*` targets): confirm the F2 make group lists them
- [ ] terraform plan/apply, `helm template`, `kubectl apply -k` as overseer templates (item 16 Docker/WSL branch covers containers only)
- [ ] tests: neotest for python `unittest` (poller) and Go (neotest-golang exists); run `make check-py` / `go test` from nvim
- [ ] a `tests/` case per new language that proves filetype + parser + linter (`make status` table), as `readme.add-a-language.md` step 8

## Suggested order

1. Filetypes and the `tf` parser registration (cheap, no installs, unblocks everything else).
2. Parsers that were listed but never installed (a C compiler).
3. Restrict actionlint / yamllint; add tflint, terraform fmt, helm lint.
4. Merge `PR-k8s-yaml` and add terraform-ls + helm-ls + dockerls modules.
5. The rest (sql, toml, systemd, alloy).

Session record (estimates, usage, decisions): `~/es/grafana-cloud-minikube-terraform.claude/doc-wip/readme.2026-11-07.session.md`.
