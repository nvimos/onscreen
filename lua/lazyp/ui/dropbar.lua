-- idea 13: breadcrumbs (symbol path at the cursor) with drop-down menus.
-- Shown inside genja-statusline's winbar: lua/lazyp/new/genja-statusline.lua.
-- Usage and keys: doc-wip/readme.idea13-dropbar-aerial.outer-key.md

local BIG_BYTES = 1024 * 1024 -- above this, no LSP symbols (whole tree per request)

---Crumb sources per buffer, chosen once when the bar of a window is created.
---No path source: genja already shows the file name.
---@param buf integer
---@return dropbar_source_t[]
local function sources(buf)
	local src = require('dropbar.sources')
	local utils = require('dropbar.utils')
	if vim.bo[buf].filetype == 'markdown' then
		return { src.markdown }
	end
	if vim.bo[buf].buftype ~= '' then
		return {}
	end
	-- treesitter walks up from the cursor: cheap at any size
	if vim.fn.getfsize(vim.api.nvim_buf_get_name(buf)) > BIG_BYTES then
		return { src.treesitter }
	end
	return { utils.source.fallback({ src.lsp, src.treesitter }) }
end

---@type LazySpec
return {
	'Bekaboo/dropbar.nvim',
	event = 'VeryLazy',
	keys = {
		{ '<leader>;', function() require('dropbar.api').pick() end, desc = 'Dropbar: pick a crumb' },
		{ '[;', function() require('dropbar.api').goto_context_start() end, desc = 'Dropbar: start of context' },
		{ '];', function() require('dropbar.api').select_next_context() end, desc = 'Dropbar: next context' },
	},
	---@type dropbar_configs_t
	opts = {
		bar = {
			enable = false, -- never set 'winbar'; genja-statusline embeds the bar
			sources = sources,
			padding = { left = 0, right = 1 }, -- genja puts a space before it
		},
	},
}
