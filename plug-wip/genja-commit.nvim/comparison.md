# Comparison: AI commit message plugins

Checked 2026-10-23 from the READMEs only; nothing was installed. `?` = the
README doesn't say.

## Plugins

- [commit-ai.nvim](https://github.com/Abizrh/commit-ai.nvim): `:Commit`, suggestions from the git diff; commit types with icons; message language setting.
- [commitmate.nvim](https://github.com/ajatdarojat45/commitmate.nvim): `:CommitMate` through CopilotChat.nvim; message goes to the clipboard and `.git/COMMIT_EDITMSG`, optionally opens lazygit.
- [aicommits.nvim](https://github.com/404pilo/aicommits.nvim): `:AICommit`, Conventional Commits, several suggestions in a picker, commits the chosen one; Neogit `C`.
- [CopilotChat.nvim](https://github.com/CopilotC-Nvim/CopilotChat.nvim): built-in `Commit` prompt (`:CopilotChatCommit`), commitizen style, answer in the chat window.
- [codecompanion.nvim](https://codecompanion.olimorris.dev/usage/action-palette): built-in "Commit message" prompt in the action palette.

Not commit tools: [gemini.nvim](https://github.com/meinside/gemini.nvim) (general Gemini text generation),
[sidekick.nvim](https://github.com/folke/sidekick.nvim) (runs claude/gemini/codex CLIs in interactive terminals).

## Features

| | genja-commit | commit-ai | commitmate | aicommits | CopilotChat | codecompanion |
|---|---|---|---|---|---|---|
| Talks to | AI CLIs (claude, copilot, gemini, aichat) | HTTP API (Gemini; "several") | Copilot via CopilotChat | HTTP APIs (OpenAI, Vertex, Gemini, Anthropic, Codex) | Copilot API | its adapters |
| API key needed | no, uses CLI logins | yes | Copilot subscription | yes (or gcloud) | Copilot | per adapter |
| Backend fallback order | yes | ? | no | no (one provider) | no | no |
| Invoked by | `<M-g>` in any gitcommit buffer | `:Commit` | `:CommitMate` | `:AICommit`, Neogit `C` | `:CopilotChatCommit` | action palette |
| Message goes to | cursor in the commit buffer | ? (telescope) | clipboard + COMMIT_EDITMSG | picker, then commits | chat window | ? |
| Several suggestions | no | yes | no | yes (1-8) | no | ? |
| Style from repo log | last 15 subjects | no | no | no | no | ? |
| Conventional Commits | no (follows your log) | commit types | "conventions" | yes | commitizen | ? |
| Message language | no | yes | no | no | no | ? |
| Lint while typing | gitlint or Lua rules | no | no | no | no | no |
| Commit popup | yes (oil), draft kept, `:w` | no | no | no | no | no |
| Copilot ghost text in commit buffers | yes | no | no | no | no | no |
| Cancel / timeout | `<C-c>`, 60 s | ? | ? | ? | ? | ? |
| Git UI integration | oil | ? | lazygit | Neogit | no | no |
| Dependencies | none (nvim-lint, gitlint optional) | plenary, telescope | plenary, CopilotChat | curl | plenary, curl | plenary |

## Takeaways

- None of them run local AI CLIs one-shot; all call HTTP APIs or Copilot. genja-commit reuses the CLI logins, so it needs no API keys.
- None lint the message or keep a draft.
- Ideas worth taking:
  - several suggestions in a picker (aicommits);
  - an optional Conventional Commits mode (aicommits, CopilotChat);
  - writing to COMMIT_EDITMSG for lazygit (commitmate).
