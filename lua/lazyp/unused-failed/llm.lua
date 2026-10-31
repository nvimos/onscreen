-- llm.nvim (huggingface): ghost text from ollama through the llm-ls server.
-- Needs `ollama serve` with the model below (same one as gen.lua) and `:MasonInstall llm-ls`.
-- llm.nvim's own llm-ls download fails on Windows (sysname is Windows_NT, and it shells
-- out to gunzip/chmod), so lsp.bin_path points at mason's launcher.
-- Auto-suggest is off at start: <leader>al (:LLMToggleAutoSuggest); :LLMSuggestion asks once.
--
-- Keys and mappings are defined in lua/genja/map-plugin/llm.lua.

local SRC = 'lua/lazyp/langs-comps/llm.lua: '

local Maps = require('genja.map-plugin')

-- qwen3.5 is not a coder model; if fill-in-the-middle is poor, try qwen2.5-coder:0.5b.
local MODEL = 'qwen3.5:0.8b-q8_0'

---@type LazySpec
return {
    'huggingface/llm.nvim',
    cmd = { 'LLMToggleAutoSuggest', 'LLMSuggestion' },
    keys = Maps:keys(),
    opts = function()
        return {
            backend = 'ollama',
            model = MODEL,
            url = 'http://localhost:11434', -- llm-ls appends /api/generate
            -- raw: the prompt already has the FIM tokens, so ollama skips the chat template
            request_body = {
                raw = true,
                options = { temperature = 0.2, top_p = 0.95, num_predict = 60 },
            },
            -- Qwen's FIM tokens (the README only lists starcoder and codellama)
            fim = {
                enabled = true,
                prefix = '<|fim_prefix|>',
                suffix = '<|fim_suffix|>',
                middle = '<|fim_middle|>',
            },
            tokens_to_clear = { '<|endoftext|>', '<|im_end|>' },
            context_window = 1024,
            enable_suggestions_on_startup = false,
            -- <Tab> is blink's; copilot.vim and minuet hold the other <M-> keys
            accept_keymap = '<M-;>',
            dismiss_keymap = "<M-'>",
            lsp = { bin_path = vim.fn.exepath('llm-ls') },
        }
    end,
    config = function(_, opts)
        if opts.lsp.bin_path == '' then
            vim.notify(SRC .. 'llm-ls not found; run :MasonInstall llm-ls', vim.log.levels.WARN)
            return
        end
        require('llm').setup(opts)
        Maps:mappings(opts)
    end,
}
