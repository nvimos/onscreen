-- <F2> source, group `lsp`: `EnableLang <lang>` when the buffer's filetype belongs to a
-- language that the config turns off (plug-wip/genja-completion011.nvim).

local M = {}

---@param ctx genja.f2.Ctx
---@param done fun(tasks: genja.f2.Task[])
function M.collect(ctx, done)
	local lsp = package.loaded['genja.lsp']
	-- not set up yet: :EnableLang doesn't exist, and <F2> shouldn't load it
	if not lsp or not lsp.config then
		done({})
		return
	end
	local name = lsp.disabled_lang_for(ctx.filetype)
	if not name then
		done({})
		return
	end
	done({
		{
			group = 'lsp',
			label = 'EnableLang ' .. name,
			action = function()
				lsp.enable_lang(name)
			end,
		},
	})
end

return M
