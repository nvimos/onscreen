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

---@param path string
---@return boolean
function FileExists(path)
	local stat = vim.uv.fs_stat(path)
	return stat ~= nil
end

---@param path? string
---@return boolean
function IsDir(path)
	if (path == nil) then return false end
	if (path == '') then return false end
	local stat = vim.uv.fs_stat(path)
	return stat ~= nil and stat.type == 'directory'
end

-- {{{ Dirname, Basename, Extensionname
---@param path string
---@return string
function Dirname(path) return vim.fn.fnamemodify(path, ':h') end
---@param path string
---@return string
function Basename(path) return vim.fn.fnamemodify(path, ':t') end
---@param path string
---@return string lowercase, without the dot
function Extensionname(path) return string.lower(vim.fn.fnamemodify(path, ':e')) end
-- }}}

---@generic T
---@param arr T[]
---@param target T
---@return integer index, -1 when absent
function IndexOf(arr, target)
	for i, value in ipairs(arr) do
		if value == target then
			return i
		end
	end
	return -1
end

---@generic T
---@param arr T[]
---@param target T
---@return boolean
function TableContains(arr, target)
	return IndexOf(arr, target) >= 1
end

---@param ext string without the dot
---@return boolean
function IsPictureExtension(ext)
	return TableContains({
		'jpg', 'png', 'gif', 'bmp', 'xmp',
		'jpeg', 'tiff', 'webp',
	}, string.lower(ext))
end

---@param ext string without the dot
---@return boolean
function IsVideoExtension(ext)
	return TableContains({
		'mp4', 'mkv', 'avi', 'mpg', 'm4v',
		'mov', 'flv', 'f4v', 'vob',
		'wmv', '3gp', 'ogv', 'drc',
		'mpeg', 'webm', 'avchd', 'qt',
	}, string.lower(ext))
end

---@param ... string
---@return string joined with the OS separator
function JoinPaths(...)
	return (table.concat({ ... }, package.config:sub(1, 1))
		:gsub('[\\/]+', package.config:sub(1, 1)))
end

---@param t any[]
---@param sep? string default ''
---@return string
function Join(t, sep)
	sep = sep or ''
	local sline = t[1]
	for i = 2, #t do
		local e = t[i]
		if e == nil then e = '' end
		sline = sline .. sep .. tostring(e)
	end
	return sline
end

---@param inputstr? string
---@param sep? string lua pattern class, default whitespace; '' splits into characters
---@return string[]
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

---@param to string
function Cd(to)
	vim.api.nvim_call_function('chdir', { to })
	vim.api.nvim_command('pwd')
	-- vim.cmd [[pwd]]
	-- vim.loop.chdir(vim.env.Userprofile) end
end

---@param s string
---@return string
function StripNewlines(s)
	return (string.gsub(s, '[\n\r]+', ' '))
end

---@param s string
---@return string
function Trim(s)
	return (s:gsub('^%s+', ''):gsub('%s+$', ''))
end

---@return boolean
function IsWindows()
	return vim.fn.has("win32") == 1
end

---@generic T
---@param win T
---@param lin T
---@param mac T
---@param bsd T
---@param posix T
---@param other T
---@return T
function OsDependant(win, lin, mac, bsd, posix, other)
	if vim.fn.has("mac") == 1 then
		return mac
	elseif vim.fn.has("win32") == 1 then
		return win
	elseif vim.fn.has("linux") == 1 then
		return lin
	elseif vim.fn.has("bsd") == 1 then
		return bsd
	elseif vim.fn.has("unix") == 1 then
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

---@return string YYYY-MM-DD
function Ymd()
	return os.date('%Y-%m-%d')
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

