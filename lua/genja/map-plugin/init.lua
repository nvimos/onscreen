-- Plugin keys in one place. Lazy specs fetch their entries by their own file name:
--
--   local Maps = require('genja.map-plugin')
--   return {
--   	'github/copilot.vim',
--   	keys = Maps:keys(),          -- lazy `keys`: these keys also trigger loading
--   	config = function(_, opts)
--   		Maps:mappings(opts)      -- runs the vim.keymap.set calls registered below
--   		vim.cmd('Copilot disable')
--   	end,
--   }
--
-- The name is the spec file's name sans `.lua` (lua/lazyp/langs-comps/copilot.lua -> 'copilot').
-- Pass it explicitly when two spec files share a name:
--
--   Maps:keys('copilot'),
--   Maps:mappings(opts, 'copilot').
--
-- Definitions live in lua/genja/map-plugin/<spec name>.lua; the bottom of this file
-- finds and requires them. Each returns a function that takes the instance:
--
--   ---@param Maps genja.MapPlugin
--   return function(Maps)
--   	local spec_name = Maps.current_file()   -- 'copilot'
--   	Maps:add_keys(spec_name, { ... })
--   	Maps:add_mappings(spec_name, function(opts) ... end)
--   end
--
-- They don't require('genja.map-plugin') themselves: this file is still loading
-- then, and require errors with "loop or previous error loading module".
--
-- A lookup that finds nothing is not a notify: it is recorded once per name and session,
-- appended to stdpath('log')/genja-map-plugin.log, and listed by
-- :checkhealth genja.map-plugin (health.lua, from this session's records only).

local SRC = 'lua/genja/map-plugin/init.lua: '
local LOG = vim.fs.joinpath(vim.fn.stdpath('log'), 'genja-map-plugin.log')


-- One (or more) keymap for lazy plugin spec keys option.
-- [1] lhs, [2] rhs (string or function),
-- plus mode/desc/silent/expr/ft... as named fields (not a nested table).
---@alias genja.MapPlugin.Keys LazyKeysSpec[]

-- Body of vim.keymap.set calls; run by MapPlugin:mappings(opts) from a spec's config.
-- opts is the spec's merged `opts` ({} when none were passed).
---@alias genja.MapPlugin.Mappings fun(opts: table)

-- A keys() or mappings() call that found nothing.
---@class genja.MapPlugin.Miss
---@field kind 'keys'|'mappings'
---@field name string spec name, or '?' when it could not be resolved
---@field file string calling file, relative to the config dir when inside it

---@class genja.MapPlugin
---@field private _keys table<string, genja.MapPlugin.Keys>         spec name -> lazy keys
---@field private _mappings table<string, genja.MapPlugin.Mappings> spec name -> keymap function
---@field private _asked table<string, boolean>                     'keys:name' / 'mappings:name' -> found
---@field private _missed genja.MapPlugin.Miss[]                    this session, each kind+name once
local MapPlugin = {}

-- Missing keys on instances are looked up here: this is what makes the methods visible.
MapPlugin.__index = MapPlugin


---@return genja.MapPlugin
function MapPlugin.new()
	local obj = { _keys = {}, _mappings = {}, _asked = {}, _missed = {}, }
	return setmetatable(obj, MapPlugin)
end

-- Name of the file that defined the function at `level` on the stack:
-- '@C:/.../lua/lazyp/langs-comps/copilot.lua' -> 'copilot'.
-- Windows paths can use either slash, hence [/\\].
-- Second value: the file's path, relative to the config dir when inside it.
---@param level integer stack level, counted from this function (1 = caller_name itself)
---@return string|nil name
---@return string path
local function caller_name(level)
	local info = debug.getinfo(level, 'S')
	if info == nil then
		return nil, '?'
	end
	-- '@' marks a file; other sources are strings from load()/loadstring().
	if info.source:sub(1, 1) ~= '@' then
		return nil, info.short_src
	end
	local path = vim.fs.normalize(info.source:sub(2))
	local config = vim.fs.normalize(vim.fn.stdpath('config')) .. '/'
	-- Windows: drive letter and folder case can differ between the two
	if path:lower():sub(1, #config) == config:lower() then
		path = path:sub(#config + 1)
	end
	local file_name = info.source:match('([^/\\]+)%.lua$')
	return file_name, path
end

-- Resolves the spec name: explicit argument, else the file that called the public method.
-- Stack seen from caller_name: 1 caller_name, 2 resolve_name, 3 the method (keys/mappings),
-- 4 the spec file. Hence 4, and why no call on this path may be a tail call.
-- Second value: the caller's file, for the miss log.
---@param spec_name string|nil
---@return string|nil name
---@return string path
local function resolve_name(spec_name)
	local found, path = caller_name(4)
	if spec_name ~= nil then
		return spec_name, path
	end
	return found, path
end

-- Records a lookup; a miss is logged once per kind and name in this session.
---@param self genja.MapPlugin
---@param kind 'keys'|'mappings'
---@param name string|nil
---@param path string
---@param found boolean
local function record(self, kind, name, path, found)
	local shown = name or '?'
	local id = kind .. ':' .. shown
	local before = self._asked[id]
	self._asked[id] = found or before == true
	if found or before ~= nil then
		return
	end
	table.insert(self._missed, { kind = kind, name = shown, file = path })
	local line = os.date('%Y-%m-%d %H:%M:%S') .. ' no ' .. kind .. " for '" .. shown .. "' (" .. path .. ')'
	local f = io.open(LOG, 'a')
	if f then
		f:write(line, '\n')
		f:close()
	end
end

-- Registering (used in the definition files)

-- Name of the file that calls this, sans .lua: 'copilot' from map-plugin/copilot.lua.
-- Stack seen from caller_name: 1 caller_name, 2 current_file, 3 the definition file.
-- A plain function, not a method: Maps.current_file() and Maps:current_file() both work,
-- the extra self is ignored.
---@return string
function MapPlugin.current_file()
	local spec_name = caller_name(3)
	if spec_name == nil then
		error(SRC .. 'current_file() needs to be called from a .lua file')
	end
	return spec_name
end

-- Lazy `keys` for `spec_name`. Called again for the same name, the lists are appended.
---@param spec_name string spec file name sans .lua
---@param keys genja.MapPlugin.Keys
---@return genja.MapPlugin self # for chaining
function MapPlugin:add_keys(spec_name, keys)
	local list = self._keys[spec_name]
	if list == nil then
		list = {}
		self._keys[spec_name] = list
	end
	vim.list_extend(list, keys)
	return self
end

-- Registering keymap function for `spec_name`. One per name; a second call replaces the first.
---@param spec_name string spec file name sans .lua
---@param fn genja.MapPlugin.Mappings
---@return genja.MapPlugin self # for chaining
function MapPlugin:add_mappings(spec_name, fn)
	self._mappings[spec_name] = fn
	return self
end

-- Retrieving (used in lazy specs)
-- Lazy `keys` for the calling spec file, or for `spec_name`.
-- Returns nil when nothing is registered, which lazy reads as "no keys".
---@param spec_name? string defaults to the caller's file name
---@return genja.MapPlugin.Keys|nil
function MapPlugin:keys(spec_name)
	local resolved, path = resolve_name(spec_name)
	local found = resolved ~= nil and self._keys[resolved] ~= nil
	record(self, 'keys', resolved, path, found)
	if not found then
		return nil
	end
	return self._keys[resolved]
end

-- Runs the mappings registered for the calling spec file, or for `spec_name`.
-- Call it inside the spec's config function. The name lookup still works there:
-- that function is defined in the spec file, so it is what level 4 sees.
---@param opts? table the spec's merged opts, handed to the keymap function
---@param spec_name? string defaults to the caller's file name
function MapPlugin:mappings(opts, spec_name)
	local resolved, path = resolve_name(spec_name)
	local found = resolved ~= nil and self._mappings[resolved] ~= nil
	record(self, 'mappings', resolved, path, found)
	if not found then
		return
	end
	if opts == nil then
		opts = {}
	end
	self._mappings[resolved](opts)
end

-- For health.lua: misses, and registered names not asked for yet in this session
-- (mappings run only when their plugin loads, so these are "not used yet", not errors).
---@return { missed: genja.MapPlugin.Miss[], keys_unasked: string[], mappings_unasked: string[], log: string }
function MapPlugin:status()
	local keys_unasked = {}
	for name in pairs(self._keys) do
		if self._asked['keys:' .. name] == nil then
			table.insert(keys_unasked, name)
		end
	end
	local mappings_unasked = {}
	for name in pairs(self._mappings) do
		if self._asked['mappings:' .. name] == nil then
			table.insert(mappings_unasked, name)
		end
	end
	table.sort(keys_unasked)
	table.sort(mappings_unasked)
	return { missed = self._missed, keys_unasked = keys_unasked, mappings_unasked = mappings_unasked, log = LOG }
end

-- print(require('genja.map-plugin')) shows what is registered.
-- Works on instances because MapPlugin is their metatable (see notes).
function MapPlugin:__tostring()
	return 'MapPlugin keys: ' .. vim.inspect(vim.tbl_keys(self._keys))
		.. ', mappings: ' .. vim.inspect(vim.tbl_keys(self._mappings))
end

-- Definitions: every .lua file next to this one (not subdirectories, not health.lua), in name order.
-- A file that returns a function is called with the instance; anything else is just required.
-- One broken file is reported and skipped, so the other plugins keep their keys.
local M = MapPlugin.new()

-- This file's directory, from its own chunk name ('@C:/.../map-plugin/init.lua').
local dir = vim.fs.dirname(debug.getinfo(1, 'S').source:sub(2))

-- vim.fs.dir's order depends on the OS; sort so the load order is stable.
local modules = {}
for file, kind in vim.fs.dir(dir) do
	if kind == 'file' and file ~= 'init.lua' and file ~= 'health.lua' and vim.endswith(file, '.lua') then
		table.insert(modules, file:sub(1, -5))
	end
end
table.sort(modules)

for _, module in ipairs(modules) do
	local ok, result = pcall(require, 'genja.map-plugin.' .. module)
	if ok and type(result) == 'function' then
		ok, result = pcall(result, M)
	end
	if not ok then
		vim.notify(SRC .. module .. '.lua: ' .. tostring(result), vim.log.levels.ERROR)
	end
end

return M
