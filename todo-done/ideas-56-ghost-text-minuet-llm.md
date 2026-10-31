From: todo-ideas.md

- [x] want true "Ghost Text" (gray text inside the buffer like GitHub Copilot) rather than a popup menu, it is highly recommended to use llm.nvim or copilot.vim architectural alternatives alongside blink.cmp.
  - integrate ollama as a source / provider / backend ( ollama run qwen3.5
  - use qwen
    - 0.8b 2b 4b
  - compare copilot.vim and llm.nvim. i probably want llm.nvim
    - which parts (in my current config) do i have to rip out to get it.
    - i think im using copilot.vim already
  - set up the fastest/smallest qwen as a blink source in addition
  - decided 2026-10-31 (auto-todo): nothing to rip out, copilot.vim stays (gitcommit, <leader>at)
    - [x] minuet-ai.nvim: ollama qwen3.5:0.8b, ghost text + blink source (manual <M-y>), off by default
    - [x] llm.nvim: ollama qwen3.5:0.8b via llm-ls, auto-suggest off, <M-;> accept
    - llm-ls from mason (llm.nvim's download is broken on Windows); untested,
      doc-wip/readme.2026-10-31.ghost-text-minuet-llm.md
