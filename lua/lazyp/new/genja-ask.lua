-- Ask popup (idea 16): plug-wip/genja-ask.nvim. Keys: plugin/ask.lua, plugin/claude-fterm.lua.

local Wip = require('genja.plug-wip')

---@type LazySpec
return {
	'tox2ik/genja-ask.nvim',
	dir = Wip.dir('genja-ask.nvim'),
	dependencies = { { 'tox2ik/genja-util.nvim', dir = Wip.dir('genja-util.nvim') } },
	-- lazy (default), no trigger: loads on the first require('genja-ask'), i.e. <M-?> / <leader>pc

	---@type genja-ask.Opts
	opts = {
		-- claudefterm target: the popup's model and effort become claude flags (plug-wip/genja-claudefterm.nvim)
		send = function(prompt, run)
			local flags = {}
			if run.model then
				vim.list_extend(flags, { '--model', run.model })
			end
			if run.effort then
				vim.list_extend(flags, { '--effort', run.effort })
			end
			require('genja-claudefterm').send(prompt, flags)
		end,
	},

	config = function(_, opts)
		require('genja-ask').setup(opts)
	end,
}
