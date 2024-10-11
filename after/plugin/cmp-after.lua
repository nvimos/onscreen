local vim = vim
local err = vim.api.nvim_err_writeln

local yes, cmp = pcall(require, 'cmp');
if not yes then
	err('no cmp module!')
	return
end

cmp = require('cmp')


-- Load as needed by filetype from the luasnippets folder in the config dir
-- TODO: verify / confirm / extend
require 'luasnip.loaders.from_lua'.lazy_load()


local Tab = { luasnip = require('luasnip') }
function Tab.has_text_before()
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	local line_text = vim.api.nvim_buf_get_lines(0, line - 1, line, true)
	local col_text = line_text[1]:sub(col, col)
	local col_not_space = col_text:match("%s") == nil

	-- use scheduled / deferred stuff to detect if there is a ' or " before cursor
	-- dont do completion if that's the case.

	-- local col_is_quote = col_text:match('^[\'"]') ~= nil
	-- print("L«".. line_text[1] .."» C:«" .. col_text .. "» ".. tostring(col_is_quote ))
	-- if col_is_quote then return true end
	return col ~= 0 and col_not_space
end

function Tab.next(fallback)
	if cmp.visible() then -- must be first
		cmp.select_next_item()
	elseif Tab:has_text_before() then
		cmp.complete()
	elseif Tab.luasnip.expand_or_jumpable() then
		Tab.luasnip.expand_or_jump()
	else
		fallback()
	end
end

function Tab:prev(fallback)
	if cmp.visible() then
		cmp.select_prev_item()
	elseif Tab.luasnip.jumpable(-1) then
		Tab.luasnip.jump(-1)
	else
		fallback()
	end
end

cmp.setup({
	--[[ close vs abort; close emits event «complete_done», abort does not ]]
	mapping = cmp.mapping.preset.insert({
		['<f2>']      = cmp.mapping.select_next_item(),
		['<f3>']      = cmp.mapping.select_prev_item(),
		['']         = cmp.mapping.abort(), -- on jolemak  <c-e> sends ^K
		['<c-space>'] = cmp.mapping.complete(),
		['<cr>']      = cmp.mapping.confirm { behavior = cmp.ConfirmBehavior.Insert, select = true },
		['<tab>']     = cmp.mapping(Tab.next, { 'i', 's' }),
		['<s-tab>']   = cmp.mapping(Tab.prev, { 'i', 's' }),
	}),

	snippet = {
		expand = function(args)
			local ok, luasnip = pcall(require, 'luasnip');
			if not ok then err('no luasnip') end
			luasnip.lsp_expand(args.body)
		end,
	},

	-- sorting = {
	-- 	comparators = {
	-- 		function(...)
	-- 			ok, cmp_b = pcall(require, 'cmp_buffer')
	-- 			if ok then
	-- 				return cmp_b:compare_locality(...)
	-- 			end
	-- 			return nil
	-- 		end,
	-- 		-- The rest of your comparators...
	-- 	}
	-- }

})

cmp.setup {
	sources = {
		{ group_index = 1, name = 'luasnip' },
		{ group_index = 2, name = 'nvim_lsp' },
		{ group_index = 2, name = 'nvim_lsp_signature_help' },
		{ group_index = 2, name = 'path' },
		{ group_index = 3, name = 'copilot' },
		{ group_index = 4, name = 'buffer' },
		-- {
		-- 	name = 'buffer',
		-- 	option = {
		-- 		-- get_bufnrs = function() return vim.api.nvim_list_bufs() end
		-- 		get_bufnrs = function()
		--
		-- 			--- max 3 mb...
		-- 			--- local buf = vim.api.nvim_get_current_buf()
		-- 			--- local byte_size = vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf))
		-- 			--- if byte_size > 3 * 1024 * 1024 then -- 3 Megabyte max
		-- 			--- 	return {}
		-- 			--- end
		--
		-- 			-- only visible buffers, as opposed to all
		-- 			local bufs = {}
		-- 			for _, win in ipairs(vim.api.nvim_list_wins()) do
		-- 				bufs[vim.api.nvim_win_get_buf(win)] = true
		-- 			end
		-- 			return vim.tbl_keys(bufs)
		-- 		end,
		-- 		keyword_pattern = [[\k\+]],
		-- 	}
		-- },
	},
}

cmp.setup {
	formatting = {
		fields = {
			cmp.ItemField.Kind,
			cmp.ItemField.Abbr,
			cmp.ItemField.Menu,
		},
		expandable_indicator = false,
		format = require("lspkind").cmp_format({
			mode = 'symbol', -- show only symbol annotations
			maxwidth = function() return math.floor(0.66 * vim.o.columns) end,
			ellipsis_char = '…', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
			show_labelDetails = true, -- show labelDetails in menu. Disabled by default

			-- -- The function below will be called before any actual modifications from lspkind
			-- -- so that you can provide more controls on popup customization.
			-- -- (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
			-- before = function(entry, vim_item)
			-- 	print(vim.inspect( entry ))
			-- 	return vim_item
			-- end
		})
	}
}



-- Set configuration for specific filetype.
-- You can specify the `git` source if cmp-git is installed
-- * https://github.com/petertriho/cmp-git
cmp.setup.filetype(
	'gitcommit',
	{
		sources = cmp.config.sources(
			{
				{ name = 'git' },
			},
			{
				{ name = 'buffer' },
			}
		)
	})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = 'buffer' }
	}
})


-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = 'path' }
	}, {
		{ name = 'cmdline', option = { ignore_cmds = { 'Man', '!', 'w', } } }
	}),
	-- matching = {
	-- disallow_symbol_nonprefix_matching = false,
	-- }
})




--[[ suggested mappings from somewhere
cmp.setup({
	mapping = cmp.mapping.preset.insert({
		-- ['<CR>'] = cmp.mapping.confirm({ select = false }),
		-- ['<C-Space>'] = cmp.mapping.complete(),
		-- ['<Tab>'] = function(fallback) if cmp.visible() then cmp.select_next_item() else fallback() end end,
		-- ['<C-b>'] = cmp.mapping.scroll_docs(-4),
		-- ['<C-f>'] = cmp.mapping.scroll_docs(4),
		-- ['<C-e>'] = cmp.mapping.abort(),
		-- ['<C-S-b>'] = cmp.mapping( cmp.mapping.scroll_docs(-4), { 'i', 'c'})
	})}) ]]
