-- [[ʟ %l/%L c %c]]

-- vim.o.statusline = ' %f %m%r%h%w%y [%{&fileencoding}] [%{&fileformat}]'
-- vim.o.statusline = ' %f %m%r%h%w%y [%{&fileencoding}] [%{&fileformat}]'

--[[
	Each status line item (%) is of the form:
	All fields except the {item} are optional.
	  %-0{minwid}.{maxwid}{item}
	  %= alignment / splitter
	  %< where to truncate
	  %# set highlight group
	  %* ?? takes value from minwid? diff is applied to StatusLineNC? see hl-User1..9
	  %* ?? restore to normal
	  %0* restore to normal
	Empty groups like this will disappear if no flags are set
	:set statusline=...%(\ [%M%R%H]%)...
	:redrawstatus will force an update
]]

vim.o.statusline = 'jwf'
vim.o.statusline = '%{%v:lua.Statusline()%}'

vim.o.tabline = '%{%v:lua.Tabline()%}'

vim.g.genja_statusline_rune = false -- display percise information about the cursor position


local function sl(a, b) b=b or {}; return vim.api.nvim_eval_statusline(a, b).str end
local function hl(hiGroup, s) return  '%#' .. hiGroup .. '#' .. s .. '%*' end

local DOTm = '·'
local Space = ' '
local Empty = ''

local Tabsep = '' -- '%=%='
local Dirseparator = '󰞱' -- '⧸' '/'

local function get_os_icon()
	return OsDependant( '󰖳', '', '', 'bsd', 'posix', 'other')
end

-- i = "", n = "", v = "vis", V = "vlin", [''] = "vblk",
local mode_map = {
	n = "norm", i = "ins",
	v = "  ☭ vis", V = "  ☭vlin", [''] = "  ☭vblk",
	c = "comm", t = "term", R = 'irep', }
local function get_mode()
	local mode = vim.fn.mode()
	return mode_map[mode]
	    or ('«' .. mode ..'»')
end

local wincount_label = {
	[1] =   '⋅', [2] =   '²', [3] =   '³', [4] =   '⁴', [5] =   '⁵',
	[6] =   '⁶', [7] =   '⁷', [8] =   '⁸', [9] =   '⁹', [10] =  '¹⁰'}
local function tl_close_tab_button(tabnum, tabpage)
	local wins = vim.api.nvim_tabpage_list_wins(tabpage)
	local x = '󱀬'; if wincount_label[#wins] then x = wincount_label[#wins] end
	return '%'.. tabnum .. 'X'..x
end

local function tl_hilite(tabpage)
	local tabnum = vim.api.nvim_tabpage_get_number(tabpage)
	local hilite = '%#TabLine#'
	if tabnum == vim.fn.tabpagenr() then
		hilite = '%#TabLineSel#' end
	return hilite
end

local rename_buf_fns = {
	--[[ function(nam, buf) return nam end, ]]--
	function(nam, buf)
		local z = nam
		if 'oil' == vim.api.nvim_buf_get_option(buf, 'filetype') then
			z = vim.api.nvim_buf_get_name(buf)
			z = z:gsub([[/$]], '') -- want last dir (:path:tail)
			z = 'o:'..vim.fn.fnamemodify( z, ':p:t')
		end
		return z
	end,
}
local tl_bufname = function(tabpage, charsleft)
	local win = vim.api.nvim_tabpage_get_win(tabpage)
	local buf = vim.api.nvim_win_get_buf(win)
	local bn = vim.fn.fnamemodify( vim.api.nvim_buf_get_name(buf), ':t:r')
	if bn == Empty then
		bn = vim.api.nvim_buf_get_option(buf, 'filetype'); end
	if bn == Empty then
		bn = 'none'; end
	for _, tr in pairs(rename_buf_fns) do
		bn = tr(bn, buf)
	end
	local tabnum = vim.api.nvim_tabpage_get_number(tabpage)
	local distance = vim.fn.abs(vim.fn.tabpagenr() - tabnum)
	-- if tabnum == 1 then
		-- bn = ' ' .. bn
	-- end
	if charsleft < 0 then
		if distance > 3 then
			if #bn > 3 then
				return bn:sub(1, 3) .. '…'
			end
		elseif distance > 2 then
			if #bn > 4 then
				return bn:sub(1, 4) .. '…'
			end
		elseif distance > 1 then
			if #bn > 12 then
				return bn:sub(1, 12) .. '…'
			end
		end
	end
	return bn
end

local function tl_separator(tabpage, charsleft)
	local tabnum = vim.api.nvim_tabpage_get_number(tabpage)
	local distance = vim.fn.abs(vim.fn.tabpagenr() - tabnum)
	if charsleft < 0 then
		if distance > 2 then
			return ''
		elseif distance > 1 then
			return Tabsep..Space
		end
	end
	return Space..Tabsep..Space
end

local total = 0
local function count_len(str)
	total = total + #str
	return str
end

local Triangle_upper = ' ' -- must use Nerd Font ?
Triangle_upper = '\\'
Triangle_upper = ' '




local function tablabels(charsleft)
	-- local tl = {  };
	total = 0
	local tl = { hl('WinBarPath', Triangle_upper ), '' };
	total = total + 2 -- triangle, close button
	for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
		local tabnum = vim.api.nvim_tabpage_get_number(tabpage)
		local bn = tl_bufname(tabpage, charsleft)
		local sp = tl_separator(tabpage, charsleft)
		table.insert(tl, tl_hilite(tabpage))
		table.insert(tl, '%' .. tabnum .. 'T') -- this is only necessary if we use statusline %items ? - but we resolve them manually with sl()...
		table.insert(tl, bn)
		table.insert(tl, tl_close_tab_button(tabnum, tabpage))
		table.insert(tl, hl('StatusLineWeak', sp))
		count_len(sp) -- tab separator
		count_len(bn)  -- tab label
		count_len('x') -- close button
    end
	table.insert(tl, '%<')
	table.insert(tl, '%<')
	table.insert(tl, '%#TabLineFill#%T')
	table.insert(tl, '%=%#TabLine#%999X󱀬')
	return tl
end

function ctot(Ww)
	if false then
		local extra = 6 -- :E+T:t
		extra = extra + 2 -- mode
		extra = extra + #tostring(Ww) + #tostring(total) + #tostring(Ww-total)
		extra = extra + #tostring(Ww - total - extra)
		return extra
	end
	return 0
end

local Ww = 0
function Tabline()
	local M = (vim.fn.mode()):sub(1,1)
	local N = ''
	if M == 'c' then
		Ww = Ww
	else
		-- Ww = tonumber(vim.api.nvim_command_output("echo &columns")) or 0
		Ww = tonumber(vim.o.columns) or 0
	end
	local tl = tablabels(0)
	-- local Total = total
	-- local Dotal = 0
	local extra = ctot(Ww)
	local diff = Ww - total - extra
	if diff > 0 then
		-- N = M..'.'..Ww..':E'..extra..'+T'..Total..'t'..Dotal..':'..(diff)
		return N..Join(tl)
	else
		tl = tablabels(diff)
		-- Dotal = total
		diff = Ww - total - extra
		-- N = M..'.'..Ww..':E'..extra..'+T'..Total..'t'..Dotal..':'..(diff)
		return N..Join(tl)
	end
end

function Statusline()
	local sline = ''

	local _mod = string.format('%1s', sl('%M'))
	if _mod == '-' then _mod = ' ' end

	local _hwq, _ro = sl('%h%w%q '), sl('%R')
	if _hwq then _ro = '' end

	local _rune, _pos = '', ''
	if vim.g.genja_statusline_rune then
		_rune = ' rune{%03b %04B}'
		_pos = ' pos{%04o %O}'
	end

	local _showcmd, _file = sl('%S'), ''
	_file = sl('%.50f'):gsub('[~\\/]', '/')
	_file = vim.fn.fnamemodify(_file, ':r') -- no extension
	_file = Join(Split(_file, '/'), hl('StatusLineWeak', Dirseparator))

	local _ft_fmt_enc =  Join({ vim.bo['filetype'], vim.bo['fileformat'], vim.bo['fileencoding']}, ' ')
	local _mode = string.format('%7s', get_mode())

	local elts = {

		hl('StatusLineWeak', _mode..Space..DOTm..sl('%n')..DOTm..Space), -- %n is bufnr

		_file, _mod, _hwq, -- file/buffer name and ro status
		' %<',
		'%=',
		'%a', -- argument list status
		Space,
		'%<',
		hl('StatuslineWeak', _ft_fmt_enc),
		'%<',
		_ro,
		hl('StatusLineWeak', Space..DOTm..Space),

		get_os_icon(),
		_showcmd,

		_rune,
		_pos,

		'%3cc %3lʟ', Space, '%-3L␤ %P', -- column line total lines percentage
	}
	return Join(elts)
end




-- vim.cmd[[:hi User1 term=inverse,bold cterm=inverse,bold ctermfg=red]]
		--' 󰥛%n',
		-- '󰏢%n',

--[[ examples from docs ]]--
-- vim.cmd[[
-- 	  :function VarExists(var, val)
-- 	  :   if exists(a:var) | return a:val | else | return '' | endif
-- 	  :endfunction
-- ]]
-- vim.o.statusline=[[...%r%{VarExists('b:gzflag','\ [GZ]')}%h...]]
-- vim.o.statusline=[[%<%f%=\ [%1*%M%*%n%R%H]\ %-19(%3l,%02c%03V%)%O'%02b']]
-- vim.o.statusline=[[%<%f%h%m%r%=%b\ 0x%B\ \ %l,%c%V\ %P]]
-- vim.o.statusline=[[%<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P]]

--[[
local filename = vim.fn.expand('%:t') -- api.nvim_call_function('expand', {'%f'})

local filetype = vim.bo.ft --> Get vim filetype using nvim api


local file = bufname.get_buffer_name()


if vim.bo.modifiable and vim.bo.modified then
	return '+' .. space
end


if vim.bo.filetype == 'help' then return '' end
if vim.bo.readonly == true then return ' ' end

]]


--[[
local icons = require('tables._icons')
local TrimmedDirectory = function(dir)
	local home = os.getenv('HOME') or os.getenv('Userprofile')
	local _, index = string.find(dir, home, 1)
	if index ~= nil and index ~= string.len(dir) then
		if string.len(dir) > 30 then
			dir = '..' .. string.sub(dir, 30)
		end
		return string.gsub(dir, home, '~')
	end
	return dir
end
]]

--[[
local getTabLabel = function(n)
	local current_win = api.nvim_tabpage_get_win(n)
	local current_buf = api.nvim_win_get_buf(current_win)
	local file_name = api.nvim_buf_get_name(current_buf)
	if string.find(file_name, 'term://') ~= nil then
		return ' ' .. api.nvim_call_function('fnamemodify', { file_name, ':p:t' })
	end
	file_name = api.nvim_call_function('fnamemodify', { file_name, ':p:t' })
	if file_name == '' then
		return 'No Name'
	end
	local icon = icons.deviconTable[file_name]
	if icon ~= nil then
		return icon .. space .. file_name
	end
	return file_name
end
]]

--[[

local set_colours = function()
	--SET TABLINE COLOURS
	cmd('hi TabLineSel          gui=Bold guibg=#8ec07c guifg=#292929')
	cmd('hi TabLineSelSeparator gui=bold guifg=#8ec07c')
	cmd('hi TabLine                      guibg=#504945 guifg=#b8b894 gui=None')
	cmd('hi TabLineSeparator                           guifg=#504945')
	cmd('hi TabLineFill                  guibg=None gui=None')
end
]]


	-- local tab_list = api.nvim_list_tabpages()
	-- local current_tab = api.nvim_get_current_tabpage()
	-- for _, val in ipairs(tab_list) do
	-- 	local file_name = getTabLabel(val)

-- local modes = require('tables._modes')
-- 	local mode = api.nvim_get_mode()['mode']
-- 		.. modes.current_mode[mode]


-- [[  ICONS ]]--
-- local M = {}
-- local api = vim.api
-- local devicons = require('tables._icons')
-- local icon
-- local file_name
-- local space = ' '
-- function M.get_file_icon(bufnr)
-- 	--NOTE: Rather than use our internal bufname object
-- 	--we use full filename to detect terminal windows
-- 	file_name = api.nvim_buf_get_name(bufnr or 0)
-- 	if string.find(file_name, 'term://') ~= nil then
-- 		icon = ''..space
-- 		return icon
-- 	end
-- 	icon = devicons.deviconTable[file_name]
-- 	if icon ~= nil then
-- 		return icon .. space
-- 	else
-- 		return ''
-- 	end
-- end
-- return M



-- local M = {}
-- local git_branch
-- local space = ' '
--
-- -- os specific path separator
-- local sep = package.config:sub(1, 1)
--
-- -- returns full path to git directory for current directory
-- local function find_git_dir()
-- 	-- get file dir so we can search from that dir
-- 	local file_dir = vim.fn.expand('%:p:h') .. ';'
-- 	-- find .git/ folder genaral case
-- 	local git_dir = vim.fn.finddir('.git', file_dir)
-- 	-- find .git file in case of submodules or any other case git dir is in
-- 	-- any other place than .git/
-- 	local git_file = vim.fn.findfile('.git', file_dir)
-- 	-- for some weird reason findfile gives relative path so expand it to fullpath
-- 	if #git_file > 0 then
-- 		git_file = vim.fn.fnamemodify(git_file, ':p')
-- 	end
-- 	if #git_file > #git_dir then
-- 		-- separate git-dir or submodule is used
-- 		local file = io.open(git_file)
-- 		git_dir = file:read()
-- 		git_dir = git_dir:match('gitdir: (.+)$')
-- 		file:close()
-- 		-- submodule / relative file path
-- 		if git_dir:sub(1, 1) ~= sep and not git_dir:match('^%a:.*$') then
-- 			git_dir = git_file:match('(.*).git') .. git_dir
-- 		end
-- 	end
-- 	return git_dir
-- end
--
-- -- sets git_branch veriable to branch name or commit hash if not on branch
-- local function get_git_head(head_file)
-- 	local f_head = io.open(head_file)
-- 	if f_head then
-- 		local HEAD = f_head:read()
-- 		f_head:close()
-- 		local branch = HEAD:match('ref: refs/heads/(.+)$')
-- 		if branch then
-- 			git_branch = branch
-- 		else
-- 			git_branch = HEAD:sub(1, 6)
-- 		end
-- 	end
-- 	return nil
-- end
--
-- -- event watcher to watch head file
-- local file_changed = vim.loop.new_fs_event()
-- local function watch_head()
-- 	file_changed:stop()
-- 	local git_dir = find_git_dir()
-- 	if #git_dir > 0 then
-- 		local head_file = git_dir .. sep .. 'HEAD'
-- 		get_git_head(head_file)
-- 		file_changed:start(
-- 			head_file,
-- 			{},
-- 			vim.schedule_wrap(function()
-- 				-- reset file-watch
-- 				watch_head()
-- 			end)
-- 		)
-- 	else
-- 		-- set to nil when git dir was not found
-- 		git_branch = nil
-- 	end
-- end
--
-- -- returns the git_branch value to be shown on statusline
-- function M.branch()
-- 	if not git_branch or #git_branch == 0 then
-- 		return ''
-- 	end
-- 	local icon = ''
-- 	return icon .. space .. git_branch
-- end
--
-- -- run watch head on load so branch is present when component is loaded
-- watch_head()
--
-- return M

-- 'tabline' option.  Additionally, the |tabpagebuflist()|, |tabpagenr()| and
-- |tabpagewinnr()| functions are useful.
--[[
	function MyTabLine()
	  let s = ''
	  for i in range(tabpagenr('$'))
	    " select the highlighting
	    if i + 1 == tabpagenr()
	      let s ..= '%#TabLineSel#'
	    else
	      let s ..= '%#TabLine#'
	    endif
	    " set the tab page number (for mouse clicks)
	    let s ..= '%' .. (i + 1) .. 'T'
	    " the label is made by MyTabLabel()
	    let s ..= ' %{MyTabLabel(' .. (i + 1) .. ')} '
	  endfor
	  " after the last tab fill with TabLineFill and reset tab page nr
	  let s ..= '%#TabLineFill#%T'
	  " right-align the label to close the current tab page
	  if tabpagenr('$') > 1
	    let s ..= '%=%#TabLine#%999Xclose'
	  endif
	  return s
	endfunction
]]


-- local M = {}
-- -- Mode Prompt Table
-- M.current_mode = setmetatable({
-- 	['n'] = 'N',
-- 	['no'] = 'N·Operator Pending',
-- 	['v'] = 'V',
-- 	['V'] = 'V',
-- 	['^V'] = 'V',
-- 	['s'] = 'Select',
-- 	['S'] = 'S·Line',
-- 	['^S'] = 'S·Block',
-- 	['i'] = 'I',
-- 	['ic'] = 'I',
-- 	['ix'] = 'I',
-- 	['R'] = 'Replace',
-- 	['Rv'] = 'V·Replace',
-- 	['c'] = 'C',
-- 	['cv'] = 'Vim Ex',
-- 	['ce'] = 'Ex',
-- 	['r'] = 'Prompt',
-- 	['rm'] = 'More',
-- 	['r?'] = 'Confirm',
-- 	['!'] = 'Shell',
-- 	['t'] = 'T',
-- }, {
-- 	-- fix weird issues
-- 	__index = function(_, _)
-- 		return 'V·Block'
-- 	end,
-- })
-- return M

-- local M = {}
-- local extensionTable = {
-- 	-- Exact Match
-- 	['gruntfile.coffee'] = '',
-- 	['gruntfile.js'] = '',
-- 	['gruntfile.ls'] = '',
-- 	['gulpfile.coffee'] = '',
-- 	['gulpfile.js'] = '',
-- 	['gulpfile.ls'] = '',
-- 	['mix.lock'] = '',
-- 	['dropbox'] = '',
-- 	['.ds_store'] = '',
-- 	['.gitconfig'] = '',
-- 	['.gitignore'] = '',
-- 	['.gitlab-ci.yml'] = '',
-- 	['.bashrc'] = '',
-- 	['.zshrc'] = '',
-- 	['.vimrc'] = '',
-- 	['.gvimrc'] = '',
-- 	['_vimrc'] = '',
-- 	['_gvimrc'] = '',
-- 	['.bashprofile'] = '',
-- 	['favicon.ico'] = '',
-- 	['license'] = '',
-- 	['node_modules'] = '',
-- 	['react.jsx'] = '',
-- 	['procfile'] = '',
-- 	['dockerfile'] = '',
-- 	['docker-compose.yml'] = '',
-- 	-- Extension
-- 	['styl'] = '',
-- 	['sass'] = '',
-- 	['scss'] = '',
-- 	['htm'] = '',
-- 	['html'] = '',
-- 	['slim'] = '',
-- 	['ejs'] = '',
-- 	['css'] = '',
-- 	['less'] = '',
-- 	['md'] = '',
-- 	['mdx'] = '',
-- 	['markdown'] = '',
-- 	['rmd'] = '',
-- 	['json'] = '',
-- 	['js'] = '',
-- 	['mjs'] = '',
-- 	['jsx'] = '',
-- 	['rb'] = '',
-- 	['php'] = '',
-- 	['py'] = '',
-- 	['pyc'] = '',
-- 	['pyo'] = '',
-- 	['pyd'] = '',
-- 	['coffee'] = '',
-- 	['mustache'] = '',
-- 	['hbs'] = '',
-- 	['conf'] = '',
-- 	['ini'] = '',
-- 	['yml'] = '',
-- 	['yaml'] = '',
-- 	['toml'] = '',
-- 	['bat'] = '',
-- 	['jpg'] = '',
-- 	['jpeg'] = '',
-- 	['bmp'] = '',
-- 	['png'] = '',
-- 	['gif'] = '',
-- 	['ico'] = '',
-- 	['twig'] = '',
-- 	['cpp'] = '',
-- 	['c++'] = '',
-- 	['cxx'] = '',
-- 	['cc'] = '',
-- 	['cp'] = '',
-- 	['c'] = '',
-- 	['cs'] = '',
-- 	['h'] = '',
-- 	['hh'] = '',
-- 	['hpp'] = '',
-- 	['hxx'] = '',
-- 	['hs'] = '',
-- 	['lhs'] = '',
-- 	['lua'] = '',
-- 	['java'] = '',
-- 	['sh'] = '',
-- 	['fish'] = '',
-- 	['bash'] = '',
-- 	['zsh'] = '',
-- 	['ksh'] = '',
-- 	['csh'] = '',
-- 	['awk'] = '',
-- 	['ps1'] = '',
-- 	['ml'] = 'λ',
-- 	['mli'] = 'λ',
-- 	['diff'] = '',
-- 	['db'] = '',
-- 	['sql'] = '',
-- 	['dump'] = '',
-- 	['clj'] = '',
-- 	['cljc'] = '',
-- 	['cljs'] = '',
-- 	['edn'] = '',
-- 	['scala'] = '',
-- 	['go'] = '',
-- 	['dart'] = '',
-- 	['xul'] = '',
-- 	['sln'] = '',
-- 	['suo'] = '',
-- 	['pl'] = '',
-- 	['pm'] = '',
-- 	['t'] = '',
-- 	['rss'] = '',
-- 	['f#'] = '',
-- 	['fsscript'] = '',
-- 	['fsx'] = '',
-- 	['fs'] = '',
-- 	['fsi'] = '',
-- 	['rs'] = '',
-- 	['rlib'] = '',
-- 	['d'] = '',
-- 	['erl'] = '',
-- 	['hrl'] = '',
-- 	['ex'] = '',
-- 	['exs'] = '',
-- 	['eex'] = '',
-- 	['leex'] = '',
-- 	['vim'] = '',
-- 	['ai'] = '',
-- 	['psd'] = '',
-- 	['psb'] = '',
-- 	['ts'] = '',
-- 	['tsx'] = '',
-- 	['jl'] = '',
-- 	['pp'] = '',
-- 	['vue'] = '﵂',
-- 	['elm'] = '',
-- 	['swift'] = '',
-- 	['xcplayground'] = '',
-- }
-- M.deviconTable = setmetatable(extensionTable, {
-- 	__index = function(extensionTable, key)
-- 		local i = string.find(key, '[.*]')
-- 		if i ~= nil then
-- 			return extensionTable[string.sub(key, i + 1)]
-- 		end
-- 	end,
-- })
-- return M

		-- '',
		-- '·',

	-- [1] = '⋅',
	-- [1] = '',
	-- [2] = '⚇',
	-- [3] = '󰮍',
	-- [2] = ':',
	-- [3] = '󰇘',
	-- [4] = '⦙',
	-- [5] = '∺',
	-- [6] = '󱗾',
	-- [7] = '󱗿',
	-- [8] = '󱗽',
	-- [9] = '󱗼',
	----

	-- [2] = '󱂉',
	-- [3] = '󱂊',
	-- [4] = '󱂋',
	-- [5] = 'Ⅴ',
	-- [6] = '󱂍',

	-- [1] =   '¹',

	-- [1] =   '¹',

