# Clean and update for neovim 0.11+

## new setup 2026

-[n] extract Mylunsj into a separate plugin


-[x] ai, llm, code generation (closed 2026-10-29: done in the code)
    -[x] integrate at leas one from online, free tier
        - gemini via genja-ask (plug-wip/genja-ask.nvim, backends/cli.lua)
    -[x] integrate ollama
        - gen.nvim (lua/lazyp/langs-comps/gen.lua), ollama http api
        - (maybe) via cli
        - (maybe) via http api
        - (maybe) via local sock
    -[x] integrate at least one
        - maybe hack some round-robin, auto retry util
        - maybe delegate to cli tools
        - genja-ask: claude -p, claudefterm, gemini, copilot, aichat
    -[x] auto-code-completion suggestions
        - copilot
        - gemini
        - copilot.vim (lua/lazyp/langs-comps/copilot.lua)
    -[x] chatbot
        - ask random questions
        - ask about current file
        - genja-ask popup (<M-?>), codecompanion chat

-[x] indexed file search: integrate everything search index
    - [x] use it per default if it's installed, fallback to fzf or whatever

- [x] look for an alternative shortcut-hint plugin
  - testing out legendary
  - [x] improve sorting and grouping of which-key
  - [x] make an automated test ui/which-groups
    - [x] tests/ui/test_which_groups.lua, both ways: empty groups, <leader> prefixes without a group (2026-10-29)
    - tests that all defined key groups appear with a prefix
    - warn if not, not failure. list the missing groups
  - which-key feels clunky
    - maybe look into a different layout mode
    - [x] preset helix; modern and a narrower classic commented out (2026-10-29)

-[x] only enable / install needed languages with a conservative set of defaults
    - [x] on-demand with :EnableLang -on -off -save
    - [x] per-environment with local settings file

-[x] migrate lsp, cmp config to neovim 0.11+ api
    - [x] ask claude to rewrite based on existing files
    - [x] make it modular or feature-per-file
    - [x] put essential functionality into separate files
        -[x] :help completion
        -[x] :commands completion
        -[x] lua lsp
        -[x] shell lsp
        -[ ] how to extract into minimal config?
            - first figure out what the minimal config is:
              try it in a bare WSL and in a Termux environment (not now)
    -[x] undo require(lspconfig).«lang».setup()
    -[x] migrate to vim.lsp.config and vim.lsp.enable
    -[x] fix: no completion menu while typing (cmp.setup() was never called)
-[x] evaluate completion engines other than nvim-cmp
    (notes: plug-wip/genja-completion011.nvim/README.md, "Alternatives to nvim-cmp")
    -[x] built-in: vim.lsp.completion.enable({ autotrigger = true }) / 'autocomplete'
        - is LSP-only enough? what about buffer words, paths, cmdline?
        - no it's not enough, maybe for some kind of minimalist setup
    -[x] blink.cmp
        - [x] port lua/genja/completion/* features
        - [x] compare speed and menu feel with nvim-cmp
          - some kinks with selection. mainly works fine
            can'd describe the issue yet. feels a bit off
            but works faster and it's more powerful

-[n] bootstrap core plugins with neovim
    -[x] lazy disables pack/ loading (vim.pkg.add)
        - ~/.local/share/nvim/site/pack/core/opt/ (Linux/macOS) (or under $XDG_DATA_HOME/nvim)
        - %LOCALAPPDATA%\nvim-data\site\pack\core\opt\ (Windows)
    -[x] plugin manager: stick with lazy
    -[x] move bootstrap to lua/lazy-boot.vim

-[x] look into generating a cheat-sheet from existing keys
    - ideally some logical patterns and rearrangement ideas should emerge
        - which key groups help with that
            - the ui is easier to read too
    -[x] should be a reference at a glance
    -[x] sudormrfbin/cheatsheet.nvim
        - no. the ui / interface sucked. abandon effort
        - abdul keymaps is much better. works as a modal with search
        - maybe save as custom help files -> cheatsheet.txt
        -[n] move the :CheatsheetGenerate snippet to lazy setup
        -[n] make the telescope ui first column wider
        -[n] adjust the script for more granular groups (first column)
        -[n] look into generating several cheatsheets
            -[n] one for lsp
            -[n] one for map-convoluted
            -[n] one for map-*
            -[n] add them to Mylunsj
    - consider exclude or include defaults
      - [x] done for folds to define the descriptions
      - toggle builtin keymaps?
        (in the cheatsheet, or the search ui)
          - must be manually redeclared. prob not worth it for all

-[x] open a browser and paste a query to perplexity
    -[x] move into plug-wip/genja-paste-ai.nvim
    -[x] add providers
      - [x] add gemini
      - [x] add manus
      - [x] add chatgpt
      - [x] add grok
      - gonna clutter ui if add them in the same way as the perplexity eff-two item and keybinds
      - should be a toggle-provider on the fly kind of config, via eff-two
        - provide user func :PasteSearch [-provider name] [-save]
          - set active provider for runtime session
          - optionally persist choice in plugin-spec setup function (clever / simple lua pattern)
      - the feature / module should be «paste to ai-search in browser», using {{provider}}
      - [x] done 2026-10-29: :PasteSearch (:Xty, :Pplx), <F2> lookup, -save to lua/genja/local/paste-ai.lua
          (doc-wip/readme.2026-10-29.paste-search.md)


## prep / clean

-[x] factor out statusline stuff into a separate plugin
    - [x] move old files
    - [ ] set up github repo
    - [ ] delete from home-nvim repo
    - not publishing yet: todo-2027.md, repos for the plug-wip plugins



## release v2026

Plan: CLAUDE.md ## Release 2026. Defined 2026-11-05.

v2026 is: neovim 0.11 LSP API, blink.cmp, lazy; the plug-wip plugins (finder, completion,
statusline, commit, ask, claudefterm, paste-ai, startdirs, recent, oily, splitpad, util,
abdul-keymaps fork); PHP (phpactor in WSL, frameworks, phpstan/php-cs-fixer/phpcs/pint, pest/phpunit);
Go (gopls, go.nvim); AI (ask popup, minuet ghost text, codecompanion, paste search);
the test suite with timings and the startup checks; README, goals, cheatsheet.

- [ ] 1. `make gather` in tests/ passes, slow cases too
- [x] 2. clean clone starts without warnings, startup below 1 s (tests/startup, f1951ca, 90814fb)
- [ ] 3. hand tests: todo-test/testink-now.md and the untested items in todo-ideas.md (all, or a must-pass subset: open)
- [x] 4. zen z0 doesn't restore the window size in nvim-qt: shipped as a known bug (2026-11-05)
- [ ] 5. docs: READMEs for genja-ask, genja-claudefterm, genja-paste-ai (v2026 or later: open); cheatsheet current
- [ ] 6. backlog: unfinished items to todo-2027.md (own keymap logger, claude -p minuet provider,
         statusline github repo, ...)
- [ ] 7. PHP debugging works in DDEV/WSL, UI chosen: todo-test/php-debug.md
- [ ] 8. Kubernetes YAML: schemas, component docs as :help / K / popup (next; test project k8s-minikube-ci)
- [ ] 9. LLM chat: survey first (todo-test/llm-chat-survey.md), then use one or build on genja-ask
- [ ] 10. zen layouts by task (z1 code only, a digging/debug layout)
- [ ] 11. aerial sidebar follows the file shown in the source window
- [~] 12. PHP gaps (auto-todo 2026-11-05 did all but a JS test runner, untested): css/scss/twig parsers, CSS/HTML LSP, eslint/stylelint, behat, drupal detection,
          composer/package.json scripts as tasks, React front end
- [x] 13. Go gaps: golangci-lint, gomod/gotmpl parsers, one test runner (auto-todo 2026-11-05, untested)
- [x] 14. C: navigate and explore without a build (f702825, untested)
- [x] 15. adding a language: one documented step (readme.add-a-language.md, 7b69862)
- [ ] 16. WSL and Docker control from nvim
- [x] 17. publish the other plug-wip plugins (done 2026-11-05: 12 repos on github.com/tox2ik, MIT, READMEs with lazy install;
          each plug-wip folder is its own checkout, ignored by the nvim repo, 2492965)
          - repos github.com/tox2ik/<folder name>, genja-util.nvim first; history kept with `git subtree split`
          - genja-completion011.nvim keeps its name inside the config (unique, visible); only its repo is
            tox2ik/genja-completion.nvim (spec: name = the folder name, url = the repo)
          - specs: local plug-wip dir when present, else the GitHub repo (as abdul-keymaps)
          - gh 2.103.3 installed (winget); needs `gh auth login` before repos can be created
- [ ] 18. release: merge v2026 into master when the checklist is done (2026-11-05: refactor-2026-sept merged
          into master, branches develop and v2026 made; CLAUDE.md ## Release 2026)

Release date: open (Monday 2026-11-09 was set before items 8-17 were added).

Known bugs shipped:
- zen z0 in nvim-qt: window stays maximized-sized (todo-test/testink-now.md, "Zen in nvim-qt")
