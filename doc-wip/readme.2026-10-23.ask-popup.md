# Ask popup (#16)

What: one quick question from anywhere, a short plain-text answer in the
same float. Several targets; claude-p is your pwsh `claude-p` in Lua.

Files: `lua/genja/ask.lua` (popup, sessions, log), backends in
`lua/genja/ask/backends/` (`claude_p.lua`, `floaterm.lua`, `cli.lua` for
gemini/copilot/aichat), key `<M-?>` in `plugin/ask.lua`, `<leader>pc` in
`plugin/claude-fterm.lua`. The old popup in `claude.lua` is gone;
`claude.lua` keeps `send()` for the floaterm target.

## Keys

| Where | Key | Does |
|-------|-----|------|
| n, i, x | `<M-?>`, `<leader>pc` (n, x) | open; visual sends the selection (`path:lines` + code) along |
| compose | `<C-CR>` | send |
| compose | `<S-CR>`, `<C-j>` | newline |
| compose | `<C-p>` / `<C-n>` | history |
| compose | `<C-b>` | brief: at most 3 sentences |
| compose | `<M-t>` | target: claude-p → floaterm → gemini → copilot → aichat |
| compose | `<M-m>` / `<M-e>` | model (haiku, sonnet, opus) / effort (low, medium, high) |
| compose | `<M-s>` | save the session as `nvim yyyy.ww.d-ddd.hhmm` |
| compose | `<M-r>` | resume a saved `nvim ...` session (picker; needs rg) |
| compose (normal) | `q`, `<Esc>` | close, draft kept |
| waiting | `<C-c>` | cancel |
| answer | `<CR>` | follow-up in the same session |
| answer | `y` | yank the answer (`"` and `+`) |
| answer | `q`, `<Esc>` | close |

Title: `claude-p · haiku · low [brief] [nvim 2026.43.5-fri.2204] [follow-up]`.

## Targets

- **claude-p**: `claude --print --append-system-prompt <terse plain text,
  80 cols> --model --effort`, prompt on stdin, cwd = git root. First question
  `--session-id <new>`, follow-ups `--resume`; `-n <name>` after `<M-s>`.
  Unlike pwsh claude-p, unsaved sessions are persisted too (follow-ups need
  them).
- **floaterm**: pastes into this project's claude terminal and submits; the
  popup closes, the answer shows in the terminal.
- **gemini / copilot / aichat**: one-shot, flags as in genja-commit; no
  sessions, so a follow-up sends the earlier Q&A along. gemini and copilot
  are untested there too.

Every Q&A is appended to `~/.claude/p-logs/nvim.log` (same format as the
pwsh logs).

## Try it

1. `<M-?>` in normal mode, type `what does :h 'so' do`, `<C-CR>`: wait, the
   answer replaces the prompt in the float.
2. `y`, paste somewhere: the answer.
3. `<CR>`, type `and siso?`, `<C-CR>`: the answer knows the context.
4. `<M-?>`, `<M-m>` twice: title shows opus; `<M-e>`: medium.
5. `<M-s>`, ask something: `claude-p -s list` in pwsh won't show it (that
   filters `pwsh ...`), but `<M-r>` in the popup lists it.
6. Visual-select a function, `<M-?>`, ask `explain`: the title shows
   `+ path:lines`.
7. `<M-t>` to floaterm, ask: the claude terminal gets the question.
8. Check `~/.claude/p-logs/nvim.log`.

Checked by Claude: headless test with a fake backend: model cycling, the
answer replacing the prompt, `y` yank, `<CR>` follow-up with `resume=true`,
the session name format (`2026.43.5-fri.2204`). Fixed on the way: `<CR>` as
an expr mapping couldn't change the buffer (E565). Not run: real claude,
gemini, copilot, aichat; `<M-r>`; the floaterm target; `-n` together with
`--resume` (whether claude renames a resumed session is unchecked).
