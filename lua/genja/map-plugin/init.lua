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
-- Definitions live in lua/genja/map-plugin/<spec name>.lua, required at the bottom
-- of this file. Each returns a function that takes the instance:
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


-- One (or more) keymap for lazy plugin spec keys option.
-- [1] lhs, [2] rhs (string or function),
-- plus mode/desc/silent/expr/ft... as named fields (not a nested table).
---@alias genja.MapPlugin.Keys LazyKeysSpec[]

-- Body of vim.keymap.set calls; run by MapPlugin:mappings(opts) from a spec's config.
-- opts is the spec's merged `opts` ({} when none were passed).
---@alias genja.MapPlugin.Mappings fun(opts: table)

---@class genja.MapPlugin
---@field private _keys table<string, genja.MapPlugin.Keys>         spec name -> lazy keys
---@field private _mappings table<string, genja.MapPlugin.Mappings> spec name -> keymap function
local MapPlugin = {}

-- Missing keys on instances are looked up here: this is what makes the methods visible.
MapPlugin.__index = MapPlugin

local SRC = 'genja/map-plugin/init.lua'

---@return genja.MapPlugin
function MapPlugin.new()
	local obj = { _keys = {}, _mappings = {}, }
	return setmetatable(obj, MapPlugin)
end

-- Name of the file that defined the function at `level` on the stack:
-- '@C:/.../lua/lazyp/langs-comps/copilot.lua' -> 'copilot'.
-- Windows paths can use either slash, hence [/\\].
---@param level integer stack level, counted from this function (1 = caller_name itself)
---@return string|nil
local function caller_name(level)
	local info = debug.getinfo(level, 'S')
	if info == nil then
		return nil
	end
	-- '@' marks a file; other sources are strings from load()/loadstring().
	if info.source:sub(1, 1) ~= '@' then
		return nil
	end
	local file_name = info.source:match('([^/\\]+)%.lua$')
	return file_name
end

-- Resolves the spec name: explicit argument, else the file that called the public method.
-- Stack seen from caller_name: 1 caller_name, 2 resolve_name, 3 the method (keys/mappings),
-- 4 the spec file. Hence 4, and why no call on this path may be a tail call.
---@param spec_name string|nil
---@return string|nil
local function resolve_name(spec_name)
	if spec_name ~= nil then
		return spec_name
	end
	local found = caller_name(4)
	return found
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
		error(SRC .. ': current_file() needs to be called from a .lua file')
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
	local resolved = resolve_name(spec_name)
	if resolved == nil or self._keys[resolved] == nil then
		vim.notify(SRC .. ': no keys for ' .. tostring(resolved), vim.log.levels.WARN)
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
	local resolved = resolve_name(spec_name)
	if resolved == nil or self._mappings[resolved] == nil then
		vim.notify(SRC .. ': no mappings for ' .. tostring(resolved), vim.log.levels.WARN)
		return
	end
	if opts == nil then
		opts = {}
	end
	self._mappings[resolved](opts)
end

-- print(require('genja.map-plugin')) shows what is registered.
-- Works on instances because MapPlugin is their metatable (see notes).
function MapPlugin:__tostring()
	return 'MapPlugin keys: ' .. vim.inspect(vim.tbl_keys(self._keys))
		.. ', mappings: ' .. vim.inspect(vim.tbl_keys(self._mappings))
end

-- Definitions: one line per file in lua/genja/map-plugin/, named after its lazy spec file.
local M = MapPlugin.new()

require('genja.map-plugin.abdul-keymaps')(M)     -- lua/lazyp/new/abdul-keymaps.lua
require('genja.map-plugin.aerial')(M)            -- lua/lazyp/ui/aerial.lua
require('genja.map-plugin.celular-automaton')(M) -- lua/lazyp/phunnee/celular-automaton.lua
require('genja.map-plugin.codecompanion')(M)     -- lua/lazyp/langs-comps/codecompanion.lua
require('genja.map-plugin.copilot')(M)           -- lua/lazyp/langs-comps/copilot.lua
require('genja.map-plugin.dap-php')(M)           -- lua/lazyp/debug/dap-php.lua
require('genja.map-plugin.dropbar')(M)           -- lua/lazyp/ui/dropbar.lua
require('genja.map-plugin.focus')(M)             -- lua/lazyp/ui/focus.lua
require('genja.map-plugin.harpoon')(M)           -- lua/lazyp/new/harpoon.lua
require('genja.map-plugin.mru')(M)               -- lua/lazyp/my/mru.lua
require('genja.map-plugin.nvim-emmet')(M)        -- lua/lazyp/langs-comps/nvim-emmet.lua
require('genja.map-plugin.php-laravel')(M)       -- lua/lazyp/langs/php-laravel.lua
require('genja.map-plugin.php-neotest')(M)       -- lua/lazyp/langs/php-neotest.lua
require('genja.map-plugin.toggleterm')(M)        -- lua/lazyp/term/toggleterm.lua
require('genja.map-plugin.vim-easy-align')(M)    -- lua/lazyp/my/vim-easy-align.lua
require('genja.map-plugin.zenmode')(M)           -- lua/lazyp/ui/zenmode.lua

return M
