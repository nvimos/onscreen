# minuet-ai.nvim providers (2026-10-31)

Spec: `lua/lazyp/langs-comps/minuet.lua`. Keys: `lua/genja/local/secrets.lua` (gitignored), read by
`require('genja.ext.secrets').LocalOrEnv(name)`; the environment variable of the same name is the fallback.
Check: `:CheckHealthSimpleMinuet` (provider, model, key not set, ollama server, one fixed test request).
Switch for a session: `:Minuet change_model <provider>:<model>`; the spec's `provider` is the default.

## Overview

| Provider (minuet backend) | Key in secrets.lua | Free? | Kind |
|---|---|---|---|
| ollama (`openai_fim_compatible`) | none | yes, local | fill-in-the-middle |
| Gemini (`gemini`) | `GEMINI_API_KEY` | free tier | chat |
| Codestral (`codestral`) | `CODESTRAL_API_KEY` free, `MISTRAL_API_KEY` paid | free personal key | fill-in-the-middle |
| OpenRouter (`openai_compatible`) | `OPENROUTER_API_KEY` | `:free` models | chat |
| DeepSeek (`openai_fim_compatible`, commented out) | `DEEPSEEK_API_KEY` | no, prepaid | fill-in-the-middle |
| Claude (`claude`) | `ANTHROPIC_API_KEY` | no, prepaid | chat |
| OpenAI (`openai`) | `OPENAI_API_KEY` | no | chat |

One completion here is roughly 1K tokens in and up to 256 out (`context_window = 512` characters,
`n_completions = 1`).

## ollama (local)

- Free, private: the code never leaves the machine. `ollama pull qwen2.5-coder:0.5b`, `ollama serve`.
- The model must support fill-in-the-middle (a `.Suffix` in its template, `ollama show <model>`).
  qwen3.5 does not: `400 ... does not support insert`.
- `api_key = 'APPDATA'`: ollama wants none, minuet wants a set env var (TERM is unset on Windows).
- Client test:
  `curl.exe http://localhost:11434/v1/completions -H 'Content-Type: application/json' -d '{\"model\":\"qwen2.5-coder:0.5b\",\"prompt\":\"def add(a, b):\n    \",\"suffix\":\"\n\nprint(add(1, 2))\",\"max_tokens\":30}'`
- Limitation: small models complete worse; speed depends on the GPU (2 GB VRAM here).

## Gemini

- Key: https://aistudio.google.com/apikey
- Free tier, rate-limited. On the free tier Google may use the prompts to improve its models.
- No key gives `403 PERMISSION_DENIED ... unregistered callers`.
- Thinking: 2.5 models take `thinkingBudget = 0` (off); 3.x take `thinkingLevel`.
  `gemini-3.8-flash` rejects `'minimal'` (`400 Thinking level MINIMAL is not supported`); `'low'` is set.
- No retry: a curl `--retry 1` was tried and removed (2026-10-31). `request_timeout = 6`, blink's
  `timeout_ms = 6000` (`lua/genja/completion/minuet.lua`).
- Key test:
  `curl.exe -s "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent" -H "x-goog-api-key: $env:GEMINI_API_KEY" -H 'Content-Type: application/json' -d '{\"contents\":[{\"parts\":[{\"text\":\"say hi\"}]}]}'`

## Codestral (Mistral)

- Free personal key: https://console.mistral.ai, Codestral section. Works only on
  `codestral.mistral.ai`; rate-limited. Check that it is still free.
- Paid key (La Plateforme): https://console.mistral.ai/api-keys. Works only on `api.mistral.ai`.
- The spec takes `MISTRAL_API_KEY` when set, else `CODESTRAL_API_KEY`; a `transform` moves the end point
  to `api.mistral.ai` for the paid key. `:CheckHealthSimpleMinuet` shows the free end point either way.

## OpenRouter

- Key: https://openrouter.ai/keys. One key for many models.
- Models ending in `:free` cost nothing; low rate limits. The spec's `deepseek/deepseek-v4-flash` is paid.

## DeepSeek

- Key: https://platform.deepseek.com (prepaid).
- `deepseek-v4-flash`: about $0.14 per 1M input tokens, $0.28 per 1M output (third-party listings,
  2026-06 to 2026-09; official page: https://api-docs.deepseek.com/quick_start/pricing).
  About $0.0002 per completion, so $1 is around 5 000.
- Shares the `openai_fim_compatible` slot with ollama: swap the two blocks in the spec to use it.

## Claude (Anthropic)

- Key: https://console.anthropic.com, Settings > API Keys (shown once, starts `sk-ant-`).
  Credits first: Settings > Billing. A claude.ai Pro/Max plan does not cover API use. No free tier.
- `claude-haiku-5-5`: $0.10 per 1M input tokens, $0.50 per 1M output (prompts up to 100K tokens),
  about $0.0002 per completion. minuet's old default `claude-3-5-haiku-latest` is likely no longer served.
- Haiku 5.5 thinks by default (effort medium); the spec sends `output_config = { effort = 'low' }`.

## OpenAI

- Key: https://platform.openai.com/api-keys. Paid only. Spec: minuet's default `gpt-5.6-luna`.

## Other free options (not in the spec)

- Groq, Cerebras: free tiers with rate limits, OpenAI-compatible chat end points
  (`openai_compatible` with their `end_point`).
- LM Studio, llama.cpp server: local, like ollama (`openai_fim_compatible`).

## minuet behaviour found in this session

- No retry of its own; `curl_extra_args` (list or function) is added to every curl call, before
  minuet's own `--max-time`, so a later `--max-time` from `request_timeout` wins.
- `request_timeout` is one value for all providers (`curl --max-time`, per attempt).
- `api_key` is an env var name or a function; a function is read per request.
- Errors only go to `vim.notify` (`Gemini returns error on streaming: ...`); the backend callback gets
  no items. `:CheckHealthSimpleMinuet` catches the notice during its test request and shows the API's
  code and message.
- `:Minuet change_model` without an argument lists minuet's built-in model list
  (`minuet/modelcard.lua`), not what ollama has installed; picking a `gemini:` entry also switches
  the provider for the session.
- `:Minuet blink toggle` adds minuet items to the blink menu; ghost text is `:Minuet virtualtext toggle`
  (`<leader>am`).

Prices and free tiers change; check the provider pages before relying on them.
