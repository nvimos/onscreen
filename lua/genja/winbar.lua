-- vim.api.nvim_set_hl(0, 'WinBarPath',     { bg = '#010101', fg = '#363636' })
-- vim.api.nvim_set_hl(0, 'WinBarModified', { bg = '#010101', fg = '#fb8500' })
-- vim.o.winbar = "%{%v:lua.require'genja.winbar'()%}"

vim.cmd[[
hi WinBarModified guibg=#010101
hi WinBarModified guifg=#fb8500

hi WinBarPath     guibg=#010101
hi WinBarPath     guibg=#0E0707
hi WinBarPath     guifg=#363636
hi WinBarPath     guifg=#545454
]]



local function sl(a, b) b=b or {}; return vim.api.nvim_eval_statusline(a, b).str end
local function hl(hiGroup, s) return  '%#' .. hiGroup .. '#' .. s .. '%*' end

function Winbar()
	local fname = vim.fn.fnamemodify(sl('%t'), ':r')  -- top of path, no extension
	if fname == "" then
		local buf = vim.api.nvim_get_current_buf()
		local ft = vim.api.nvim_buf_get_option(buf, 'filetype')
		fname = ft
	end

	return ''
	-- ..with_hl('WinBarPath',     sl(''))
	..hl('WinBarPath',     sl(' '))

	..hl('WinBarPath',     fname)
	..hl('WinBarModified', sl('%M')) -- modified flag
	..hl('WinBarPath',     sl('%r')) -- read-only [RO]
	..hl('WinBarPath',     sl('%q')) -- [quickfix list]
	-- ..with_hl('WinBarPath',     fname..sl('%R')) -- top of path
	-- ..with_hl('WinBarPath',     sl(''))
end



--[[

	https://github.com/ojroques/nvim-hardline

]]

-- local M = {}
-- setmetatable(M, { __call = winbar})
-- return M
--return winbar


--[[
:help statusline
	(...)
	item meaning
	f S
	(...)
]]
--[[
local function _winbar()
	local file_path = vim.api.nvim_eval_statusline('%f', {}).str
	local modified = vim.api.nvim_eval_statusline('%M', {}).str == '+' and '⊚' or ''
	file_path = file_path:gsub('/', ' ➤ ')
	return '%#WinBarPath#' .. file_path .. '%*'
		.. '%#WinBarModified#' .. modified .. '%*'
end
]]


--[[
--
--function M.eval()
--    local winbar = ''
--    -- do stuff.........
--      winbar = join_status_line(winbar, 'WinBarPath', file_path)
--      winbar = join_status_line(winbar, 'WinBarModified', modified)
--
--     return winbar
--end
--]]
--
----[[
--local M = {}
--
--local winbar_filetype_exclude = {
--    "help",
--    "startify",
--    "dashboard",
--    "packer",
--    "neogitstatus",
--    "NvimTree",
--    "Trouble",
--    "alpha",
--    "lir",
--    "Outline",
--    "spectre_panel",
--    "toggleterm",
--}
--
---- #4A3E4B
--vim.api.nvim_set_hl(0, 'WinBarPath', { bg = '#4A3E4B', fg = '#C1ADC4' })
--vim.api.nvim_set_hl(0, 'WinBarModified', { bg = '#dedede', fg = '#ff3838' })
--
--function M.statusline()
--
--    if vim.tbl_contains(winbar_filetype_exclude, vim.bo.filetype) then
--        return ""
--    end
--
--    local file_path = vim.api.nvim_eval_statusline('%F', {}).str
--    -- local modified = vim.api.nvim_eval_statusline('%M', {}).str == '+' and '⊚' or ''
--    local modified = vim.api.nvim_eval_statusline('%m', {}).str
--    local buffer_number = vim.api.nvim_eval_statusline('%n', {}).str
--    local last_change = vim.fn.strftime('%a, %b %d %Y - %H:%M', vim.fn.getftime(vim.fn.expand('%')))
--
--    file_path = file_path:gsub('/', ' ➤ ')
--    file_path = file_path:gsub('~', ' $HOME')
--
--    return '%#WinBarPath#'
--     .. ' [' .. buffer_number .. '] '
--     .. file_path .. ' '
--     .. '%*'
--     -- .. '%#WinBarModified#'
--     .. ' ' .. modified
--     .. '%*'
--     .. 'Modified: ' .. last_change
--end
--
--return M
--]]
