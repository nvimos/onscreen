-- Env variables in .env and shell files: ecolog2.nvim when ecolog-lsp can run, else ecolog.nvim v1.
-- The two conds are each other's opposite, so exactly one of them loads.

---@type LazySpec
return {
    {
        -- todo: test me 2026
        "ph1losof/ecolog2.nvim",

        -- the plugin is a client for ecolog-lsp (a Rust binary). build and the plugin need
        -- ~/.cargo/bin on PATH (cargo and ecolog-lsp live there; lua/genja/env.lua adds it)
        build = "cargo install ecolog-lsp",
        -- load when ecolog-lsp is installed, or cargo is on PATH so build can install it. Without
        -- either, opening a .sh file logs "Spawning process with cmd: { "ecolog-lsp" } failed"
        cond = function()
            return vim.fn.executable("ecolog-lsp") == 1 or vim.fn.executable("cargo") == 1
        end,

        ft = { "dotenv", "sh", "bash", "zsh" },
        -- one command with subcommands (lua/ecolog/commands/init.lua); peek is LSP hover (K)
        cmd = { "Ecolog" },
        keys = {
            { "<leader>gE",  "<cmd>Ecolog files open_active<cr>", desc = "Env: go to env file",   noremap = true, silent = true },
            { "<leader>gEs", "<cmd>Ecolog files select<cr>",      desc = "Env: select env file",  noremap = true, silent = true },
            { "<leader>gEv", "<cmd>Ecolog list<cr>",              desc = "Env: browse variables", noremap = true, silent = true },
        },

        dependencies = {
            "nvim-telescope/telescope.nvim", -- optional
        },

        ---@type table
        opts = {},
    },
    {
        -- the pure-Lua v1, for machines without cargo or ecolog-lsp; removed 2026-10-12 (2c1dba6),
        -- back 2026-10-31. Commands from its v1 README.
        "ph1losof/ecolog.nvim",
        branch = "v1", -- upstream asks to pin v1; ecolog2.nvim is the rewrite
        cond = function()
            return vim.fn.executable("ecolog-lsp") == 0 and vim.fn.executable("cargo") == 0
        end,

        ft = { "dotenv", "sh", "bash", "zsh" },
        cmd = { "EcologGoto", "EcologPeek", "EcologSelect", "EcologTelescope", "EcologGotoVar", "EcologRefresh" },
        keys = {
            { "<leader>gE",  "<cmd>EcologGoto<cr>",      desc = "Env: go to env file",   noremap = true, silent = true },
            { "<leader>gEp", "<cmd>EcologPeek<cr>",      desc = "Env: peek variable",    noremap = true, silent = true },
            { "<leader>gEs", "<cmd>EcologSelect<cr>",    desc = "Env: select env file",  noremap = true, silent = true },
            { "<leader>gEv", "<cmd>EcologTelescope<cr>", desc = "Env: browse variables", noremap = true, silent = true },
        },

        dependencies = { "nvim-telescope/telescope.nvim" },

        ---@type table
        opts = {},
    },
}
