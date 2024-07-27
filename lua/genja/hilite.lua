
--[[
	https://coolors.co/palettes/trending/orange
]]
-- highlight link MRUFileName LineNr


--[[
		cterm={attr-list}			*attr-list* *highlight-cterm* *E418*
			attr-list is a comma-separated list (without spaces) of the
			following items (in any order):
				bold
				underline
				undercurl	curly underline
				underdouble	double underline
				underdotted	dotted underline
				underdashed	dashed underline
				strikethrough
				reverse
				inverse		same as reverse
				italic
				standout
				altfont
				nocombine	override attributes instead of combining them
				NONE		no attributes used (used to reset it)
]]
vim.cmd[[

highlight Search     guifg=orange guibg=#441111
highlight IncSearch  guifg=orange guibg=#441111
highlight CurSearch  guifg=cyan   guibg=#441111
highlight MatchParen guifg=orange guibg=NONE
highlight MatchParen guisp=orange gui=bold,standout,underline
highlight Visual     guifg=orange guibg=#332277 gui=bold

]]

-- General
vim.cmd[[
hi DashboardHeader ctermfg=Yellow guifg=#4793AF
hi DashboardFooter ctermfg=Yellow guifg=#FFC470
hi DashboardShortCut ctermfg=Yellow guifg=#FFC470
hi DashboardShortCutIcon ctermfg=Yellow guifg=#FFC470

hi DashboardFiles  ctermfg=Yellow guifg=#4793AF

hi DashboardDesc ctermfg=Yellow guifg=#FFC470
hi DashboardKey ctermfg=Yellow  guifg=#FFC470
]]
--hi DashboardShortCutIcon ctermfg=Yellow guifg=#FFC470
-- -- Hyper theme
-- DashboardProjectTitle DashboardProjectTitleIcon DashboardProjectIcon
-- DashboardMruTitle DashboardMruIcon DashboardFiles DashboardShortCutIcon
-- -- Doome theme
-- DashboardDesc DashboardKey DashboardIcon DashboardShortCut


vim.cmd[[
	hi VertSplit    cterm=NONE ctermbg=235 guibg=#111115
	hi Split        cterm=NONE ctermbg=235 guibg=#111115

	"hi StatusLine   cterm=NONE ctermbg=black ctermfg=orange
	"hi StatusLineNC cterm=NONE ctermbg=black ctermfg=orange


	hi TablineFill guibg=#161616

	hi TablineSel gui=none
	hi TablineSel guifg=#AF4805
	hi TablineSel guibg=#161616
	hi TablineSel guibg=#0e0707

	hi Tabline gui=none
	hi Tabline guifg=#656565
	hi Tabline guibg=#161616

	hi StatusLine    gui=bold
	hi StatusLine    gui=none
	hi StatusLine    gui=none
	hi StatusLine    guibg=#161616
	hi StatusLine    guifg=#AF4805
	"hi StatusLine    guifg=#fb8500
	"hi StatusLine    guifg=#FF6500

	hi StatusLineWeak    guifg=#383838
	hi StatusLineWeak    guibg=#161616

	" not current?
	hi StatusLineNC  gui=NONE
	hi StatusLineNC  guibg=#141414
	hi StatusLineNC  guifg=#ED9455
]]

vim.cmd[[
	hi SpellBad guisp=#3C1616
	hi SpellBad guifg=#A34343
	hi SpellBad gui=underline
]]

vim.cmd[[
	hi ErrorMsg guifg=#ff99c8
	hi ErrorMsg guibg=NONE
	hi ErrorMsg gui=bold
]]

-- OilDir -> Directory
vim.cmd[[
	hi Directory guifg=#ffd76a
	hi Directory guifg=#ffe9a9
	hi Directory guifg=#ffe087
]]

local ColorTable = {
	props = {},
	new = function(self)
		local clone = {}
		for prop, fn in pairs(self) do if type(fn) ~= 'function' then clone[prop] = fn end end
		return setmetatable(clone, { __index = self, __call = self.fgbg })
	end,
	fgbg = function(self, fg, bg)
		self.props = {}
		self.props['fg'] = fg
		self.props['bg'] = bg
		return self
	end,
	bold = function(self) self.props['bold'] = true; return self end,
	t = function(self) return self.props end,
}
local cc = ColorTable:new()

vim.api.nvim_set_hl(0, 'Git', cc("#f14e32"):bold():t())
-- vim.api.nvim_set_hl(0, 'TelescopeBorder', cc('#99582a'):bold():t())
-- vim.api.nvim_set_hl(0, 'TelescopeBorder', cc('#bb9457'):bold():t())
-- vim.api.nvim_set_hl(0, 'TelescopeBorder', cc('#9f86c0'):bold():t())
-- vim.api.nvim_set_hl(0, 'TelescopeBorder', cc('#5e548e'):bold():t())
-- vim.api.nvim_set_hl(0, 'TelescopeBorder', cc('#231942'):bold():t())
vim.api.nvim_set_hl(0, 'TelescopeBorder',    cc('#202020'):bold():t())
vim.api.nvim_set_hl(0, 'TelescopeSelection', cc('#B5642F'):t())
vim.api.nvim_set_hl(0, 'TelescopeNormal',    cc('#AAAAAA'):t())
vim.api.nvim_set_hl(0, 'TelescopePromptNormal',    cc('#AAAAAA'):t())
vim.api.nvim_set_hl(0, 'TelescopePromptTitle',    cc('#AAAAAA'):t())



