-- ccc.nvim: colour picker and in-buffer colour highlighter. Keys: lua/genja/map-plugin/ccc.lua.
-- Upstream idle since 2025-05 (open: #150 deprecated buf option API, #146 `excludes` ignored).
-- auto_enable stays off: with it on, its filetype filter also blocks :CccHighlighterToggle elsewhere.
local Maps = require('genja.map-plugin')

-- Filetypes that get colours painted on open.
local HIGHLIGHT_FT = { 'vim', 'lua', 'css', 'scss' }

---@param bufnr integer
local function highlight(bufnr)
	require('ccc.highlighter'):enable(bufnr)
end

---@type LazySpec
return {
	'uga-rosa/ccc.nvim',
	ft = HIGHLIGHT_FT,
	cmd = { 'CccPick', 'CccConvert', 'CccHighlighterToggle', 'CccHighlighterEnable', 'CccHighlighterDisable' },
	keys = Maps:keys(),
	-- A function: ccc's mapping table exists only once the plugin is loaded.
	opts = function()
		local mapping = require('ccc').mapping
		return {
			highlighter = {
				auto_enable = false,
				lsp = false, -- nvim's own LSP document colours would draw a second time
			},
			-- Added to the defaults (h/l, s/d, …), which stay.
			mappings = {
				['<Left>'] = mapping.decrease1,
				['<Right>'] = mapping.increase1,
			},
		}
	end,
	config = function(_, opts)
		require('ccc').setup(opts)
		Maps:mappings(opts)

		vim.api.nvim_create_autocmd('FileType', {
			group = vim.api.nvim_create_augroup('genja_ccc', { clear = true }),
			pattern = HIGHLIGHT_FT,
			callback = function(ev) highlight(ev.buf) end,
		})
		-- The buffer whose FileType loaded the plugin has fired already.
		if vim.tbl_contains(HIGHLIGHT_FT, vim.bo.filetype) then
			highlight(vim.api.nvim_get_current_buf())
		end
	end,
}
