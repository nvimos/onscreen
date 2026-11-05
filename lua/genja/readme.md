# Neovim setup

## Files

maybe separate plugin

     log.lua       - write errors to a file, maybe separate plugin
     fn.lua      - functions in general, maybe a separate plugin
     fu-test.lua - nicify movie-dir names (for searching imdb, etc)

init / boot

     boot - init lazy vim
     init.lua    - Safeload the rest, mapleader, colorscheme, font(?)
     local/      - per-machine files, gitignored: startdirs.txt (plug-wip/genja-startdirs.nvim); example next to it
     lazy-spec.lua - pluginspec imports and array
     plug-wip.lua - Wip.dir(folder): a plug-wip spec loads the local checkout when present, else its tox2ik/<repo> on GitHub

config

     auto.lua    - autocmds in lua
     ext/intro.lua   - startup intro screen without the charity lines (virtual lines, from auto.lua)
     opt.lua     - neovim configuration
     ext/term.lua - terminal-mode cursor: bar (default), StatusLine orange; :TermCursorShape bar|block; scrolloff 0 in terminal windows; a bare :terminal opens pwsh (Windows) or bash (Linux), 'shell' unchanged
     env.lua     - shell vars
     ft.lua      - filetype settings, maybe merge with something

custom funcs

     ext/actions.lua - g. / <LocalLeader>/ action menu (telescope), cur: = item under cursor
     ext/        - feature modules, one file each (the ext/ entries in this list)
     api.lua     - source from other config lua scripts
     oil/        - functions for nvim-oil, by topic; oil/init.lua lists the files, oil/plug/ holds the self-contained ones
     oil-actions.lua - oil actions (desc + callback), used by map-oil.lua
     f2/         - <F2> context picker: init.lua (sources, sorting, add_tasks/add_task/remove_tasks API), picker.lua (shared dropdown: main list and make targets), collect/: the sources, one per file, each with collect(ctx, done) (adhoc, git (oil only), make, claude, gui, diag, messages, lang); registry.lua stores added tasks; builder.lua is the add_task builder; run.lua runs keys/functions/commands (overseer, floaterm); readme.md: conventions (groups ≤ 6 chars, `group  label` alignment); Makefile + readme.testing.md: tests in tests/f2/
     ext/debug-ui.lua - dap-ui opens on a session's first stop, in its own tab or the current one (g:genja_debug_auto_open, g:genja_debug_layout); closes at the end
     ext/debug-fkeys.lua - during a debug session `!` flips F1-F8 between debug actions and their own maps
     ext/debug-ddev.lua - DDEV in WSL: warn when xdebug_ide_location isn't the Windows IP; :DdevXdebugHost sets it; :DebugCli, :DebugBehat run in the container under the debugger
     ext/md-glow.lua - <F2> in markdown: glow preview of the file in a new pwsh window (Windows only)
     ext/messages.lua - :Messages -dump/-quick/-loc (plugin/messages.lua) and <F2> messages: file:line from :messages (tests: tests/messages/)
     ext/messages-capture.lua - NOT ACTIVE: records vim.notify WARN+ with tracebacks; ideas and how others do it in its header
     ext/md-fix.lua - markdown fixers: <leader>mfx and on save (tabs to spaces, or to tabs when an editorconfig section for markdown says indent_style = tab; vim keys in backticks, typos, markdownlint-cli2 --fix), vim.g.md_fix_on_save, toggled by <leader>tm / :ToggleMarkdownFix (plugin/md-fix.lua)
     ext/md-abbrev.lua, ext/md-abbrev.txt - markdown insert-mode abbreviations, one `wrong right` pair per line (tests: tests/md/)
     fu.lua      - user functions (lua) :UserFunction
     hilite.lua  - colors, ui, syntax (lua)
     ext/hi-inspect.lua - :HiInspect (plugin/hi-inspect.lua): highlight groups under the cursor in a split, with link chains and final colours; q closes
     ext/minuet-status.lua - :CheckHealthSimpleMinuet (plugin/minuet-status.lua): minuet provider, model, whether the API key is set, ollama server, a fixed test request and frontends in a float; q closes
     ext/secrets.lua - LocalOrEnv(name): API key from the gitignored local/secrets.lua, else the environment
     ext/ui-select.lua - vim.ui.select in a telescope dropdown (code actions etc.)
     ext/md-checklist.lua - <F2> in markdown: lines to a checklist and back
     ext/tilde.lua - ~ toggles true/false, on/off, +/- … under the cursor
     ext/winsize.lua - window sizes in big steps, share cycle, resize mode
     ext/unsaved.lua - :Unsaved [cmd]: picker of modified buffers (write / discard), then cmd; :qa, :q, :x, jj, s: go through it
     ext/wrapfold.lua - fold markers with a title, :WrapFold
     completion/minuet.lua - blink.cmp feature 'minuet' for genja-completion011: minuet-ai source, <M-y> asks it
     ext/rename-inline.lua - LSP rename typed in a float over the word (grn, <leader>c2, right-click)
     ui/gui-func-state.lua - nvim-qt shim state: M.Gui<Name>() returns one singleton per Gui* function (:advance, :set, :text); used by the GuiFuncs picker, <leader>mQ keys, right-click frameless

mappings and funcs for them

     fn-keys.lua - custom functions for bound keys
     map-convoluted.lua - keymaps, hard to grok
     map-jolemak.lua    - keymaps, custom layout quirks
     map-lsp.lua        - keymaps, code-actions, diagnostics navigation
     map-oil.lua        - keymaps, oil buffers: key -> oil-actions; which-key groups
     map-plugin/        - keymaps for lazy specs: init.lua (registry, looked up by spec file name), <spec name>.lua (keys + keymap functions), health.lua (:checkhealth genja.map-plugin); Makefile: tests in tests/map-plugin/
     map-telescope.lua  - keymaps, telescope actions, shortcuts
     map-telescope/fn.lua - functions bound in map-telescope.lua
     ext/morning.lua - :Morning page: start dirs, recent files, todo items, untested lines (click opens)
     ext/popup-menu.lua - right-click entries per filetype (markdown, oil, LSP), paste search on a selection, Morning; on MenuPopup
     ext/recent.lua - <C-F1> picker for genja-recent (frecency), project first, <M-a> all
     ext/diag-limit.lua - draws only the first 3 diagnostics per severity and buffer (vim.g.diag_limit, <leader>tt3 in plugin/diag-limit.lua; tests: tests/ui/test_diagnostics-limit.lua)
     ext/diag-align.lua - diagnostic virtual text starts in one column per paragraph, after its longest line (vim.g.diag_align = false: end of line; plugin/diag-align.lua)
     ext/lint.lua - nvim-lint linters per filetype (markdown, yaml, ansible via WSL, lua, make, php, workflows, dockerfile, python, vale for markdown (shared lint/.vale.ini, :ValeSync, run by itself once when the styles are missing); editorconfig-checker and gitleaks on all)
     ext/lint-silence.lua - <leader>cx in markdown: the markdownlint/vale rule under the cursor off in its config, with a dated comment
     ext/minuet-diff.lua - minuet in gitcommit buffers: the staged diff goes along with each request (FIM suffix, chat context)
     ext/telescope-virthelp.lua - prototype: key help table in the empty results of every picker (plugin/telescope-virthelp.lua); the footer was removed
     ext/telescope-keymaps.lua - telescope keymaps with refine keys and <M-r> desc group rotation (tests: tests/telescope-keymaps/)
     map-zero.lua       - keymaps, essential that must not fail

meta, random

     readme.discovery.md - stuff to checkout related to neovim config, plugins
     zexp.lua            - experiments


Vimscript

     vimrc.almalinux.vim - almalinux solid config
     hilite.vim          - colors, syntax, ui
     fn.vim              - user functions
     auto-alias.vim      - aucmds, shorthand commands, :com-aliases


## Oil: hiding entries with .oily

Moved to `plug-wip/genja-oily.nvim` (README.md there). oil shows a folder:
the nearest `.oily` in it or up the tree applies, child folders included.
Wired up in `lua/lazyp/explorer/oil.lua` (`is_hidden_file`, `<LocalLeader>M`).
