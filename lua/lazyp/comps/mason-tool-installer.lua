-- Installs mason packages by name. Only for headless runs:
--   nvim --headless "+Lazy! sync" "+MasonToolsInstallSync" +qa
-- The list is not kept here: it is whatever the enabled languages in
-- lua/genja/lsp/ ask for (servers + tools), see require('genja.lsp').packages().
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
	opts = function()
		return {
			ensure_installed = require('genja.lsp').packages(),
			run_on_start = false, -- only on the explicit command
		}
	end,
}
