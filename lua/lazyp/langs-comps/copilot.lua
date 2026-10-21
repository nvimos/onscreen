-- GitHub Copilot ghost-text suggestions. First run: :Copilot setup (signs in via browser).
-- Needs Node.js on PATH (minimum version: copilot.vim README; :Copilot status warns).
-- <Tab> stays with nvim-cmp
--
-- Keys and mappings are defined in lua/genja/map-plugin/copilot.lua.

local Maps = require('genja.map-plugin')

---@type LazySpec
return {
	'github/copilot.vim',
	enabled = true,
	event = 'InsertEnter',
	cmd = 'Copilot',
	keys = Maps:keys(),
	init = function()
		vim.g.copilot_no_tab_map = true -- nvim-cmp owns <Tab>
		vim.g.copilot_filetypes = {
			['*'] = true,
			gitcommit = true,
			markdown = true,
			help = false,
			TelescopePrompt = false,
			oil = false,
		}
	end,
	config = function(_, opts)
		Maps:mappings(opts)
		vim.cmd('Copilot disable') -- copilot off, disabled by default to conserve credits
	end,
}
