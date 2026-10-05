-- Diagnostics display. Neovim 0.11 turned inline virtual text off by default.
vim.diagnostic.config({
	virtual_text = true,
	severity_sort = true,
})

-- But virtual text can become visually noisy, especially with both Pyrefly and Ruff active.
-- A more ergonomic setup might be:
-- vim.diagnostic.config({
-- 	signs = true,
-- 	underline = true,
-- 	severity_sort = true,
-- 	virtual_text = {
-- 		spacing = 2,
-- 		source = 'if_many',
-- 	},
-- 	float = {
-- 		border = 'rounded',
-- 		source = 'if_many',
-- 	},
-- })
--


-- Another good option is to use virtual lines only for the current line:
-- vim.diagnostic.config({
-- 	virtual_text = false,
-- 	virtual_lines = {
-- 		current_line = true,
-- 	},
-- })
--
