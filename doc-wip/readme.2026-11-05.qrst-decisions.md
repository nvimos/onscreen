# Q R S T: decisions (2026-11-05)

Spec items from auto-todo-20261105-2109. The user answered T 1-4, 10-13 and R 1; Claude decided the rest
("make your own decisions"). Each item is built in its own Claude worktree off `v2026`, then `/prish`
(branch `PR-<name>`, merged later with `/prish-merge`). Each gets a guided test session in `todo-test/`.

Marks: **user** = answered by the user, **claude** = decided by Claude; confirm or change in the test session.

## T. nvim as the interface to the OS: long processes

What makes the user leave nvim: watching long processes (servers, logs, `docker compose up`).

1. **user** The case to solve: long-running processes, started and watched from nvim.
2. **user** Output lands in a plain buffer (searchable, `gf`, quickfix), not a float.
3. **user** Shell: pwsh on Windows, bash on Linux.
4. **user** More questions before scoping (5-13); then built as below.
5. **claude** Start from the project list: the `<F2>` script group and overseer templates (composer, npm,
   Makefile, compose). No new "type a command" UI.
6. **claude** One output buffer per task, filled live; it follows the end while the cursor is on the last
   line, and stops following when the cursor moves up.
7. **claude** Statusline count of running tasks (e.g. `⏵2`), and one picker: show, restart, stop.
8. **claude** On exit: one `:messages` line (`<task>: exited 1 after 3m`); the statusline count turns red
   while a failed task is in the list. No popups.
9. **claude** Quitting nvim: attached running tasks are listed in the `:Unsaved` picker (stop or leave);
   detached tasks keep running and are not listed.
10. **user** Built on overseer.nvim: thin glue (buffer view, count, detach), no runner of our own.
    Must be able to detach tasks on Windows, as with tmux.
11. **user** Detach: by default a detached process writes to a log file in `stdpath('state')`, PID saved;
    reattach opens the log as a live buffer; stop kills the PID (no input). On request, psmux
    (native Windows tmux) for tasks that need input; reattach then opens `psmux attach` in a terminal.
12. **user** A task detaches when marked in the picker (a key, e.g. `<M-d>`) and when its name matches a
    pattern list of long tasks (server, serve, watch, dev, `compose up`, `logs -f`).
13. **user** Detached tasks show in the same picker, marked `detached`, read back from the state dir
    (log path, PID, command, cwd, start time) after an nvim restart; dead PIDs show as `exited`.

## R. Kubernetes YAML

1. **user** Schema matching: yaml-companion.nvim (mosheavni) now; replace with a small own matcher later if
   its interface doesn't fit.
2. **claude** yamlls attaches to `yaml` and `yaml.ansible` (`.yml` stays `yaml.ansible`); yaml-companion
   picks the schema from `apiVersion`/`kind`, so no k8s filetype.
3. **claude** Field docs come from the JSON schemas (offline): yannh/kubernetes-json-schema for core kinds,
   datreeio/CRDs-catalog for CRDs. `kubectl explain` and cluster CRDs later, once minikube runs.
4. **claude** Shown through: `K` = yamlls hover (schema description); generated `:help` files, one per kind
   (`:help k8s-Deployment.spec.replicas`, tag completion); a key on a field opens the help tag of its path.
5. **claude** Components first: Tekton (Task, Pipeline, TaskRun, PipelineRun) and Gateway API (the
   ingress-nginx successor; ingress-nginx was retired upstream in 2026). Autoscaling (HPA) is core.
   The git server (Gitea, Helm) later. Components are a config table: name, CRD schema paths, doc URLs.
6. **claude** Kubernetes version: one setting (default: the newest version yannh publishes that minikube
   supports), overridable per machine in `lua/genja/lsp/local.lua`.
7. **claude** yamlls in genja-completion011 (`lang/yaml.lua`); yaml-companion spec in `lua/lazyp/new/`;
   the help generator in the config (`lua/genja/ext/k8s-help.lua`), a plug-wip plugin later if it grows.
   Help files in `stdpath('data')/genja-k8s/doc`, built by a command (network), not at startup.
8. **claude** SchemaStore for other yaml (compose, GitHub workflows, kustomization) through yamlls;
   helm-ls later.
9. **claude** This round: yamlls + yaml-companion + help generator for core kinds and Tekton.

## S. zen modes by task

Open questions from todo-ideas.md (parked 2026-11-05), decided:

1. **claude** z3 = no zen-mode float (it hides other windows): maximized in the current tab, number +
   relativenumber, colorcolumn, all diagnostics, aerial open, debug UI as splits in the same tab.
2. **claude** Debug UI: nvim-dap-ui (installed; todo-test/php-debug.md leans to keeping it). dap-view is
   compared in the PHP debug session.
3. **claude** z3 opens the debug UI on the first stop, not at once.
4. **claude** z2: diagnostics on with the limit (3 per severity), as "limited diagnostics" was decided.
5. **claude** z1 unchanged; z0 restores everything z2/z3 changed.

## Q. WSL and Docker control

1. **claude** Survey first (telescope-docker, lazydocker, kubectl.nvim-style plugins); own pickers unless
   one fits.
2. **claude** `:Wsl` telescope picker from `wsl -l -v` (`WSL_UTF8=1`): name, state, version, default mark.
   `<CR>` shell in a floaterm (`:WslFterm <name>`, `wsl.exe -d <name> --cd ~`), `<M-s>` start,
   `<M-t>` terminate (confirm), `<M-o>` oil in `//wsl.localhost/<name>/home`, `<M-D>` set default
   (separate confirm).
3. **claude** `:Docker` picker from `docker ps -a`: logs into a live buffer (T's tail buffer when present),
   exec shell in a floaterm, restart, stop (confirm), remove (confirm). Missing docker: one notification.
4. **claude** Compose: projects with a compose file get `compose up` / `down` / `logs` tasks in the F2
   script group; `compose up` detaches (T, pattern list).
5. **claude** Keys under `<leader>m` (UI) if free, else a free prefix; which-key group and cheatsheet.
