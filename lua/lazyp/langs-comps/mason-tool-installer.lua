-- Installs mason packages by name. Only for headless runs:
--   nvim --headless "+Lazy! sync" "+MasonToolsInstallSync" +qa
-- The list is not kept here: it is whatever the enabled languages in
-- lua/genja/lsp/ ask for (servers + tools), see require('genja.lsp').packages(),
-- plus the linters of lua/genja/lint.lua (require('genja.lint').mason).
---@type LazySpec
return {
	'WhoIsSethDaniel/mason-tool-installer.nvim',
	dependencies = { 'mason-org/mason.nvim' },
	cmd = {
		'MasonToolsInstall',
		'MasonToolsInstallSync',
		'MasonToolsUpdate',
		'MasonToolsUpdateSync',
		'MasonToolsClean',
	},
	---@return MasonToolInstallerSettings
	opts = function()
		local packages = vim.list_extend(require('genja.lsp').packages(), require('genja.lint').mason)
		return {
			ensure_installed = packages,
			run_on_start = false, -- only on the explicit command
		}
	end,
}
