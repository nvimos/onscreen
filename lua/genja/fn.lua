CONFIG = vim.fn.stdpath('config')


function Telescope_find_dirs()
	local te = require 'telescope.builtin'
	te.find_files({
		hidden = false,
		search_dirs = START_DIRS })
end


-- util
function FileExists(path)
	local stat = vim.loop.fs_stat(path)
	return stat ~= nil
end
function IsDir(path)
	local stat = vim.loop.fs_stat(path)
	return stat ~= nil and stat.type == 'directory'
end
function Dirname(path)
	return vim.fn.fnamemodify(path, ':h')
end
function Basename(path)
	return vim.fn.fnamemodify(path, ':t')
end
function Extensionname(path)
	return vim.fn.fnamemodify(path, ':e')
end

function IndexOf(arr, target)
	for i, value in ipairs(arr) do
		if value == target then
			return i
		end
	end
	return -1
end
function TableContains(arr, target)
	return IndexOf(arr, target) >= 1
end
function IsVideoExtension(ext)
	local video = {
		'mp4', 'mkv', 'avi', 'mpg',
		'mov', 'flv', 'f4v', 'vob',
		'wmv', '3gp', 'ogv', 'drc',
		'mpeg', 'webm', 'avchd', 'qt', }
	return TableContains(video, ext)
end
function JoinPaths(...)
	local aa = {}
	for i = 1, select("#", ...) do
		local a = select(i, ...)
		a, _ = a:gsub('[\\/]+$', '')
		table.insert(aa, a)
	end
    local separator = package.config:sub(1, 1) -- Get the OS-specific path separator
    -- return table.concat({...}, separator)
    return table.concat(aa, separator)
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
-- /util


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

function OsDependant(win, lin, mac, bsd, posix, other)
	if vim.fn.has("mac") == 1 then return mac
	elseif vim.fn.has("windows") == 1 then return win
	elseif vim.fn.has("linux") == 1 then return lin
	elseif vim.fn.has("bsd") == 1 then return bsd
	elseif vim.fn.has("posix") == 1 then return posix
	else return other
	end
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

'%[TD%]',
"web-dl", "webb", "webrip", "web",
"%d+.BRRip",
"%d+.BluRay",
"480p",
"720p",
"1080p",
"1440p",
"X[%.%s]26[45]",
"H[%.%s]26[45]",
"x26[45]",
"h26[45]",

"(HQ%s)*AC3[%s%.]DD[%.%d]*",

"dts%-hd",

"HQ[%s%.-]AC3",
"MA%s5.1",
"DDP5.1",
"DD5.1",
"DD2.0",

"ddp2", "ddp5", "dd2", "dd5", "ddp",
"10bit",   "aac2", "aaf",
"dts",

"ac3", "afg", "alfahd", "amcon", "amiable", "amzn",

'rerip',
"dvdscr", "HDDVD", "dvdrip", "(dvd)", "dvd",

"avi$",
"mkv$",
"mov$",
"mp4$",

"bae", "bdmf", "bdrip", "bigdoc",
"bluray", "bordure", "brrip", "cakes", "cinefile",
"clue", "cm8", "cmrg", "%[csi%]", "%[h33t%]", "d3fil3r", "d3g",
"debtvid",
"deimos", "demand", "diamond", "dimension", "disc", "divx",
"dl",  "dual",


"%.cam%.",
"%.limited%.",
"%.WS%.",
'%.torrent$',

"ebook", "elia", "ethel", "evo", "extras",
"ffndvd", "flux", "fqm", "ghosts", "haggis",
"hdrip", "hdtv", "hevc", "hive", "hmax", "%[hst%]",
"hulu", "hybris", "imbt", "internal", "ipt", "kacy",
"ktr", "lama", "m00tv", "majestic", "megusta",
"mp4", "msd", "naisu", "nogrp", "%[norar%]", "npw",
"ntb", "ntsc", "paleale", "part", "phase", "proof",
"psychd", "qix", "redblade", "remastered", "repack",
"reward",

"s01e02", "s01e03", "s01e04", "s01e05", "s01e06", "s01e07", "s01e08", "s01e09", "s01e10",
"sample", "screens",
"season",

"externe subs",
"subtitles",
"topaz", "trips", "uki", "usury", "video_ts",
"vodo", "vomit", "voxhd",

"s01", "s02", "s03", "s04", "s05", "s06", "s07", "s08", "s09", "s10",

"mp3", "aac",

"wiki", "wrb", "x0r",  "xlf",
"xvid",
"xvidhd",
"uncut",
"xxx",

"unrated.dc", "unrated",
}

function StripSceneTags(e)
	e = string.lower(e)
	for _, p in pairs(tags) do
		p = string.lower(p)
		e,_ = e:gsub(p, "")
	end
	e,_ = e:gsub('%.', " ")             -- dot to space
	e,_ = e:gsub('[%s%.]%(*%d%d%d%d%)*', " ") -- remove (year)
	e,_ = e:gsub("%s+", " ")            -- collapse spaces
	e = e:match("^%s*(.-)[%s/-]*$")     -- (1) strip leading spaces, trailing spaces, slash, hyphens
	e,_ = e:gsub('%s*%(%s*%)$', "")     -- strip empty ( )
	e,_ = e:gsub('%s%-[%w_]+$', "")     -- strip trailin -name
	e = e:match("^%s*(.-)[%s/-]*$")     -- (2) strip leading spaces, trailing spaces, slash, hyphens
	return e
end

-- local strip_test = {
-- 	["riddick"] = "Riddick.Unrated.DC.2013.1080p.WEB-DL.H264-PHD/",
-- 	["critical"] = "Critical.S01.720p.HDTV.x264-FaiLED/",
-- 	["jwf"] = "jwf",
-- 	["daddy's home"] = "Daddy's Home (2015) 720p BRRip HQ AC3 DD5.1 (Externe Subs)/",
-- 	['dallas buyers club'] = "Dallas.Buyers.Club.2013.720p.BluRay.x264-x0r/",
-- 	["dune drifter"] = "Dune.Drifter.2020.1080p.WEBRip.DD5.1.X.264-EVO/",
-- 	["eastern promises"] = "Eastern.Promises.2007.1080p.HDDVD.DTS.x264-DEFiNiTE [NORAR]/",
-- 	["ed wood"] = "Ed.Wood.1994.1080p.BluRay.X264-AMIABLE [NORAR]/",
-- 	["encanto"] = "Encanto.2021.1080p.WEB-DL.H264.DDP5.1-EVO/",
-- 	["mr brooks"] = "Mr.Brooks.2007.720p.BluRay.x264-x0r/",
-- 	["mute"] = "Mute.2018.720p.HDRip.X264.AC3-EVO/",
-- 	["nausicaa of the valley of the wind"] = "Nausicaa.Of.The.Valley.Of.The.Wind.1984.720p.BRRip.x264-x0r/",
-- 	["network"] = "Network.1976.720p.BRRip.x264-x0r/",
-- 	["once were warriors"] = "Once.Were.Warriors.1994.1080pBRRip.x264.AC3-m2g/",
-- 	["paul blart mall cop"] = "Paul.Blart.Mall.Cop.2009.720p.BluRay.DD5.1.x264-ChaoS/",
-- 	["perfume the story of a murderer"] = "Perfume.The.Story.of.a.Murderer.2006.720p.BluRay.x264-x0r/",
-- 	["leaving las vegas"] = "Leaving.Las.Vegas.1995.iNTERNAL.DVDRip.x264-REGRET/",
-- 	["finding neverland"] = "Finding.Neverland.2004.720.BRRip.x264-x0r/",
-- 	["strings"] = "Strings.2021.1080p.WEB-DL.DD5.1.H.264-CMRG/",
-- 	["super 8"] = "Super.8.2011.720.BluRay.x264-x0r/",
-- 	["the social network"] = "The Social Network 2010 1080p BluRay DTS-HD MA 5.1 x264-BluEvo/",
--  ['65 will1869'] = '65.2023.1080p.Cam.X264.Will1869/'
-- }
-- for i, e in pairs(strip_test) do
-- 	if not (i == StripSceneTags(e)) then
-- 		print('«'..i..'»' .. ' <want, got> '.. '«'..StripSceneTags(e)..'»'.. '   -- ' .. e)
-- 	end
-- end


