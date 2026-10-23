# «idea 19 companion»: codecompanion.nvim + Claude Code

Chat with Claude Code in an nvim buffer, through ACP (Agent Client Protocol).
Spec: `lua/lazyp/langs-comps/codecompanion.lua`. Not run or tested yet.

## Setup, once

- Claude Code is installed (`claude --version`).
- Install the ACP adapter for Claude Code:
  - `npm install -g @agentclientprotocol/claude-agent-acp`
  - check `claude-agent-acp` is on PATH (npm's global bin dir)
- Auth, pick one:
  - subscription: `claude setup-token`, authorise in the browser, then set the
    token as a user env var: `setx CLAUDE_CODE_OAUTH_TOKEN "<token>"`
  - API key: `setx ANTHROPIC_API_KEY "<key>"` (billed apart from the subscription)
- Restart the terminal and nvim, so the env var is seen.
- `:Lazy sync`, then `:checkhealth codecompanion`.
- Never put the token in the spec; the config is in git.

## Keys

- `<leader>ac` chat buffer on/off
- `<leader>aa` action palette; in visual mode it works on the selection
- In the chat buffer (normal mode):
  - `<CR>` or `<C-s>` send (insert mode: `<C-s>`)
  - `q` stop the running request
  - `<C-c>` close the chat
  - `gr` regenerate the last answer
  - `{` / `}` previous / next chat
  - `ga` switch adapter (e.g. ACP <-> HTTP) in the same chat
  - `?` all keys

## Context

- `#{buffer}` the current buffer; `#{buffers}` all of them
  - only these two stay in sync; other context is a snapshot
  - `gba` resend the full buffer each turn, `gbd` only the changes
- `/file` and other slash commands; `[File](path)` links attach a file
- `\` completes the agent's own commands; they show up a few seconds after
  the chat opens

## Quirks

- The agent brings its own tools, approvals and context handling: permission
  questions come from Claude Code, inside the chat.
- MCP servers run inside the agent; they don't show in the chat's context.
- `claude_code` has a `yolo` command that starts the agent with `--yolo`
  (no approvals). Avoid it outside throwaway work.
- A separate agent process: its sessions are not the ones in the floaterm
  (`:ClaudeFterm`, idea #19 A).
- Starting the agent takes a few seconds per chat.
- The inline assistant (`:CodeCompanion`) uses the inline adapter, not the
  chat one. The docs don't say ACP agents work inline; expect chat only.
- Windows is not documented upstream for codecompanion or claude-agent-acp.
- Needs Neovim 0.12+ (have 0.13), curl, plenary; the yaml parser for prompt
  library markdown (installed).

## Docs

- `:help codecompanion`
- https://codecompanion.olimorris.dev (ACP adapters, chat buffer pages)
