return {
    "David-Kunz/gen.nvim",
    opts = {
        model = "qwen3.5:0.8b-q8_0", -- Your exact Ollama model
        host = "localhost",      -- Default Ollama port
        port = "11434",
        quit_map = "q",          -- Close the response window easily
        display_mode = "float",  -- "float" (floating window), "split", or "horizontal"
        show_model = true,       -- Displays which model is acting
        no_auto_close = false,   -- Keep window open after generation finishes
        init = function(options) pcall(io.popen, "ollama run " .. options.model) end,
    },
    keys = {
        { "<leader>ai", ":Gen<CR>", mode = { "n", "v" }, desc = "AI Prompt Menu" },
    }
}
