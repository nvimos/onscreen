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


local function sl(a, b) b=b or {}; return vim.api.nvim_eval_statusline(a, b).str end
local function with_hl(hiGroup, s) return  '%#' .. hiGroup .. '#' .. s .. '%*' end

local mode_map = {
	-- i = "",
	-- n = "",
	n = "norm",

	i = "ins",

	-- v = "vis",
	-- V = "vlin",
	-- [''] = "vblk",

	v = "  ☭ vis",
	V = "  ☭vlin",
	[''] = "  ☭vblk",

	c = "comm",
	t = "term",
	R = 'irep',
}
local function get_mode()
	local mode = vim.fn.mode()
	local mm = mode_map[mode] or '«' .. mode ..'»'
	return mm
end


vim.o.statusline = 'jwf'
vim.o.statusline = '%{%v:lua.Statusline()%}'

vim.g.genja_statusline_rune = false

vim.cmd[[:hi User1 term=inverse,bold cterm=inverse,bold ctermfg=red]]



-- %-0{minwid}.{maxwid}{item}
function Statusline()
	local sline , _M = '', ''
	local _rune, _pos = '', ''
	local _showcmd, _file
	local _os

	_M = string.format('%1s', sl('%M'))
	local _hwq = sl('%h%w%q ')
	local _ro = sl('%R')


	if _hwq then _ro = '' end

	if _M == '-' then _M = ' ' end

	if vim.g.genja_statusline_rune then
		_rune = ' rune{%03b %04B}'
		_pos = ' pos{%04o %O}'
	end

	_showcmd = sl('%S')

	_file = vim.fn.fnamemodify(sl('%.38f'), ':r')
	-- _file = _file:gsub('[\\/]', '/')
	_file = _file:gsub('[\\/]', '⧸')

	if vim.fn.has("Windows") then _os = '󰖳' else _os = '' end

	local _ft = vim.bo['filetype']
	local _frm = vim.bo['fileformat']
	local _fenc =  vim.bo['fileencoding']

	-- _fi = join({'(', _ft, _frm, _fenc, ')'}, '󰥛')
	local _fi = join({_ft, _frm, _fenc}, ' ')

	local _bufnr = '·' .. sl('%n')

	local elts = {
		-- '',
		-- '·',
		string.format('%7s', get_mode()),
		' ',
		-- "«",
		-- "»",

		'%a',

		_M, _hwq, _file, -- file/buffer name and ro status
		_bufnr,
		' %<',

		_fi, '%<', _ro,

		-- '%=',
		-- '%=',


		-- '%=',
		-- '%=',
		-- 'k:%k',

		'%=',
		_os,
		_showcmd,

		_rune,
		_pos,


		'%3cc %3lʟ',
		' ',
		'%-3L␤ %P',

		'',
	}
	return join(elts)
end

function join(t, sep)
	sep = sep or ''
	local sline = t[1]
	for i=2, #t do
		e = t[i]
		if e == nil then e = '' end
		sline = sline .. sep .. tostring(e)
	end
	return sline
end

function Statusline2()
	return "S0"
end

function Statusline1()
	return 'KAKE. and sodomy'
end


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
