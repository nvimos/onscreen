# list of improvements to nvim

## related files

squash ideas details and estimations

    ./doc-wip/squash-ideas-oct-17.md
    ./doc-wip/squash-ideas-oct-17.details.md

future work (need to limit the neovim-2026 project)

    ./todo-2027.md
    ./todo-2028.md

migration from 0.9 to 0.11 (the file that started it all)

    ./todo-2026-neovim011.md

## ideas november

- [ ] review the keys added on default answers in auto-todo 2026-11-10 (not thought through, picked the recommended option)
  - `<leader>tC` colorcolumn toggle (map-zero.lua); `<leader>mGd` diffview layout toggle
  - PR-wsl-docker: `<leader>mw` :Wsl, `<leader>mD` :Docker; :Wsl `<M-s>` `<M-t>` `<M-o>` `<M-D>`; :Docker `<M-e>` `<M-r>` `<M-s>` `<M-d>`
  - PR-tasks-detach: `<leader>u…` task keys; :Tasks `<M-r>` `<M-s>` `<M-d>` `<M-i>` `<M-x>`; :Unsaved `<M-w>` / `<M-x>` on tasks
  - PR-k8s-yaml: `gK` field help (and kubectl explain), `<leader>cy` schema pick
  - check each against jolemak (reach, clashes with telescope defaults and genja-finder shared keys), which-key groups

- [x] now that jolemak keymap in win is sending the correct control chars...
  - `<c-p>` (logical mapping) for preview is not as convenient as `<c-y>` on jolemak
    - added `<c-m-y>` for now. maybe no need to overthink this.
  - [x] oil preview on `<C-A-y>`/`<C-M-y>` (70c8803); `å`, what Ctrl+Alt+Y (AltGr) sends on jolemak (7aa1a62)

- [x] extras outside the idea list (2026-11-05)
  - [x] oil: ]c [c jump to changed entries, ggC commits the entry (f5ce192); ~ checkbox cycle x . ~ n (0862b18)
  - [x] plug-wip plugins are their own repos (tox2ik/<name>); specs load the local checkout, else clone it (2492965, 43c806f, 90814fb)
  - [x] tests/startup: a clean clone starts cleanly, startup below 1 s (f1951ca)
  - [x] lint: checkmake off, its config and parser kept (fdbf5e3)
  - [x] docs: readme.add-a-language.md checklist (7b69862); guide for C without a build (cbb8df5)
  - [x] aerial: test that the sidebar follows :edit (ed46209)

- [x] extras outside the idea list (2026-11-06)
  - [x] textobjects: mini.ai with treesitter f c o, next/last on aN iN / aL iL (09eb281);
        visual `<C-s>`/`<BS>` grow and shrink by node (3bed5be); tested
  - [x] abbrev: ymdd! weekday and date (c6143cd); tested
  - [x] tests: cmdline shellcmd menu opens on a typed char (53d9252); which-key buffer-local groups (aa538e9)

- [x] extras outside the idea list (2026-11-07)
  - [x] claudefterm: session markers removed, /rename still names the terminal (54ffee2; plugin ff46a75);
        visual `<leader>pC` pastes from a buffer without a file (plugin ea2d156); tested

## ideas october

- [x] extras outside the idea list (2026-10-23)
  - [x] winbar: quickfix windows show w:quickfix_title, no duplicate %q (6f29b37)
  - [x] map-telescope: helpers in fn.lua; `<leader>jj1`/jj2 quickfix/loclist, genja grep/find on jjJ/jjj,
          builtins under `<leader>jb` (6aa5a7b); which-key groups `<leader>j`. and `<leader>j`/ (73c4c3b)
  - [x] focus.nvim: vim.g.focus_disable, so `<C-w>`= sticks; `<leader>tPf` can turn it on (28c80c0)
  - [x] every vim.notify names its file through a SRC prefix (2aadf61)
  - [x] mylunsj lists Telescope mydirs first (1151dfb)
  - [x] cmdline completion: `<Tab>`/`<S-Tab>` next/previous, `<Up>`/`<Down>` pick while the menu is open (b5173ad)

- [x] extras outside the idea list (2026-10-24)
  - [x] cmdline: `<C-j>`/`<C-k>` pick items, `<Up>`/`<Down>` back to history (0de4d52)
  - [x] map-lsp: descs for nvim 0.11 gr* defaults, references on gR, [d ]d go the way their descs say (5e788aa)
  - [x] markdown: `<F2>` glow preview in a new pwsh window, Windows only (21cfe96)
  - [x] intro: eob ~ drawn in column 0 like vanilla (81a4659)
  - [x] gui: nvim-qt toggles on `<leader>mQ`…, GuiFuncs picker (`<F3>`, `<F2>` gui), right-click frameless,
          one shared state per Gui* function; neovim-gui-shim on again; tested (3580a06, ad94a79)
  - [x] edit: visual `<leader>w`, wraps lines as "line",; title case on `<leader>wsT`, sort paragraph `<leader>wsp` (8f25155)
  - [x] f2 git: `<M-a>` git adds the file, picker stays open (e6c04ac)
  - [x] hilite: darker Search/IncSearch/CurSearch background (a1b0857)
  - [x] startdirs: `<M-1>`…`<M-4>` jump by rank and don't count a use; :Mydirs picker,
          :Mydirs reset deletes the usage file; tested (1132d6b)

- [x] extras outside the idea list (2026-10-25)
  - [x] telescope keymaps: `<M-r>` after `<M-f>`/`<M-x>` cycles the groups of the refined list; tested (2debb3b)
  - [x] tests: map-plugin miss log and health (af13aed), claudefterm per project (63800da),
          comps011 lsp/cmp/lint with groups and timings (9f5f014); tests/Makefile runs every dir
  - [x] aerial: nav float 5% see-through (cbe6c13)
  - [x] gitsigns: `<leader>mGs` attaches skipped buffers again (e9e50f7)
  - [x] f2: groups of at most 6 chars, main list `group  label` in one column (5edddfa)
  - [x] floaterm: :PwshFterm (50e4b8a)
  - [x] mason: make mason-luals reinstalls lua-language-server headless (19d67f5)
  - [x] :ToggleDiagnostics for the current buffer (38e3d2d)
  - [x] f2 diag: hide excess undoes show all (620545d); pickers: matched chars in Visual fg, bold (00b05e5)
  - [x] genja-finder: `<M-Up>` rescans in the parent dir (93a8b69); `<C-]>` opens the entry, a dir entry itself (7bc4759, 31b74cd)
  - [x] statusline: [Nameless] for unnamed buffers (eddb6e5); telescope key footer dropped, key help kept (5c6e9a7)
  - [x] md: substitutions wrap vim key notation in backticks (c4d6b26)
  - [x] commit popup also on `<leader>gcm` and `<leader>C` (39dab59); `<leader>ei` tab-local from stdpath (7b05312)
  - [x] nvim-qt: nvim-qt.qss stylesheet, dark title bar note in ginit.vim (41e5bb6)

- [x] extras outside the idea list (2026-10-26)
  - [x] tests: pwsh Makefile, per-name groups, timings for every case, make gather/failed/plan/slow/status (8d2d86c)
  - [x] lua_ls: GENJA_LUA_NO_LIB=1 skips libraries, set by tests/Makefile (53642d0)
  - [x] :checkhealth genja.lsp: servers not installed, broken Python venvs, mason launchers (96b7910)
  - [x] bashls: mason's shellcheck.exe path on Windows (0bdc719); claudefterm kill() crash (0b46cfa)
  - [x] auto-todo round: shared checkmake.ini (9152813), `<M-CR>`/`<C-s>` submit popups (776f78a), telescope default keys
        and `<C-/>` descs (2f85171), claudefterm marker toggle and !! markers (a5ae869), f2 git staged picker (5e81cdf)
  - [x] statusline: plain separators in terminals, icons in GUI (487aec2); :Ct for :ClaudeFterm (9073fcb)
  - [x] guifont JetBrainsMono NFM 12 (ac41882); make mason-make reinstalls autotools_ls (170ba57)

- [x] extras outside the idea list (2026-10-27)
  - [x] blink.cmp replaces nvim-cmp, own sources on one source builder, blade-nav source (2d6b4bd, 00268c4);
        tests/completion: sources, keys, cmdline, `<CR>` (191c6cf, 55c1296)
  - [x] genja-util: shared centred float and text helpers; plug-wip plugins tidied (b34a1a8, f16695b)
  - [x] gen.nvim: ollama qwen3.5:0.8b prompt menu on `<leader>ai` (2bd7b6f)

- [x] extras outside the idea list (2026-10-28)
  - [x] LSP rename typed in a float over the word: grn, `<leader>c2`, right-click (527755d)
  - [x] :EnableLang turns a language on/off for the session, -save writes lsp/local.lua, `<F2>` offers it (03ce43e)
  - [x] completion menu colours from StatusLine (e45657e); cmdline `<Down>`/`<Up>` walk the menu, history without one (dbd3c64)
  - [x] terminal windows: scrolloff 0 (db72fa3); :help you page (b7337e9); `<leader>ts` toggles spelling (fda9e2e)
  - [x] colorscheme set in init.vim, Gui* settings grouped (6adb2ed); markdownlint MD012 off (ce73378)

- [x] extras outside the idea list (2026-10-29)
  - [x] ccc.nvim colour picker and highlighter: `<leader>ic`, `<leader>tc` (e26d31e)
  - [x] paste search: right-click on a selection (cbeef81); genja-paste-ai.nvim: :PasteSearch, :Wot,
        :Google / :Perplexity / :Xty, `<F2>` lookup, web and ai providers (80b9277, 5e70490, f9854f3)
  - [x] terminal keys, `` <C-`> `` floaterm toggle, sessions keep shells (f4675f6)
  - [x] md-fix: expand tabs, backtick vim keys, `<leader>tm` (420d58c; Lua port 893ff63); formatlistpat for checkboxes, footnotes (d69e644)
  - [x] diag-align: virtual text in one column per paragraph (5b579f9); diagnostic colours per severity (d778534);
        dim underline on markdown links (42d9f18)
  - [x] legendary: 0king fork, `<leader>jl`, in mylunsj (14a73da), bigger dropdown (b366920)
  - [x] :ClaudeFterm -ax passes --ax-screen-reader (0db2b57)
  - [x] which-key: helix preset, left-centred, fixed height (da8581b, 5eb0576, a143fca); test groups vs mappings (f7a9970)
  - [x] unsaved buffers picker before :qa, jj, s: (58316bd)

- [x] extras outside the idea list (2026-10-30)
  - [x] unsaved picker: layout, E13 overwrite prompt, :q and :x, tests (4ccf5bc)
  - [x] telescope: per-picker prompt hint via b:telescope_hint (bb164fe); :Messages -yank copies :messages (1270b29)
  - [x] abbrev: g quits via a `<CR>` map, :g/pat/ stays :global (a3e07a3)

- [x] extras outside the idea list (2026-10-31)
  - [x] netrw.nvim icons (c30c591); ghost text: minuet-ai.nvim and llm.nvim on ollama (d7d084f); both in todo-done/
  - [x] terminal: bare :terminal opens pwsh on Windows, bash on Linux (80c8fa1); idle shells under a 'shell'
        wrapper saved in sessions (140ed09); `<S-Insert>` sends `<C-v>` to pwsh terminals (df0a668)
  - [x] cmdline: `<Up>`/`<Down>` history until a menu walk, no preselect (fc6cd99); `<C-BS>` deletes a word (8351d8f);
        `<M-j>`/`<M-k>` walk the menu (aa7cdc5); `<M-f>` previous, `<M-w>` first, `<M-s>` 3 down (9693171);
        no menu on one-char commands, :w`<CR>` map dropped (c655f23)
  - [x] minuet: answers only `<M-y>` unless blink auto-complete is on (6dead7f); qwen2.5-coder, all providers,
        keys from gitignored local/secrets.lua (3e90c60, 6122927); :CheckHealthSimpleMinuet (3e5a645);
        Codestral by default (a300cea); provider guide doc-wip/readme.minuet-providers.md (0c3e3a3)
  - [x] :HiInspect shows highlight groups under the cursor (17dceca); :CheckHealthLspSimple renamed
        :CheckHealthSimpleLsp (7d43221)
  - [x] completion doc window: menu colours, rounded frame, padding (29e8c26, 08a6f5c, 7390836)
  - [x] lint: runs cancelled by nvim-lint no longer reported as exit code 1 (cd4a0ab)
  - [x] tests: gopls go-list warmup (a3f049a), make timings slowest last (cd57bdf), mason linters installed (ef9867a),
        llm dir with minuet `<M-y>` (ae71dd3), telescope key help (48936c2), lint md-mixed (3d74e10)
  - [x] ecolog: ecolog2 with ecolog-lsp, else ecolog.nvim v1 (d7842a2, ca842c0)
  - [x] copilot.vim and llm.nvim shelved, keys commented out (18ed193, 1185287)
  - [x] oil: :Lexplore works again (e7b8ece); telescope key help in insert mode without n maps (48936c2)
  - [x] markdown: gq wraps checkbox items under the text (58538ea); md-fix follows editorconfig sections (aeab075)
  - [x] diag-align toggle on `<leader>tta` and in `<F2>` (27648c7); right-click paste search with a picked provider (fa42e84);
        diagnostic virtual text and link colours (698b3a6)

- [x] extras outside the idea list (2026-11-02)
  - [x] lint: `<leader>cx` turns the markdownlint/vale rule under the cursor off (01f7cda)
  - [x] tests: copilot case skips without copilot.vim in lazy (9244bc1)

- [x] extras outside the idea list (2026-11-03)
  - [x] :Ct starts claude in the current window (3911a0b)
  - [x] ~ cycles markdown checkbox states blank x n . ~ (c773959); ]j [j / ]y [y jump to open checkboxes (70a20a1)
  - [x] tests: yellow NOTE lines, shorter case path (9bebc59)
  - [x] Makefile.lazy.mk: update-treesitter a prerequisite of update/sync again (3480b0d)
  - [x] mason: cut-off installs repair themselves on open, make kills lua_ls first, lua_ls logs to stdpath('log') (eef2590)
  - [x] hilite: muted diagnostic underline and virtual text (65812bb); `<leader>`' opens oldfiles (5c637f8)

- [x] diagnostics: `<leader>ttt` disables all diagnostics (LSP, nvim-lint: vale, gitleaks, ...) and toggles them back on
  - today: lua/genja/map-lsp.lua toggle_diagnostics, `vim.diagnostic.enable(not vim.diagnostic.is_enabled())`
  - check that every source goes away and comes back, also in buffers opened while off
  - 2026-11-02: already works: enable(false) without a filter covers every namespace and later buffers
  - [x] zen z1/z2 turn diagnostics off; z0 turns them on again (unless off before zen) with the limit of 3; untested (333bf79)
  - [x] `<leader>ttt` in every buffer, not only after LspAttach; `<leader>tt3` the limit of 3; tested (b829ae5)

- [x] lint: :ValeSync runs by itself when the shared styles are missing (asked 2026-10-31)
  - today vale is skipped until :ValeSync (lua/genja/ext/lint.lua prepare_vale), no hint that it's off
  - 2026-11-02: the first lint without styles starts the sync once per session, then lints all buffers again; untested (1c67fc5)

- [x] abbrev: /FAIL`<CR>` searches for "/FAIL`<C-]><CR>`" (literal text, no search)
  - source: lua/genja/abbreviations.vim:38, the cmdline `<CR>` map returns the single-quoted string `'<C-]><CR>'` for every cmdtype but `:`; in an `<expr>` map the <> is typed literally, and the Vim-only `<C-]>` is only needed for `:` abbreviations (a3e07a3, 80c8fa1)
  - fix: only `:` gets the `<C-]>` prefix, other cmdtypes return `"\<CR>"` (double quotes, real key), or no map at all for `/` `?`
  - test: `/FAIL<CR>`, `?FAIL<CR>`, `:s/a/b/<CR>`, `jj`, `g` still work
  - 2026-11-02: fixed (abbreviations.vim: `"\<CR>"` for non-`:`); `/FAIL<CR>` tested by hand, the rest of the test list open (82cd9a4)

- [x] completion: blink cmdline completion of shell commands (`!cmd`, `:terminal cmd`) is very slow
  - today: blink cmdline source in plug-wip/genja-completion011.nvim/lua/genja/completion/cmdline.lua; shell names come from getcompletion(..., 'shellcmd') = $PATH scan on every keypress (inferred, not profiled)
  - upstream: blink recipe turns cmdline completion off for `:!` and `:%!` only, because Git Bash or WSL hang (<https://cmp.saghen.dev/recipes>); feature request to ignore commands in the cmdline source, not resolved in the results (<https://github.com/saghen/blink.cmp/issues/1029>); Neovim docs: shell command names come from $PATH (:h cmdline-completion)
  - no PATH cache found upstream in Neovim or blink; a cache would be ours
  - try: profile first (time getcompletion('', 'shellcmd') on this PATH); then cache the list in Lua, rebuild on PATH change or after 3 h, serve it from the cmdline source for `!` and `:terminal`; or drop shellcmd for `!` as the recipe does
  - test: `!` then letters, `:terminal` then letters: menu appears within a keypress
  - 2026-11-02: written: lua/genja/completion/shellcmd.lua, list in stdpath('state')/genja-completion011/shellcmd.txt, rebuilt after 3 h or on PATH change; `!word`, `:term word` and `:vert term word`; tests/completion/test_cmdline.lua: PATH-change rebuild and `:vert term` pass (make test D=completion); the 3 h age rebuild is untested (abfb666); :ResetPathCache deletes the list

- [ ] zen modes: switch between layouts by task (not thought through yet, 2026-11-05)
  - z1: only the code
  - z2 (or a new key): digging, debugging, jumping around code: sidebars (aerial), dropbar and the like shown
  - today: lua/genja/map-plugin/zenmode.lua, z1 width 120, z2 width 80 + relnum + maximized, z0 off; both hide diagnostics
  - open: keep z1/z2 as they are and add z3 for the debug layout, or redefine z2?
  - decided 2026-11-05 (todo-test/php-debug.md): z1 reading and prose (usable for anything);
    z2 some UI: limited diagnostics, max-width line; z3 UI heavy, debug panes as splits in the z3 view
    (not a separate tab; outside z3 the debug tab default stays).
  - open questions 2026-11-05 (parked by user): zen-mode's float hides other windows, so z3 can't
    hold debug splits beside it.
    1. z3 = no zen float, maximized, number + relnum, colorcolumn, all diagnostics, debug UI as splits in the current tab?
    2. z3 debug UI: dap-ui or dap-view?
    3. z3 opens the debug UI at once, or on the first stop (as splits)?
    4. z2 today turns diagnostics off; change to diagnostics on with the limit?
  - [x] z0 restores the window size in nvim-qt: a wait between frameless and maximize (98aa8a4)

- [ ] PHP project out of the box (goal in CLAUDE.md ## Goal, 2026-11-05)
  - examples: Drupal site; Symfony app with a React front end; custom app with Behat
  - gaps add: React side (jsx/tsx, eslint, a JS test runner)
  - have: phpactor in WSL (completion, diagnostics, refactors), framework detection WordPress/Laravel/Symfony,
    phpstan/php-cs-fixer/phpcs/pint from vendor/bin (plug-wip/genja-completion011.nvim/lua/genja/lang/php.lua),
    laravel-ls + blade-nav (lua/lazyp/langs/php-laravel.lua), neotest pest/phpunit (php-neotest.lua),
    overseer php_test template, emmet, typescript lang module, treesitter html/php/phpdoc/blade/js/ts/json/yaml
  - gaps (from a grep, not tested): no treesitter css/scss/twig; no CSS or HTML LSP, no eslint/stylelint/biome;
    no twig (Symfony, Drupal); no Behat runner; Drupal not detected; composer.json / package.json scripts not offered as tasks (check overseer)
  - [x] auto-todo 2026-11-05 (guides doc-wip/readme.2026-11-05.*.md, all untested):
        parsers css scss twig jsdoc regex (9a8aa25, need a C compiler: winget install LLVM.LLVM);
        cssls + html lang modules (c18994b, 0ed9ee4); eslint + stylelint with a project config (e7bad3d);
        Drupal: phpactor indexes .module etc., ft mapping, drupal-check (236948c, dbc21f8);
        `<F2>` composer/npm scripts (bac05c1); Behat overseer template via ddev in WSL (23d563c)
    - [x] `<F2>` scripts: automated test, fixtures tests/f2/eff-two/, :OverseerToggle (5fe22f0)
  - [x] React side: a JS test runner (vitest / jest through neotest), not decided yet
    - [x] both, picked by the project's config file (vitest wins), lua/lazyp/langs/php-neotest.lua (2026-11-10); untested

- [ ] Go project out of the box, same feel as PHP (after PHP, 2026-11-05)
  - have: gopls (plug-wip/genja-completion011.nvim/lua/genja/lang/go.lua: go.work roots, organize imports + format on save,
    code lenses on `<leader>cl`), go.nvim with dap (lua/lazyp/langs/go.lua), treesitter go
  - gaps (from a grep, not tested): golangci-lint not in lua/genja/ext/lint.lua; treesitter gomod/gosum/gotmpl;
    templ, sql, proto, Dockerfile parsers; tests through neotest-golang or go.nvim (decide one)
  - [x] auto-todo 2026-11-05 (untested): parsers gomod gosum gotmpl (9a8aa25); golangci-lint only with a
        .golangci.*file, sample examples/go/.golangci.toml (e7bad3d); neotest-golang, go.nvim's :GoTest* kept (1037aa2)
  - [x] parsers templ, sql, proto, dockerfile: templ and proto in load-treesitter.lua (2026-11-10);
        sql on PR-langs, dockerfile on PR-wsl-docker; untested

- [ ] nvim as the interface to the OS for coding work: shell, terminal, pwsh, Git Bash, git (2026-11-05)
  - today: floaterm commands (:PwshFterm, :BashFterm, :LazygitFterm), toggleterm, :terminal pwsh/bash, Neogit, mini.git
  - open: which simple tasks still make you leave nvim?

- [ ] control WSL instances and Docker containers from nvim (2026-11-05)
  - today: only phpactor's wsl.exe calls (lang/php.lua); nothing for listing/starting/stopping distros or containers
  - ideas: picker for `wsl -l -v` (start, terminate, shell into, set default with confirmation);
    picker for docker ps/images/compose (logs, exec shell, restart); check existing plugins first

- [ ] Kubernetes YAML: write manifests with the spec at hand, started before 2027, alongside the LLM chat survey (2026-11-05)
  - test project: ~/es/k8s-minikube-ci in its own WSL distro minikube (AlmaLinux 10; written in alma first, copied by make seed), Windows wrapper C:/Users/jazzo/es/k8s-minikube-ci (Minikube + Tekton CI; phases add git server, ingress, autoscaling;
  - the distro is disposable: source, configs and CI state live on the host, synced in (to do in the project)
    each component is one whose docs genja should fetch); nothing run yet, minikube/kubectl/docker not installed
  - options while writing a manifest, look things up from inside the editor, no browsing the spec
  - values depend on the components in use (router X, ingress Y, autoscaler Z): pull their docs into
    stdpath('data') and show them through familiar interfaces: generated :help files (a help subfolder,
    maybe per project), K hover, or a popup
  - today: no yamlls, no schemas (grep: only old/unused specs); lua/genja/ft/yaml.lua maps yml -> yaml.ansible
  - ideas: yamlls + schemastore + kubernetes schemas (CRD schemas per component, e.g. datreeio/CRDs-catalog);
    helm/kustomize files; docs fetched per component into stdpath('data'), turned into vim help; check existing plugins first
  - more languages found missing (terraform, helm, alloy, promql, sql, toml, systemd, parsers, linters): todo-ideas/grafana-k8s-terraform-langs.md (2026-11-07)

- [ ] LLM chat in a buffer, like the browser chat (2026-11-05; an idea, to be fleshed out)
  - open a buffer, ask; it thinks, appends the answer; type a follow-up below it, the next answer is appended; one running conversation
  - maybe a separate input buffer (simpler), but questions and answers live in the chat buffer
  - folds: questions close automatically as folds; responses can be closed by hand when needed
  - likely an extension of the genja-ask popup (plug-wip/genja-ask.nvim)
  - survey session, test steps and questions: todo-test/llm-chat-survey.md
  - first: survey existing chat plugins (codecompanion, avante, gp.nvim, parrot, others); use one only if its interface fits
    the mental model above; otherwise build our own and take the ideas that work (what to do, what to avoid)
  - any provider, not tied to ChatGPT
  - today: codecompanion.nvim chat with Claude Code over ACP (lua/lazyp/langs-comps/codecompanion.lua,
    doc-wip/readme.idea19-companion.md) already works this way; genja-ask popup is one question, one answer;
    minuet covers ghost text. Find out what's missing in codecompanion before building one

- [ ] PHP debugging that works, part of v2026 (2026-11-05)
  - keep nvim-dap + nvim-dap-ui unless the UI test says otherwise; compare nvim-dap-view
  - PHP runs in DDEV inside WSL (weasel-ddev): Xdebug networking and pathMappings untested
  - session, gaps and questions: todo-test/php-debug.md
  - [x] dap-ui on the first stop in its own tab, `!` flips F1-F8, :DdevXdebugHost, :DebugCli / :DebugBehat,
        `<leader>dK` `dl` `dB` `dp` (17e6c2b); nvim-dap-view on `<leader>dv` (8f5b8d2); untested

- [ ] try the new diff viewers and their modes (2026-11-09; all untested)
  - diffview, set up plain: panels left/bottom, no icons or hints, `<leader>mGd` and F2 `diffview toggle mode` flip side by side / inline (`diff1_inline`),
    red left / green right (fold in lua/genja/hilite.lua, hook in lua/lazyp/git/diffview.lua), `diffopt` histogram (opt.lua), fillchars `diff: `
  - F2 in an oil buffer in a repo (lua/genja/f2/collect/git.lua): `diffview open` (FROM, TO pickers, `FROM...TO`),
    `codediff changes | branches | history | pr`
  - installed to compare, nothing mapped: unified.nvim (`:Unified`), deltaview.nvim (`:DeltaView [ref]`, `:Delta`, `:DeltaMenu[!]`),
    codediff.nvim (`:CodeDiff`; first use downloads its diff library: `:CodeDiff install`)
  - check: `:Lazy install`; `diff1_inline` and the hook colors exist in the installed diffview (`:h diffview.defaults`);
    `-C` / `--repo` flags in the codediff items; unified.nvim against a branch ref; which viewer replaces which (keep one or two)
  - research on sleek diffview configs: the subagent report of this session; alternatives not looked at: nvim.difftool, mini.diff, octo.nvim
