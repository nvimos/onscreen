# list of improvements to nvim

## related files

squash ideas details and estimations

    ./doc-wip/squash-ideas-oct-17.md
    ./doc-wip/squash-ideas-oct-17.details.md

future work (need to limit the neovim-2026 project)

    ./todo-2027.md

migration from 0.9 to 0.11 (the file that started it all)

    ./todo-2026-neovim011.md

## ideas october

- [~] 14. gitcommit: plug-wip/genja-commit.nvim (details in its CLAUDE.md) (wip)
  - commit popup moved out of oil; :w keeps the draft in .git/COMMIT_EDITMSG
  - lint while typing: nvim-lint + gitlint, built-in Lua rules when Python/gitlint are missing
  - <M-g> writes the message from the staged diff (claude / copilot / gemini / aichat)
  - copilot ghost text in commit buffers, accept with <M-f> (copilot.vim moved to lua/lazyp/unused/ 2026-10-31: minuet won)
  - [~] gitcommit buffers: get commit-message help back without copilot.vim
    - [x] minuet: ghost text on by default in gitcommit (ft + auto_trigger_ft, lua/lazyp/langs-comps/minuet.lua); tested 2026-10-31
    - [ ] minuet in gitcommit suggests random text: it only sees the commit buffer, not the staged changes;
          feed it `git diff --cached` (e.g. a gitcommit-only prompt or context in minuet's provider options)
    - [ ] claude -p as a minuet provider: minuet only has HTTP backends; a custom backend would start the CLI per request (slow)
    - [ ] minuet `claude` provider (Anthropic API): not an option now (no API key); block commented out in minuet.lua
    - [ ] CLI tools: <M-g> backends (claude -p / copilot / gemini / aichat), also outside the popup
  - opt-in Conventional Commits mode; cmp offers types, scopes, footers
  - commits: 64baa3b, 3d5dc8c, e02ab60, fdc634c

- [x] extras outside the idea list (2026-10-23)
  - [x] winbar: quickfix windows show w:quickfix_title, no duplicate %q (6f29b37)
  - [x] map-telescope: helpers in fn.lua; <leader>jj1/jj2 quickfix/loclist, genja grep/find on jjJ/jjj,
          builtins under <leader>jb (6aa5a7b); which-key groups <leader>j. and <leader>j/ (73c4c3b)
  - [x] focus.nvim: vim.g.focus_disable, so <C-w>= sticks; <leader>tPf can turn it on (28c80c0)
  - [x] every vim.notify names its file through a SRC prefix (2aadf61)
  - [x] mylunsj lists Telescope mydirs first (1151dfb)
  - [x] cmdline completion: <Tab>/<S-Tab> next/previous, <Up>/<Down> pick while the menu is open (b5173ad)

- [x] extras outside the idea list (2026-10-24)
  - [x] cmdline: <C-j>/<C-k> pick items, <Up>/<Down> back to history (0de4d52)
  - [x] map-lsp: descs for nvim 0.11 gr* defaults, references on gR, [d ]d go the way their descs say (5e788aa)
  - [x] markdown: <F2> glow preview in a new pwsh window, Windows only (21cfe96)
  - [x] intro: eob ~ drawn in column 0 like vanilla (81a4659)
  - [x] gui: nvim-qt toggles on <leader>mQ…, GuiFuncs picker (<F3>, <F2> gui), right-click frameless,
          one shared state per Gui* function; neovim-gui-shim on again; tested (3580a06, ad94a79)
  - [x] edit: visual <leader>w, wraps lines as "line",; title case on <leader>wsT, sort paragraph <leader>wsp (8f25155)
  - [x] f2 git: <M-a> git adds the file, picker stays open (e6c04ac)
  - [x] hilite: darker Search/IncSearch/CurSearch background (a1b0857)
  - [x] startdirs: <M-1>…<M-4> jump by rank and don't count a use; :Mydirs picker,
          :Mydirs reset deletes the usage file; tested (1132d6b)

- [x] extras outside the idea list (2026-10-25)
  - [x] telescope keymaps: <M-r> after <M-f>/<M-x> cycles the groups of the refined list; tested (2debb3b)
  - [x] tests: map-plugin miss log and health (af13aed), claudefterm per project (63800da),
          comps011 lsp/cmp/lint with groups and timings (9f5f014); tests/Makefile runs every dir
  - [x] aerial: nav float 5% see-through (cbe6c13)
  - [x] gitsigns: <leader>mGs attaches skipped buffers again (e9e50f7)
  - [x] f2: groups of at most 6 chars, main list `group  label` in one column (5edddfa)
  - [x] floaterm: :PwshFterm (50e4b8a)
  - [x] mason: make mason-luals reinstalls lua-language-server headless (19d67f5)
  - [x] :ToggleDiagnostics for the current buffer (38e3d2d)
  - [x] f2 diag: hide excess undoes show all (620545d); pickers: matched chars in Visual fg, bold (00b05e5)
  - [x] genja-finder: <M-Up> rescans in the parent dir (93a8b69); <C-]> opens the entry, a dir entry itself (7bc4759, 31b74cd)
  - [x] statusline: [Nameless] for unnamed buffers (eddb6e5); telescope key footer dropped, key help kept (5c6e9a7)
  - [x] md: substitutions wrap vim key notation in backticks (c4d6b26)
  - [x] commit popup also on <leader>gcm and <leader>C (39dab59); <leader>ei tab-local from stdpath (7b05312)
  - [x] nvim-qt: nvim-qt.qss stylesheet, dark title bar note in ginit.vim (41e5bb6)

- [x] extras outside the idea list (2026-10-26)
  - [x] tests: pwsh Makefile, per-name groups, timings for every case, make gather/failed/plan/slow/status (8d2d86c)
  - [x] lua_ls: GENJA_LUA_NO_LIB=1 skips libraries, set by tests/Makefile (53642d0)
  - [x] :checkhealth genja.lsp: servers not installed, broken Python venvs, mason launchers (96b7910)
  - [x] bashls: mason's shellcheck.exe path on Windows (0bdc719); claudefterm kill() crash (0b46cfa)
  - [x] auto-todo round: shared checkmake.ini (9152813), <M-CR>/<C-s> submit popups (776f78a), telescope default keys
        and <C-/> descs (2f85171), claudefterm marker toggle and !! markers (a5ae869), f2 git staged picker (5e81cdf)
  - [x] statusline: plain separators in terminals, icons in GUI (487aec2); :Ct for :ClaudeFterm (9073fcb)
  - [x] guifont JetBrainsMono NFM 12 (ac41882); make mason-make reinstalls autotools_ls (170ba57)

- [x] extras outside the idea list (2026-10-27)
  - [x] blink.cmp replaces nvim-cmp, own sources on one source builder, blade-nav source (2d6b4bd, 00268c4);
        tests/completion: sources, keys, cmdline, <CR> (191c6cf, 55c1296)
  - [x] genja-util: shared centred float and text helpers; plug-wip plugins tidied (b34a1a8, f16695b)
  - [x] gen.nvim: ollama qwen3.5:0.8b prompt menu on <leader>ai (2bd7b6f)

- [x] extras outside the idea list (2026-10-28)
  - [x] LSP rename typed in a float over the word: grn, <leader>c2, right-click (527755d)
  - [x] :EnableLang turns a language on/off for the session, -save writes lsp/local.lua, <F2> offers it (03ce43e)
  - [x] completion menu colours from StatusLine (e45657e); cmdline <Down>/<Up> walk the menu, history without one (dbd3c64)
  - [x] terminal windows: scrolloff 0 (db72fa3); :help you page (b7337e9); <leader>ts toggles spelling (fda9e2e)
  - [x] colorscheme set in init.vim, Gui* settings grouped (6adb2ed); markdownlint MD012 off (ce73378)

- [x] extras outside the idea list (2026-10-29)
  - [x] ccc.nvim colour picker and highlighter: <leader>ic, <leader>tc (e26d31e)
  - [x] paste search: right-click on a selection (cbeef81); genja-paste-ai.nvim: :PasteSearch, :Wot,
        :Google / :Perplexity / :Xty, <F2> lookup, web and ai providers (80b9277, 5e70490, f9854f3)
  - [x] terminal keys, <C-`> floaterm toggle, sessions keep shells (f4675f6)
  - [x] md-fix: expand tabs, backtick vim keys, <leader>tm (420d58c; Lua port 893ff63); formatlistpat for checkboxes, footnotes (d69e644)
  - [x] diag-align: virtual text in one column per paragraph (5b579f9); diagnostic colours per severity (d778534);
        dim underline on markdown links (42d9f18)
  - [x] legendary: 0king fork, <leader>jl, in mylunsj (14a73da), bigger dropdown (b366920)
  - [x] :ClaudeFterm -ax passes --ax-screen-reader (0db2b57)
  - [x] which-key: helix preset, left-centred, fixed height (da8581b, 5eb0576, a143fca); test groups vs mappings (f7a9970)
  - [x] unsaved buffers picker before :qa, jj, s: (58316bd)

- [x] extras outside the idea list (2026-10-30)
  - [x] unsaved picker: layout, E13 overwrite prompt, :q and :x, tests (4ccf5bc)
  - [x] telescope: per-picker prompt hint via b:telescope_hint (bb164fe); :Messages -yank copies :messages (1270b29)
  - [x] abbrev: g quits via a <CR> map, :g/pat/ stays :global (a3e07a3)

- [x] extras outside the idea list (2026-10-31)
  - [x] netrw.nvim icons (c30c591); ghost text: minuet-ai.nvim and llm.nvim on ollama (d7d084f); both in todo-done/

- [ ] custom keymap logger: count which keys/binds I use more than others
  - legendary only counts palette picks (frecency needs sqlite.lua, off in lua/lazyp/new/legendary.lua)
  - plug-wip/abdul-keymaps.nvim has track_usage + :KeymapsStats, but it only records mode changes
    (n->c, c->n …); its per-keymap wrapper create_tracker() is never called (checked 2026-10-31)
  - plugins checked 2026-10-31, none fits: keystats.nvim (counts, needs cargo), stalker.nvim (motions only),
    tobira.nvim (teaching), vim-stats (Vim, Ex commands)
  - decided 2026-10-31: do both
  - [ ] finish create_tracker in the abdul-keymaps fork (plug-wip/abdul-keymaps.nvim/lua/keymaps/tracker.lua),
        so :KeymapsStats counts keymaps, not mode changes
  - [ ] build your own, no need for json. keep it lua-native
    - vim.on_key(), match typed keys against nvim_get_keymap() by lhs, count per mode:lhs (+ desc)
    - store as a Lua file returning a table (loadfile to read), in stdpath('state'), written on VimLeavePre
    - :KeyStats picker sorted by count

- [ ] diagnostics: <leader>ttt disables all diagnostics (LSP, nvim-lint: vale, gitleaks, ...) and toggles them back on
  - today: lua/genja/map-lsp.lua toggle_diagnostics, `vim.diagnostic.enable(not vim.diagnostic.is_enabled())`
  - check that every source goes away and comes back, also in buffers opened while off

- [ ] lint: :ValeSync runs by itself when the shared styles are missing (asked 2026-10-31)
  - today vale is skipped until :ValeSync (lua/genja/ext/lint.lua prepare_vale), no hint that it's off

- [ ] sessions: a saved shell comes back in its current dir, not the one it was started in (later, asked 2026-10-31)
  - lua/genja/ext/term.lua mksession: the term:// name keeps the start dir
  - which other terminals to save (e.g. `:terminal ssh a22`: reconnects on restore): needs more thought; only idle shells for now

- [ ] abbrev: /FAIL<CR> searches for "/FAIL<C-]><CR>" (literal text, no search)
  - source: lua/genja/abbreviations.vim:38, the cmdline <CR> map returns the single-quoted string `'<C-]><CR>'` for every cmdtype but `:`; in an <expr> map the <> is typed literally, and the Vim-only `<C-]>` is only needed for `:` abbreviations (a3e07a3, 80c8fa1)
  - fix: only `:` gets the <C-]> prefix, other cmdtypes return `"\<CR>"` (double quotes, real key), or no map at all for `/` `?`
  - test: `/FAIL<CR>`, `?FAIL<CR>`, `:s/a/b/<CR>`, `jj`, `g` still work
  - 2026-11-02: fixed (abbreviations.vim: `"\<CR>"` for non-`:`); `/FAIL<CR>` tested by hand, the rest of the test list open
