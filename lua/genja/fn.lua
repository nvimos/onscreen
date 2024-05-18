CONFIG = vim.fn.stdpath('config')


function Telescope_find_dirs()
	local te = require 'telescope.builtin'
	te.find_files({
		hidden = false,
		search_dirs = START_DIRS })
end


function Myleige(g, l)
	vim.g.mapleader      = g or [[\]]
	vim.g.maplocalleader = l or [[ ]]
end

local UserComm = vim.api.nvim_create_user_command

function Cd(to)
	vim.api.nvim_call_function("chdir", { to }); vim.cmd [[pwd]]
end

UserComm('Winfo', function(c)
	local zzz = vim.api.nvim_get_current_buf()
	-- print(vim.api.nvim_buf_get_name(z))
	-- print(vim.inspect(vim.bo.fenc))
	--print(vim.inspect(vim.bo.filetype))
	info = {}
	info.name = vim.fn.bufname()
	info.modified = vim.fn.getbufvar(0, "&modified") == 1
	info.modified_count = vim.fn.getbufvar(0, "&mod")
	info.line_count = vim.fn.line("$")
	info.filetype = vim.bo.filetype
	info.encoding = vim.bo.fenc
	-- :::nvim_buf_get_var
	print(vim.inspect(info))
end, { desc = 'gather info about current window/buffer' })

UserComm('Nospell', function(c) vim.o.spell = not vim.o.spell end, { desc = "toggle spelling", bar = true })
UserComm('ToggleSpell', function(c) vim.o.spell = not vim.o.spell end, { desc = "toggle spelling", bar = true })
UserComm('ToggleList', function(c) vim.o.list = not vim.o.list end, { desc = "toggle listchars", bar = true })
UserComm('VimStatusline', function(c) return 'VimStatusline()' end, { desc = "just a meme", bar = true })


-- complete = function() return {'a', 'x', 'c'} end
UserComm('Woot', function(c) print(vim.inspect(c)) end, { nargs = '?', force = true, desc = "What is a function?" })
UserComm('Woot', function(c) print(vim.inspect(c)) end,
	{ nargs = '*', force = true, desc = "What is a function?", bar = true })

function Close_nerdtree_wins() -- <space> ee | e. | et
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		local ft = vim.api.nvim_buf_get_option(buf, 'filetype')
		if ft == 'nerdtree' then
			vim.api.nvim_win_close(win, true)
		end
	end
end

function CheckAndRunMRU() -- <S-F1>
	if vim.bo.filetype == "mru" then
		vim.cmd("quit")
	else
		-- os.execute("A:\\bin\\uniq-vim-mru-files.exe")
		-- vim.cmd("MRU")
		vim.fn.jobstart("A:\\bin\\uniq-vim-mru-files.exe", {
			on_exit = function()
				vim.cmd("MRU")
			end
		})
	end
end

UserComm('CycleDirs', function() CycleDirs() end, {})
UserComm('CDconfig', function() Cd(vim.fn.stdpath('config')) end, { desc = "cd stdpath(config)", bar = true })
UserComm('CDconfigg', function() Cd(vim.fn.stdpath('config') .. '/lua/genja') end,
	{ desc = "cd ()/lua/genja", bar = true })
UserComm('CD', function(c) Cd(c.fargs) end, { nargs = '*', desc = "cd ?", bar = true })


--[[ from help, other people, etc ]]
                                     --

UserComm('HiTest', function() vim.cmd [[:so $VIMRUNTIME/syntax/hitest.vim]] end, {})


function JoinPaths(...)
    local separator = package.config:sub(1, 1) -- Get the OS-specific path separator
    return table.concat({...}, separator)
end

function Join(t, sep)
	sep = sep or ''
	local sline = t[1]
	for i=2, #t do
		e = t[i]
		if e == nil then e = '' end
		sline = sline .. sep .. tostring(e)
	end
	return sline
end

function Split(inputstr, sep)
    if sep == nil then
        sep = "%s" -- Default separator is any whitespace
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end


--[[ roll your own ]]
                      --
local _cdp = 1
function CycleDirs(dirlist)
	dirlist = dirlist or START_DIRS
	local z , ok = pcall(function()
		-- handle error?
		Cd(dirlist[_cdp]);
	end)
	_cdp = _cdp + 1;
	if _cdp > #dirlist then
		_cdp = 1;
	end
end

function is_started_from_windows_shell()
	return [[nvim.exe]] == vim.fn.readdir('.', [[v:val =~ 'nvim.exe$']])
		[1]
end



local tags = {
"x264", "x265",
"264",
"-name",
"10bit",  "480p", "720p", "aac2", "aaf",
"ac3", "afg", "alfahd", "amcon", "amiable", "amzn",
"avi$", "bae", "bdmf", "bdrip", "bigdoc",
"bipolar", "bluray", "bordure", "brrip", "cakes", "cinefile",
"clue", "cm8", "cmrg", "\\[csi][h33t]", "d3fil3r", "d3g",
"dd2", "dd5", "ddp", "ddp2", "ddp5", "debtvid",
"deimos", "demand", "diamond", "dimension", "disc", "divx",
"dl", "dts", "dual", "(dvd)", "dvd", "dvdrip",
"dvdscr", "ebook", "elia", "ethel", "evo", "extras",
"ffndvd", "flux", "fqm", "ghosts", "h264", "haggis",
"hdrip", "hdtv", "hevc", "hive", "hmax", "\\[hst]",
"hulu", "hybris", "imbt", "internal", "ipt", "kacy",
"ktr", "lama", "m00tv", "majestic", "megusta", "mp3",
"mp4", "msd", "naisu", "nogrp", "%[norar%]", "npw",
"ntb", "ntsc", "paleale", "part", "phase", "proof",
"psychd", "qix", "redblade", "remastered", "repack",
"reward", "river", "rovers", "s01e02", "s01e03", "s01e04",
"s01e05", "s01e06", "s01e07", "s01e08", "s01e09", "s01e10",
"s03", "s04", "s05", "sadpanda", "sample", "screens",
"season", "sinners", "stories", "strife", "subs", "subtitles",
"\\[tg", "topaz", "trips", "uki", "usury", "video_ts",
"vodo", "vomit", "voxhd", "web", "webb", "webrip",
"wiki", "wrb", "x0r",  "xlf",
"xvid",
"xvidhd",
"xxx",
}

function  StripSceneTags(e)
	e = string.lower(e)
	for _, p in pairs(tags) do
		e,_ = e:gsub(p, "")
	end
	e,_ = e:gsub('%.', " ")
	e,_ = e:gsub('%d%d%d%d', " ")
	e,_ = e:gsub('-$', "")
	e,_ = e:gsub("%s+", " ")

	e = e:match("^%s*(.-)%s*$")
	return e
end
