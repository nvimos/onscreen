-- Ask popup (idea 16): plug-wip/genja-ask.nvim. Keys: <M-?> (plugin/ask.lua), <leader>pC (plugin/claude-fterm.lua).

---@type LazySpec
return {
	dir = vim.fn.stdpath('config') .. '/plug-wip/genja-ask.nvim',
	-- lazy (default), no trigger: loads on the first require('genja-ask'), i.e. <M-?> / <leader>pC

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
