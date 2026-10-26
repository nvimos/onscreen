-- For scripts run inside an nvim with the real config (`make status`, `make plan`): bring it to
-- the state the tests' child reaches after boot() in tests/comps011, without opening a file.
--   dofile('tests/helpers/real-config.lua').prepare()
-- Start nvim with --cmd 'let g:genja_lsp_no_install = v:true' so mason installs nothing.
local M = {}

function M.prepare()
	-- mason's bin first: in a fresh nvim mason may not have put it on PATH yet
	local sep = ':'
	if vim.fn.has('win32') == 1 then
		sep = ';'
	end
	vim.env.PATH = vim.fn.stdpath('data') .. '/mason/bin' .. sep .. vim.env.PATH

	-- lazy fires VeryLazy after UIEnter; a headless nvim has no UI
	if vim.g.did_very_lazy ~= true then
		vim.api.nvim_exec_autocmds('UIEnter', {})
		vim.wait(5000, function() return vim.g.did_very_lazy == true end, 20)
	end

	-- genja.lsp's setup() (vim.lsp.enable) and nvim-lspconfig's lsp/<server>.lua (the cmds);
	-- requiring them makes lazy load the plugins
	pcall(require, 'lspconfig')
	pcall(require, 'genja.lsp')
end

return M
