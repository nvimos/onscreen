from: todo-ideas.md

- [x] 19. claude: from nvim
    - [x] prettier winbar names: `claude-ft «<session title>»`, else the cwd basename (bfd6eef)
    - [x] :ClaudeFterm [flags]: --chrome, --model, --effort, ... at start, <Tab> completes (55240fa)
    - [x] terminal keys: <C-Left> window on the left (4e79669), <C-Right> next tab (4a917a0)
        - [x] <M-]>/<M-[> next/previous tab (af9c7a4), <M-{> previous window (6a4c414)
    - [x] :DevReloadClaude drops the cached claude modules; :F2Reload renamed :DevReloadF2 (bab761a)
    - [x] prompt popup: bigger, placed up-left (55140b2); <C-CR> sends, <CR> adds a newline (96562ed)
    - [x] claude's exit closes the window itself, not floaterm's autoclose (E444 on the last window) (14cd1f8)
    - [x] <C-Up> in the claude terminal: normal mode (45c94fe)
    - [x] moved into plug-wip/genja-ask.nvim and plug-wip/genja-claudefterm.nvim; floaterm options
      from setup(), so every start opens the vsplit (6ebff35)
    - [x] keys: <leader>pc ask popup, <leader>pC paste context, <leader>mC running terminals (7452969)
    - [x] <F2> claude source: one item per running claude terminal (4f57a26)
    - [x] :ClaudeFterm -1 / -one: claude replaces the current buffer, :ClaudeFterm or /exit
      brings it back; tested (1d15d43)
    - [x] talk to claude desktop or claude from nvim
        -[x] claude in float term for now. using claude.exe
    - need to work out a spec
        - [x] resume sessions based on commentstring
            - [-] also if started from an oil buffer?
                - no. no need for now
        - [x] one claude float term per project?
            - [-] or use the <- session manager inside claude?
            - decided 2026-10-23: one floaterm per project root (marker cwd, git root, cwd),
              plus a picker of running ones: <leader>pt (<leader>pl is Perplexity), :ClaudeFterm!
              (<CR> show, <M-d> kill); untested, doc-wip/readme.2026-10-23.claude-per-project.md (80f96ba)
    - [x] claude in a floaterm, :ClaudeFterm, <leader>pc paste context (lua/genja/claude.lua);
        - the pasting is WIP, need to work out / test out a spec
        - [x] <L>pC opens a modal but the ability to paste to claudefterm is gone. map it to <m-p> for now
            - <M-p> in the ask popup sends to the claude floaterm, whatever the target (2026-10-24)
        - [x] otherwise mark as untested: <leader>pc, doc-wip/untested.2026-10-24.md
    - session marker: /rename in claude writes `claude-session: <uuid> <title>`
      into the buffer claude was started from; :ClaudeFterm from that file resumes the session
        - not sure if this is a fantastic idea
            - can accumulate context
            - convenient for restarting nvim
            - the commentstring can have enabled:false which can be toggled manually
            - for txt files, just put the markers at the bottom with !! as prefix
        - works for files
        - resume does not work if opened from oil
            - because there are no commentstrings to put the session marker
            - this is ok
    - tested 2026-10-24: <leader>pc/<M-p>, <leader>pC by hand; per project, picker, paste, send,
      session markers: unit tests tests/claudefterm/ (63800da)
    - follow-up: #39 session marker toggle and txt markers (todo-ideas.md)
