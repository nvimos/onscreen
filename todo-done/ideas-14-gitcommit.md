# Done 2026-11-05 (from todo-ideas.md; untested parts in doc-wip/untested.2026-11-05.md)

- [x] 14. gitcommit: plug-wip/genja-commit.nvim (details in its CLAUDE.md) (wip)
  - commit popup moved out of oil; :w keeps the draft in .git/COMMIT_EDITMSG
  - lint while typing: nvim-lint + gitlint, built-in Lua rules when Python/gitlint are missing
  - <M-g> writes the message from the staged diff (claude / copilot / gemini / aichat)
  - copilot ghost text in commit buffers, accept with <M-f> (copilot.vim moved to lua/lazyp/unused/ 2026-10-31: minuet won)
  - [x] gitcommit buffers: get commit-message help back without copilot.vim
    - [x] minuet: ghost text on by default in gitcommit (ft + auto_trigger_ft, lua/lazyp/langs-comps/minuet.lua); tested 2026-10-31 (f3db574)
    - [x] minuet in gitcommit suggests random text: it only sees the commit buffer, not the staged changes;
          feed it `git diff --cached` (e.g. a gitcommit-only prompt or context in minuet's provider options)
      - 2026-11-02: lua/genja/ext/minuet-diff.lua, diff below a scissors line in the FIM suffix / chat context;
            cached 10 s, cut at 4000 chars; untested (aa05687)
    - [x] claude -p as a minuet provider: minuet only has HTTP backends; a custom backend would start the CLI per request (slow)
      - closed 2026-11-05: won't do, the CLI start is too slow for ghost text; cheap prepaid models instead: todo-2027.md
    - [x] minuet `claude` provider (Anthropic API): not an option now (no API key); block commented out in minuet.lua
      - 2026-11-05: moved to todo-2027.md, compared there with the other prepaid models
    - [x] CLI tools: <M-g> backends (claude -p / copilot / gemini / aichat), also outside the popup
      - [x] shared backends, cli and http kinds: plug-wip/genja-util.nvim/lua/genja-util/llm.lua,
            used by genja-commit <M-g> and genja-ask (2026-11-02) (170a8ed, f2d5be3)
      - [x] copilot CLI: prompt piped, no -p (copilot ignores stdin with -p); untested, CLI not installed
      - [x] ollama backend, end point and model configurable, local by default; own http/cli backends
            via generate.backends; untested
      - [x] "also outside the popup": <M-g> already works in every gitcommit buffer; what else was meant?
        - closed 2026-11-05: nothing else; every gitcommit buffer is "outside the popup"
  - opt-in Conventional Commits mode; cmp offers types, scopes, footers
  - [x] commit message opens in a bottom split by default (2b0b316); untested
  - commits: 64baa3b, 3d5dc8c, e02ab60, fdc634c
