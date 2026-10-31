-- not used: 2026-10
-- llm.nvim (huggingface): ghost text from ollama through the llm-ls server.
-- Failed on Windows with nvim 0.13 (2026-10-31); minuet does the same job (lua/lazyp/langs-comps/minuet.lua).
-- What was tried:
--   - llm.nvim's own llm-ls download fails on Windows (sysname is Windows_NT, and it shells
--     out to gunzip/chmod), so lsp.bin_path points at mason's launcher (:MasonInstall llm-ls).
--     The llm-ls client attached (:checkhealth vim.lsp), no "not found" warning.
--   - model qwen3.5:0.8b-q8_0 (not a coder) -> qwen2.5-coder:0.5b, with Qwen's FIM tokens and raw = true.
--   - no ghost text, ollama got no request, ~/.cache/llm_ls/llm-ls.log stayed empty:
--     upstream calls lsp.util.make_position_params() without a position encoding, which
--     nvim 0.13 requires, so each request throws in the debounce timer before reaching llm-ls.
--   - PR #124 (ViViDboarder/llm.nvim, branch look-up-position-encoding, open since 2025-05)
--     passes the encoding; with it, still no ghost text. Not debugged further.
-- Auto-suggest is off at start: <leader>al (:LLMToggleAutoSuggest); :LLMSuggestion asks once.
--
-- Keys (commented out) are in lua/genja/map-plugin/llm.lua.

local SRC = 'lua/lazyp/unused-failed/llm.lua: '

local Maps = require('genja.map-plugin')

-- a coder model: qwen3.5 (not a coder) gave poor fill-in-the-middle
local MODEL = 'qwen2.5-coder:0.5b'

---@type LazySpec
return {
    'huggingface/llm.nvim',
    -- PR #124 branch, passes the position encoding nvim 0.13 requires; tried, still no ghost text:
    -- 'ViViDboarder/llm.nvim',
    -- branch = 'look-up-position-encoding',
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
