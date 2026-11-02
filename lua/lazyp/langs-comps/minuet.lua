-- minuet-ai.nvim: ghost text and a blink.cmp source; Codestral by default, other providers below (keys in secrets.lua).
-- Gemini needs GEMINI_API_KEY (https://aistudio.google.com/apikey) in the gitignored
-- lua/genja/local/secrets.lua, else in the environment (lua/genja/ext/secrets.lua); curl on PATH.
-- Ollama needs `ollama serve` and `ollama pull qwen2.5-coder:0.5b`; switch for a session with
--   :Minuet change_model openai_fim_compatible:qwen2.5-coder:0.5b
-- :CheckHealthSimpleMinuet shows which provider is on and whether it can answer.
-- Ghost text is on in gitcommit buffers (took over from copilot.vim, 2026-10-31), with the staged
-- diff sent along (lua/genja/ext/minuet-diff.lua, 2026-11-02); off elsewhere:
--   ghost text: <leader>am in the buffer (:Minuet virtualtext toggle)
--   blink: the source only answers <M-y>; <leader>aM turns on auto-complete
-- The blink source is added by lua/genja/completion/minuet.lua (feature 'minuet'
-- in lua/lazyp/new/genja-completion011.lua); blink's require loads this plugin.
--
-- Keys and mappings are defined in lua/genja/map-plugin/minuet.lua.

local Maps = require('genja.map-plugin')

-- A model with fill-in-the-middle: qwen3.5 (gen.lua's) gets 400 "does not support insert".
local MODEL = 'qwen2.5-coder:0.5b'

-- thinking as low as the model allows, below (README: it adds latency and little for completion)
-- local GEMINI_MODEL = 'gemini-3.8-flash'
local GEMINI_MODEL = 'gemini-3.5-flash-lite'

---API key getter for minuet's api_key: lua/genja/local/secrets.lua, else the env (lua/genja/ext/secrets.lua).
---A function, so minuet reads the key per request and an edited secrets.lua needs no restart.
---@param name string
---@return fun(): string|nil
local function secret(name)
    return function()
        return require('genja.ext.secrets').LocalOrEnv(name)
    end
end

-- Codestral end points: the free personal key works only on the first, a paid key only on the second
local CODESTRAL_FREE = 'https://codestral.mistral.ai/v1/fim/completions'
local CODESTRAL_PAID = 'https://api.mistral.ai/v1/fim/completions'

---Paid Mistral key if set, else the free Codestral key.
---@return string|nil
local function mistral_key()
    local secrets = require('genja.ext.secrets')
    return secrets.LocalOrEnv('MISTRAL_API_KEY') or secrets.LocalOrEnv('CODESTRAL_API_KEY')
end

---@type LazySpec
return {

    'milanglacier/minuet-ai.nvim',
    cmd = 'Minuet',
    ft = 'gitcommit', -- loads for commit buffers, so auto_trigger_ft below can turn ghost text on
    keys = Maps:keys(),
    opts = {
        provider = 'codestral', -- since 2026-10-31; free key in CODESTRAL_API_KEY
        -- provider = 'openai_fim_compatible', -- ollama, before 2026-10-31
        -- provider = 'gemini',
        n_completions = 1, -- one request per completion: local models are slow
        context_window = 512, -- README: start small for local models
        request_timeout = 6, -- seconds, every provider; curl --max-time; blink's timeout_ms matches it
        provider_options = {
            gemini = {
                api_key = secret('GEMINI_API_KEY'),
                model = GEMINI_MODEL,
                optional = {
                    generationConfig = {
                        maxOutputTokens = 256,
                        -- thinkingConfig = { thinkingBudget = 0 }, -- 2.5 models
                        -- thinkingConfig = { thinkingLevel = 'minimal' }, -- 3.x models; gemini-3.8-flash: 400 not supported
                        thinkingConfig = { thinkingLevel = 'low' }, -- 3.x models
                    },
                },
            },
            -- Claude: paid API only, no free tier. Prepaid credits at https://console.anthropic.com
            -- (Settings > Billing), key under Settings > API Keys; a claude.ai Pro/Max plan does not cover API use.
            -- claude-haiku-5-5: $0.10 per 1M input tokens, $0.50 per 1M output (prompts up to 100K tokens).
            -- One completion here is roughly 1K tokens in and up to 256 out, so about $0.0002 each.
            -- Free options: ollama (local, private, openai_fim_compatible below) or Gemini's free tier
            -- (AI Studio key, rate-limited; Google may use the prompts on the free tier).
            -- No API key for now (2026-10-31); maybe later.
            -- claude = {
            --     api_key = secret('ANTHROPIC_API_KEY'),
            --     model = 'claude-haiku-5-5',
            --     optional = {
            --         -- Haiku 5.5 thinks by default (effort medium); low keeps completions fast and cheap
            --         output_config = { effort = 'low' },
            --     },
            -- },
            -- Codestral (Mistral): fill-in-the-middle code model, two keys:
            --   MISTRAL_API_KEY    paid La Plateforme key (https://console.mistral.ai/api-keys), api.mistral.ai
            --   CODESTRAL_API_KEY  free personal key (console.mistral.ai, Codestral section; rate-limited),
            --                      codestral.mistral.ai
            -- The paid key wins when both are set; the end point follows the key.
            codestral = {
                api_key = mistral_key,
                model = 'codestral-latest',
                end_point = CODESTRAL_FREE,
                transform = {
                    function(data)
                        if require('genja.ext.secrets').LocalOrEnv('MISTRAL_API_KEY') then
                            data.end_point = CODESTRAL_PAID
                        end
                        return data
                    end,
                },
                optional = { max_tokens = 256 },
            },

            -- OpenAI: paid API only, https://platform.openai.com/api-keys
            openai = {
                api_key = secret('OPENAI_API_KEY'),
                model = 'gpt-5.6-luna', -- minuet's default
            },

            -- OpenRouter: one key for many models (https://openrouter.ai/keys); models ending in
            -- `:free` cost nothing but are rate-limited. The default below is paid, but cheap.
            openai_compatible = {
                api_key = secret('OPENROUTER_API_KEY'),
                name = 'Openrouter',
                end_point = 'https://openrouter.ai/api/v1/chat/completions',
                model = 'deepseek/deepseek-v4-flash',
            },

            -- openai_fim_compatible holds one server at a time: ollama now, DeepSeek commented out.
            -- DeepSeek (https://platform.deepseek.com, prepaid): deepseek-v4-flash about $0.14 per 1M
            -- input tokens and $0.28 per 1M output (2026-09, third-party listings), so about $0.0002 per completion.
            -- openai_fim_compatible = {
            --     api_key = secret('DEEPSEEK_API_KEY'),
            --     name = 'Deepseek',
            --     end_point = 'https://api.deepseek.com/beta/completions',
            --     model = 'deepseek-v4-flash',
            --     optional = { max_tokens = 256 },
            -- },
            openai_fim_compatible = {
                api_key = 'APPDATA', -- ollama wants none; minuet wants a set env var (TERM is unset on Windows)
                name = 'Ollama',
                end_point = 'http://localhost:11434/v1/completions',
                model = MODEL,
                optional = { max_tokens = 56, top_p = 0.9 },
            },
        },
        virtualtext = {
            auto_trigger_ft = { 'gitcommit' }, -- elsewhere off until <leader>am
            -- keys picked while copilot.vim held <M-f> <M-w> <M-j> <M-[> <M-]> <C-]> (now in lua/lazyp/unused/)
            keymap = {
                accept = '<M-A>',
                accept_line = '<M-a>',
                accept_n_lines = '<M-z>',
                prev = '<M-,>',
                next = '<M-.>',
                dismiss = '<M-e>',
            },
        },
        blink = { enable_auto_complete = false }, -- manual <M-y> still works
        cmp = { enable_auto_complete = false },
    },
    config = function(_, opts)
        -- gitcommit: the staged diff goes along (lua/genja/ext/minuet-diff.lua); minuet.config
        -- is only on the rtp now, so the templates are set here and not in opts above
        local diff = require('genja.ext.minuet-diff')
        local po = opts.provider_options
        po.codestral.template = diff.fim_template()
        po.openai_fim_compatible.template = diff.fim_template()
        for _, name in ipairs({ 'gemini', 'openai', 'openai_compatible' }) do
            po[name].chat_input = diff.chat_input()
        end
        require('minuet').setup(opts)
        Maps:mappings(opts)
    end,
}
