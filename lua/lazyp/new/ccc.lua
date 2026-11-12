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

local SRC = 'lua/lazyp/new/ccc.lua: '

local HELP = {
	'<Esc> q      close the picker',
	'<CR>         insert the colour',
	'<Tab>  i     next colour mode (RGB, HSL, CMYK)',
	'o            next output format',
	'a            show or hide alpha',
	'h l  <Left> <Right>   -1 / +1',
	's d          -5 / +5',
	'm ,  <S-Left> <S-Right>   -10 / +10',
	'0-9          set slider to 0-90 %',
	'H M L        set slider to 0 / 50 / 100 %',
	'r            reset mode',
	'g            show previous colours',
	'b w  B W     previous colour: back, forward, first, last',
	'?            this help',
}

-- Small modal listing the picker keys; <Esc> and q close it.
local function show_help()
	local ok, float = pcall(require, 'genja-util.float')
	if not ok then
		vim.notify(SRC .. 'genja-util.float not found', vim.log.levels.WARN)
		return
	end
	local width = 0
	for _, line in ipairs(HELP) do
		width = math.max(width, vim.fn.strdisplaywidth(line))
	end
	local buf = float.scratch(HELP)
	local win = float.open(buf, { width = width + 2, height = #HELP, title = 'ccc keys', zindex = 100 })
	for _, key in ipairs({ '<Esc>', 'q', '?' }) do
		vim.keymap.set('n', key, function() float.close(win) end, { buffer = buf, nowait = true })
	end
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
			-- Colours in nvim carry no alpha: hidden at start, `a` shows it.
			alpha_show = 'hide',
			-- Added to the defaults (h/l, s/d, …), which stay.
			mappings = {
				['<Esc>'] = mapping.quit,
				['<Tab>'] = mapping.cycle_input_mode,
				['?'] = show_help,
				['<Left>'] = mapping.decrease1,
				['<Right>'] = mapping.increase1,
				['<S-Left>'] = mapping.decrease10,
				['<S-Right>'] = mapping.increase10,
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
