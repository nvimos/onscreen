# LLM chat: survey before building our own

Status: not started (prepared 2026-11-05). Resume here before building the chat.
Idea: todo-ideas.md, "LLM chat in a buffer, like the browser chat".
Runs alongside the Kubernetes YAML work.

Goal of the survey: find a plugin whose chat fits the model below, or collect
the ideas worth taking (and the ones to avoid) for our own, built on genja-ask.

## The model (from the idea)

- Open a buffer, ask; the answer is appended; a follow-up goes below it; one conversation.
- Input may live in a separate buffer, but questions and answers stay in the chat buffer.
- Questions fold automatically; responses can be folded by hand.
- Any provider.

## Plugins to look at

Check each one's repo first: last commit, open issues, Windows support.

1. codecompanion.nvim: already installed (lua/lazyp/langs-comps/codecompanion.lua,
   doc-wip/readme.idea19-companion.md). Tested first.
2. avante.nvim: sidebar chat, Cursor-like.
3. gp.nvim: chat as markdown files, buffer-centric.
4. parrot.nvim: fork of gp.nvim, more providers.
5. CopilotChat.nvim: Copilot only.
6. sidekick.nvim (folke): CLI agents in a terminal, plus NES.
7. Others found during the check (e.g. model.nvim, ChatGPT.nvim).

## Test session: codecompanion (one step per question)

Before: claude-agent-acp installed (`npm install -g @agentclientprotocol/claude-agent-acp`),
CLAUDE_CODE_OAUTH_TOKEN in the environment.

1. `:CodeCompanionChat`: where does the chat open (split, float, tab)?
2. Ask a question: does the answer stream into the same buffer?
3. Ask a follow-up below the answer: appended in the same buffer, context kept?
4. Folds: can questions and answers be folded? Automatically?
5. Send the current buffer or a selection as context: which keys?
6. Switch provider mid-chat (e.g. ollama): possible, and how?
7. Close and reopen nvim: can the chat be restored or saved as a file?
8. Speed: time from submit to first text, compared with genja-ask.

## Questions for the user (ask in the survey session, not before)

1. Where should the chat open: split, float, its own tab?
2. Type the question in the chat buffer itself, or in a separate input buffer?
3. How should questions and answers be marked (headings like `## Me` / `## Assistant`, a separator line)?
4. Folds: which part folds by default, and with which keys are they toggled?
5. Stream the answer as it arrives, or show it when complete?
6. Keep chats as markdown files? Where: per project, or in stdpath('data')?
7. Context: how do files, a selection or the current buffer get into a question?
8. One provider per chat, or switch mid-chat?
9. Answers only, or may the chat edit code (agent mode)?
10. Keys: submit, cancel, new chat, yank a code block, jump between questions.
11. Should the genja-ask popup grow into the chat (popup answer -> "continue in chat")?
12. After testing codecompanion: what didn't fit?
