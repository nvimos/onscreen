-- local opts = {
-- 	ensure_installed = {
--     "efm",
--     "pyright",
--     "ansiblels",
-- 	},
-- 	automatic_installation = true,
-- }

local opts = {
	ensure_installed = {
    "pyright",
    "ansiblels",
	},
	automatic_installation = true,
}

return {
	"williamboman/mason-lspconfig.nvim",
	opts = opts,
	event = "BufReadPre",
	dependencies = "williamboman/mason.nvim",
}
