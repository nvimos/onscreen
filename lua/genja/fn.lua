-- user functions

UserComm = require 'genja.api'.UserComm

-- util

-- local function deep_flatten_table(t)
-- 	local r = {}
-- 	for _, e in pairs(t) do
-- 		if type(e) == 'table' then
-- 			for _, ee in pairs(deep_flatten_table(e))  do
-- 				table.insert(r, ee)
-- 			end
-- 		else
-- 			table.insert(r, e)
-- 		end
-- 	end
-- 	return r
-- end

---------


----------

function FileExists(path)
	local stat = vim.loop.fs_stat(path)
	return stat ~= nil
end

function IsDir(path)
	if (path == nil) then return false end
	if (path == '') then return false end
	local stat = vim.uv.fs_stat(path)
	return stat ~= nil and stat.type == 'directory'
end

function Dirname(path)
	return vim.fn.fnamemodify(path, ':h')
end

function Basename(path)
	return vim.fn.fnamemodify(path, ':t')
end

function Extensionname(path)
	return string.lower(vim.fn.fnamemodify(path, ':e'))
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

function IsPictureExtension(ext)
	return TableContains({
		'jpg', 'png', 'gif', 'bmp', 'xmp',
		'jpeg', 'tiff', 'webp',
	}, string.lower(ext))
end

function IsVideoExtension(ext)
	return TableContains({
		'mp4', 'mkv', 'avi', 'mpg', 'm4v',
		'mov', 'flv', 'f4v', 'vob',
		'wmv', '3gp', 'ogv', 'drc',
		'mpeg', 'webm', 'avchd', 'qt',
	}, string.lower(ext))
end

-- function JoinPaths(...)
-- 	local aa = {}
-- 	for i = 1, select("#", ...) do
-- 		table.insert(aa, (select(i, ...)):gsub('[\\/]+$', ''))
-- 	end
-- 	-- Get the OS-specific path separator
-- 	local separator = package.config:sub(1, 1)
-- 	return table.concat(aa, separator)
-- 	-- return table.concat({...}, separator)
-- end

function JoinPaths(...)
	return (table.concat({ ... }, package.config:sub(1, 1))
		:gsub('[\\/]+', package.config:sub(1, 1)))
end

function Join(t, sep)
	sep = sep or ''
	local sline = t[1]
	for i = 2, #t do
		e = t[i]
		if e == nil then e = '' end
		sline = sline .. sep .. tostring(e)
	end
	return sline
end

function Split(inputstr, sep)
	local t = {}
	if inputstr == '' or inputstr == nil then
		return t -- Empty input, empty output
	end
	if sep == nil then
		sep = "%s" -- Default separator is any whitespace
	end
	if sep == '' then -- Special case: convert the string to a table
		for i = 1, #inputstr do
			table.insert(t, inputstr:sub(i, i))
		end
		return t
	end
	for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
		table.insert(t, str)
	end
	return t
end

function Cd(to)
	vim.api.nvim_call_function('chdir', { to })
	vim.api.nvim_command('pwd')
	-- vim.cmd [[pwd]]
	-- vim.loop.chdir(vim.env.Userprofile) end
end

function StripNewlines(s)
	return string.gsub(s, '[\n\r]+', ' ')
end

function Trim(s)
	return string.gsub(s, '^%s+', '').gsub(s, '%s+$', '')
end

function IsWindows()
	return vim.fn.has("windows") == 1
end

function OsDependant(win, lin, mac, bsd, posix, other)
	if vim.fn.has("mac") == 1 then
		return mac
	elseif vim.fn.has("windows") == 1 then
		return win
	elseif vim.fn.has("linux") == 1 then
		return lin
	elseif vim.fn.has("bsd") == 1 then
		return bsd
	elseif vim.fn.has("posix") == 1 then
		return posix
	else
		return other
	end
end

function win_chdir_home()
	local bin_in_cwd =
		([[nvim-qt.exe]] == vim.fn.readdir('.', [[v:val =~ 'nvim-qt.exe$']])[1]) or
		([[nvim.exe]] == vim.fn.readdir('.', [[v:val =~ 'nvim.exe$']])[1])
	if (bin_in_cwd) then
		vim.uv.chdir(vim.env.Userprofile)
	end
end

function Ymd()
	return os.date('%Y-%m-%d')
end


---@param mod string
---@param cb function(e)  -- callback when loaded. e is the loaded module.
---@return boolean
function Safeload(...)
	mod, cb = unpack({...})
	local k, req = pcall(require, mod)
	if not k then
		require('genja.api').err(string.format('cannot load «%s»', mod))
	else
		if cb then
			cb(req)
		end
	end
	return k
end

M = {
	win_chdir_home = win_chdir_home,
	Safeload = Safeload,
	Mess = require('genja.api').err,
	Basename = Basename,
	Cd = Cd,
	Dirname = Dirname,
	Extensionname = Extensionname,
	FileExists = FileExists,
	IndexOf = IndexOf,
	IsDir = IsDir,
	IsPictureExtension = IsPictureExtension,
	IsVideoExtension = IsVideoExtension,
	IsWindows = IsWindows,
	Join = Join,
	JoinPaths = JoinPaths,
	OsDependant = OsDependant,
	Split = Split,
	StripNewlines = StripNewlines,
	TableContains = TableContains,
	Trim = Trim,

}
return M

--[[

Join = require('genja.fn').Join


]]

