from: todo-ideas.md

- [x] 16. <m-?>:  popup with ai chat to ask some random question. (done 2026-10-23, untested: doc-wip/readme.2026-10-23.ask-popup.md)
    - output should be mega brief and text-only (no markdown)
    - need to work out a spec
        - see what other people are doing for ideas
    - so far: <leader>pC prompt popup in lua/genja/claude.lua, sends to the claude floaterm (#19)
    - [x] decouple the popup from the claude floaterm
    - [x] send to multiple backends: a multi-agent simple prompt plugin
    - [x] first backend: the claude -p pwsh function; reconsider it, rewrite it in lua as the first cli backend
    - [x] <M-…> keys in the popup to pick: where to send the prompt, model, effort (each with a default)
    - spec 2026-10-23 (details: doc-wip/squash-ideas-oct-17.details.md #16)
        - code in lua/genja/ask.lua + lua/genja/ask/backends/ (move to plug-wip later)
        - <M-?> opens it (n, i, v: selection goes along), <leader>pC alias
        - in the popup: <M-t> target, <M-m> model, <M-e> effort, <M-s> save session
            - also <M-r> resume a saved session (picker)
        - backends: claude -p, the claude floaterm, gemini / copilot / aichat
        - answer in the same float: q/<Esc> close, y yank, <CR> follow-up; log to ~/.claude/p-logs/nvim.log
        - claude.lua's old popup removed; claude.lua keeps send() for the floaterm target
