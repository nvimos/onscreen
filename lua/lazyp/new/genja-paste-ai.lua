-- Paste search in the browser with one current provider (plug-wip/genja-paste-ai.nvim).
-- Keys: lua/genja/map-plugin/genja-paste-ai.lua. <F2>: lua/genja/f2/collect/lookup.lua.
-- The saved provider is the gitignored lua/genja/local/paste-ai.lua (`return '<name>'`).
local Maps = require('genja.map-plugin')

local SRC = 'lua/lazyp/new/genja-paste-ai.lua: '
local LOCAL_FILE = vim.fn.stdpath('config') .. '/lua/genja/local/paste-ai.lua'

---Provider saved by -save / <M-s>; nil when there is none.
---@return string|nil
local function saved_provider()
	if vim.fn.filereadable(LOCAL_FILE) == 0 then
		return nil
	end
	local ok, name = pcall(dofile, LOCAL_FILE)
	if not ok or type(name) ~= 'string' then
		vim.notify(SRC .. 'ignoring ' .. LOCAL_FILE .. ': it should return a provider name', vim.log.levels.WARN)
		return nil
	end
	return name
end

---@param name string
local function save_provider(name)
	vim.fn.writefile({
		'-- written by :PasteSearch -save / <F2> <M-s> (lua/lazyp/new/genja-paste-ai.lua)',
		"return '" .. name .. "'",
	}, LOCAL_FILE)
end

---@type LazySpec
return {
	dir = vim.fn.stdpath('config') .. '/plug-wip/genja-paste-ai.nvim',
	cmd = { 'PasteSearch', 'Wot', 'Google', 'Perplexity', 'Xty' },
	keys = Maps:keys(),

	---@type genja-paste-ai.Opts
	opts = {
		provider = saved_provider() or 'perplexity',
		save = save_provider,
	},

	config = function(_, opts)
		require('genja-paste-ai').setup(opts)
		Maps:mappings(opts)
	end,
}
