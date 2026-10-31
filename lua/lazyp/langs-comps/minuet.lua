-- minuet-ai.nvim: local ghost text and a blink.cmp source, from ollama.
-- Needs `ollama serve` with the model below (same one as gen.lua); curl on PATH.
-- Off by default, like copilot.vim:
--   ghost text: <leader>am in the buffer (:Minuet virtualtext toggle)
--   blink: the source only answers <M-y>; <leader>aM turns on auto-complete
-- The blink source is added by lua/genja/completion/minuet.lua (feature 'minuet'
-- in lua/lazyp/new/genja-completion011.lua); blink's require loads this plugin.
--
-- Keys and mappings are defined in lua/genja/map-plugin/minuet.lua.

local Maps = require('genja.map-plugin')

-- qwen3.5 is not a coder model; if fill-in-the-middle is poor, try qwen2.5-coder:0.5b.
local MODEL = 'qwen3.5:0.8b-q8_0'

---@type LazySpec
return {
    'milanglacier/minuet-ai.nvim',
    cmd = 'Minuet',
    keys = Maps:keys(),
    opts = {
        provider = 'openai_fim_compatible',
        n_completions = 1, -- one request per completion: local models are slow
        context_window = 512, -- README: start small for local models
        request_timeout = 3, -- seconds; blink's timeout_ms matches it
        provider_options = {
            openai_fim_compatible = {
                api_key = 'APPDATA', -- ollama wants none; minuet wants a set env var (TERM is unset on Windows)
                name = 'Ollama',
                end_point = 'http://localhost:11434/v1/completions',
                model = MODEL,
                optional = { max_tokens = 56, top_p = 0.9 },
            },
        },
        virtualtext = {
            auto_trigger_ft = {}, -- off everywhere until <leader>am
            -- copilot.vim holds <M-f> <M-w> <M-j> <M-[> <M-]> <C-]>
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
        require('minuet').setup(opts)
        Maps:mappings(opts)
    end,
}
