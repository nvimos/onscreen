# Local ghost text: minuet-ai.nvim and llm.nvim on ollama (2026-10-31)

What it does

- Two ways to get gray in-buffer suggestions from a local model, to compare against copilot.vim.
- Both use ollama with `qwen3.5:0.8b-q8_0` (the model gen.nvim already uses, `lua/lazyp/langs-comps/gen.lua`).
- Nothing to rip out: copilot.vim stays (gitcommit only, `<leader>at` for the rest). All three start off;
  turn on one at a time, or they draw over each other.
- minuet-ai.nvim (`lua/lazyp/langs-comps/minuet.lua`): ghost text and a blink.cmp source, talks to
  ollama's `/v1/completions` directly (curl). The blink source is the config-side feature
  `lua/genja/completion/minuet.lua`, listed in `lua/lazyp/new/genja-completion011.lua`.
- llm.nvim (`lua/lazyp/langs-comps/llm.lua`): ghost text only, through the llm-ls language server.
  Its own llm-ls download is broken on Windows (sysname `Windows_NT`, gunzip/chmod through cmd.exe),
  so it uses mason's `llm-ls`; the spec warns when it is missing.

Keys and commands

| key / command | what |
|---|---|
| `<leader>am` | Minuet: ghost text on/off in this buffer (`:Minuet virtualtext toggle`) |
| `<leader>aM` | Minuet: blink auto-complete on/off (`:Minuet blink toggle`) |
| `<M-y>` (insert) | ask minuet into the blink menu; works while auto-complete is off |
| `<M-A>` `<M-a>` `<M-z>` | minuet accept / accept line / accept n lines |
| `<M-.>` `<M-,>` `<M-e>` | minuet next / previous / dismiss |
| `<leader>al` | LLM: auto-suggest on/off (`:LLMToggleAutoSuggest`) |
| `:LLMSuggestion` | llm.nvim: one suggestion now |
| `<M-;>` `<M-'>` | llm.nvim accept / dismiss |

Setup once

1. `ollama serve` running; `ollama pull qwen3.5:0.8b-q8_0` (already there for gen.nvim).
2. Start nvim; lazy installs minuet-ai.nvim and llm.nvim.
3. `:MasonInstall llm-ls`.

How to test

1. minuet ghost text: open a `.lua` file, `<leader>am`, type `local function add(a, b)` and `<CR>`,
   wait ~1 s: gray text appears; `<M-A>` takes it, `<M-a>` one line, `<M-e>` drops it.
2. minuet blink: in insert mode `<M-y>`: the menu shows minuet items (source `minuet`). Without `<M-y>`
   minuet adds nothing; `<leader>aM` makes it join every menu (slow on a 0.8b model, watch the delay).
3. llm.nvim: `<leader>al` (first press loads it), type in a code file, wait: ghost text; `<M-;>` accepts.
   `:LspInfo` / `:checkhealth vim.lsp` shows an `llm-ls` client.
4. Compare: same spot, minuet vs llm.nvim vs copilot (`<leader>at`): speed and quality.

If it fails

- minuet nothing: `curl http://localhost:11434/v1/completions -d '{"model":"qwen3.5:0.8b-q8_0","prompt":"def f(","suffix":"\n","max_tokens":20}'`;
  an error about suffix means the model's template has no FIM support: try `qwen2.5-coder:0.5b`
  (change MODEL in both specs).
- llm.nvim echoes the chat template or garbage: the FIM tokens or `raw = true` don't suit the model; same fallback.
- `llm.lua: llm-ls not found`: `:MasonInstall llm-ls`, then restart.

Not run: neither plugin was installed or started; no request reached ollama. Only syntax and the key/feature
tables were checked headless.
