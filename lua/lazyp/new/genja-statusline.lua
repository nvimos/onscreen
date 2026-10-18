-- idea 13: dropbar crumbs embedded in genja's winbar (dropbar: lua/lazyp/ui/dropbar.lua).
-- dropbar never sets 'winbar' itself (bar.enable = false); genja calls _G.dropbar().
---@param buf integer
---@param win integer
---@return string
local function dropbar_part(buf, win)
	if type(_G.dropbar) ~= 'table' then
		return '' -- dropbar not loaded yet (VeryLazy)
	end
	-- file buffers in normal windows only: no oil, help, terminal, floats
	if vim.bo[buf].buftype ~= '' or vim.api.nvim_win_get_config(win).relative ~= '' then
		return ''
	end
	-- _G.dropbar() reads the current window, which is the one being drawn
	return _G.dropbar()
end

---@type LazySpec
return {
	dir = vim.fn.stdpath('config') .. '/plug-wip/genja-statusline.nvim',

	---@type genja-statusline.Opts
	opts = {
		statusline = true,
		tabline = true,
		winbar = true,
		winbar_extra = { dropbar_part },
		-- json/yaml key path without dropbar: see plug-wip/genja-statusline.nvim/lua/genja-statusline/keypath.lua
	},
	lazy = false,

	config = function(_, opts)
		require('genja-statusline').setup(opts)
	end
}
