UserComm('WootA', function(c) print(vim.inspect(c)) end, { nargs = '*', force = true, desc = "What is a function?", bar = true })
UserComm('WootB', function(c) print(vim.inspect(c)) end, { nargs = '?', force = true, desc = "What is a function?" })

UserComm('PurgeShada', function()
	local shada_path = vim.fn.stdpath('data') .. '/shada/'
	local tmp_files = vim.fn.glob(shada_path .. '*.tmp*', true, true)
	for _, file in ipairs(tmp_files) do
		os.remove(file)
	end
	print('Cleared ' .. #tmp_files .. ' temporary ShaDa files')
end, {})

UserComm('Winfo', function(c)
	local zzz = vim.api.nvim_get_current_buf()
	-- print(vim.api.nvim_buf_get_name(z))
	-- print(vim.inspect(vim.bo.fenc))
	--print(vim.inspect(vim.bo.filetype))
	info = {}
	info.win = vim.api.nvim_get_current_win()
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
UserComm('ToggleListchars', function(c) vim.o.list = not vim.o.list end, { desc = "toggle listchars", bar = true })

UserComm('CycleDirs', function() CycleDirs() end, {})
UserComm('CDconfig', function() Cd(vim.fn.stdpath('config')) end, { desc = "cd stdpath(config)", bar = true })
UserComm('CDconfigg', function() Cd(vim.fn.stdpath('config') .. '/lua/genja') end, { desc = "cd (…)/lua/genja", bar = true })
-- UserComm('Cd', function(c) Cd(c.fargs) end, { nargs = '*', desc = "cd ?", bar = true })

--[[ from help, other people, etc ]]
UserComm('HiTest', function() vim.cmd [[:so $VIMRUNTIME/syntax/hitest.vim]] end, {})

--[[ roll your own ]]
local _cdp = 1
function CycleDirs(dirlist)
	dirlist = dirlist or START_DIRS
	local z, ok = pcall(function()
		-- handle error?
		Cd(dirlist[_cdp]);
	end)
	_cdp = _cdp + 1;
	if _cdp > #dirlist then
		_cdp = 1;
	end
end



--- StripSceneTags() {{{
local tags = {
	"%.avi$",
	"%.mkv$",
	"%.mov$",
	"%.mp4$",
	--
	'/$',
	'[%s%.]will1869$',
	'%.first.cut',
	'%.multisubs',
	'%.proper',
	'multi%.',
	--
	"%[norar%]",
	'%[TD%]',
	'%[eng%]',
	"%.web[%.%-]dl",
	"%.webb",
	"[%s%.]webrip",
	'%.WebDL',
	"%.web",
	--
	"%d+.BRRip",
	"%d+.BluRay",
	--
	--  "480p",
	--  "720p",
	-- "1080p",
	-- "1440p",
	-- "2160p",
	"[%.%s][12]-[0147][2468]0p",
	--
	--
	"X[%.%s]26[45]",
	"H[%.%s]26[45]",
	"x26[45]",
	"h26[45]",
	--
	"(HQ%s)*AC3[%s%.]DD[%.%d]*",
	--
	"dts%-hd",
	--
	"HQ[%s%.-]AC3",
	'%.HQ.Hive',
	--
	"AAC5.1",
	"MA%s5.1",
	"DDP5.1",
	"DD.5.1",
	"[%.%s]*Dolby.Digital.5.1",
	"DD5.1",
	"DD2.0",
	"AC3%[5.1%]",
	"[%.%s]5.1",
	--
	"AC3[%.%s]6ch",
	--
	"ddp2", "ddp5", "dd2", "dd5", "ddp",
	"10bit", "aac2", "aaf",
	"dts",
	"%.avc",
	"%.hc",
	--
	'%.Atmos',
	"ac3", "afg", "alfahd", "amcon", "amiable", "amzn",
	--
	'rerip',
	--
	'%.R1.NTSC',
	'%.NTSC',
	--
	"dvd%s*rip",
	"dvdscr",
	"HDDVD",
	"dvdr",
	"(dvd)",
	"%.dvd",
	--
	--
	"bae", "bdmf", "bdrip", "bigdoc",
	"[%.%s]bluray",
	"[%.%s]Blu%-*ray",
	"bordure", "brrip", "cakes", "cinefile",
	"clue", "cm8", "cmrg", "%[csi%]", "%[h33t%]", "d3fil3r", "d3g",
	"debtvid",
	"deimos", "demand", "diamond", "dimension", "disc", "divx",
	"dual",
	--
	"%.hdrip",
	"%.hdr",
	--
	"%.cam%.",
	"%.limited",
	"%.extended",
	"%.WS%.",
	'%.torrent$',
	--
	"ebook", "elia", "ethel", "evo", "extras",
	"ffndvd", "flux", "fqm", "ghosts", "haggis",
	"hdtv", "hevc", "hive", "hmax", "%[hst%]",
	"hulu", "hybris", "imbt", "internal", "ipt", "kacy",
	"ktr", "lama", "m00tv", "majestic", "megusta",
	"mp4", "msd", "naisu", "nogrp", "npw",
	"ntb", "ntsc", "paleale", "part", "phase", "proof",
	"psychd", "qix", "redblade", "remastered", "repack",
	"reward",
	--
	"s01e02", "s01e03", "s01e04", "s01e05", "s01e06", "s01e07", "s01e08", "s01e09", "s01e10",
	"sample", "screens",
	--
	"%.screener",
	"[%.%s]season%d%d",
	--
	"externe subs",
	"subtitles",
	"topaz", "trips", "uki", "usury", "video_ts",
	"vodo", "vomit", "voxhd",
	--
	"s01", "s02", "s03", "s04", "s05", "s06", "s07", "s08", "s09", "s10",
	--
	"mp3", "aac",
	--
	"wiki", "wrb", "x0r", "xlf",
	"xvidhd",
	"xvid",
	"uncut",
	"xxx",
	--
	"unrated.dc", "unrated",
	--
	"%.NF%.",
	"%.DC%.",
}

function StripSceneTags(e)
	e = string.lower(e)
	for _, p in pairs(tags) do
		p = string.lower(p)
		e, _ = e:gsub(p, "")
	end
	e, _ = e:gsub('%.', " ")                -- dot to space
	e, _ = e:gsub('[%s%.]%(*%d%d%d%d%)*', " ") -- remove (year)
	e, _ = e:gsub('%[*%d%d%d%d%]*', " ")    -- remove [year]
	e, _ = e:gsub("%s+", " ")               -- collapse spaces
	e = e:match("^%s*(.-)[%s/-]*$")         -- (1) strip leading spaces, trailing spaces, slash, hyphens
	e, _ = e:gsub('%s*[%(%[]%s*[%)%]]', "") -- strip empty ( )
	e, _ = e:gsub('%s%-[%w_]+$', "")        -- strip trailin -name
	e = e:match("^%s*(.-)[%s/-]*$")         -- (2) strip leading spaces, trailing spaces, slash, hyphens
	return e
end
-- }}}

-- vim: set foldmethod=marker foldlevel=0 foldnestmax=2 foldcolumn=2:
