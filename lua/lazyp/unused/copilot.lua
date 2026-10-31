-- not used: 2026-10
-- Shelved 2026-10-31: minuet won the ghost-text comparison (lua/lazyp/langs-comps/minuet.lua).
-- copilot.vim worked; gitcommit ghost text goes with it. The copilot CLI backends in
-- genja-ask and genja-commit don't use this plugin.
-- Keys (commented out) are in lua/genja/map-plugin/copilot.lua.
--
-- GitHub Copilot ghost-text suggestions. First run: :Copilot setup (signs in via browser).
-- Needs Node.js on PATH (minimum version: copilot.vim README; :Copilot status warns).
-- <Tab> stays with blink.cmp
--
-- Off by default to conserve credits: only the filetypes below load and enable it;
-- <leader>at turns it on for the rest ('*').

local Maps = require('genja.map-plugin')

local on_filetypes = { 'gitcommit' }

---@type LazySpec
return {
	'github/copilot.vim',
	enabled = true,
	ft = on_filetypes,
	cmd = 'Copilot',
	keys = Maps:keys(),
	init = function()
		vim.g.copilot_no_tab_map = true -- blink.cmp owns <Tab>
		local filetypes = {
			['*'] = false,
			help = false,
			TelescopePrompt = false,
			oil = false,
		}
		for _, ft in ipairs(on_filetypes) do
			filetypes[ft] = true
		end
		vim.g.copilot_filetypes = filetypes
	end,
	config = function(_, opts)
		Maps:mappings(opts)
	end,
}
