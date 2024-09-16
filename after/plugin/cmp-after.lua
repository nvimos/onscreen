local vim = vim
local err = vim.api.nvim_err_writeln

local ok, cmp = pcall(require, 'cmp');
if not ok then
	err('no cmp module!')
	return
end

-- Load as needed by filetype by the luasnippets folder in the config dir
require'luasnip.loaders.from_lua'.lazy_load()


-- Set this check up for nvim-cmp tab mapping
local has_words_before = function()
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end


cmp.setup({

	mapping = cmp.mapping.preset.insert({
		['<C-p>'] = cmp.mapping.select_prev_item(),
		['<C-n>'] = cmp.mapping.select_next_item(),
		['<C-d>'] = cmp.mapping.scroll_docs(-4),
		['<C-f>'] = cmp.mapping.scroll_docs(4),
		['<C-Space>'] = cmp.mapping.complete(),
		['<C-e>'] = cmp.mapping.close(),
		['<CR>'] = cmp.mapping.confirm {
			behavior = cmp.ConfirmBehavior.Replace,
			select = true,
		},
		['<Tab>'] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif require('luasnip').expand_or_jumpable() then
				require('luasnip').expand_or_jump()
			elseif has_words_before() then
				cmp.complete()
			else
				fallback()
			end
		end, { 'i', 's' }),

		['<S-Tab>'] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif require('luasnip').jumpable(-1) then
				require('luasnip').jump(-1)
			else
				fallback()
			end
		end, { 'i', 's' }),

		-- ['<CR>'] = cmp.mapping.confirm({ select = false }),
		-- ['<C-Space>'] = cmp.mapping.complete(),
		-- ['<Tab>'] = function(fallback) if cmp.visible() then cmp.select_next_item() else fallback() end end,
		-- ['<C-b>'] = cmp.mapping.scroll_docs(-4),
		-- ['<C-f>'] = cmp.mapping.scroll_docs(4),
		-- ['<C-e>'] = cmp.mapping.abort(),
		-- ['<C-S-b>'] = cmp.mapping( cmp.mapping.scroll_docs(-4), { 'i', 'c'})
	}),

	snippet = {
		expand = function(args)
			local ok, luasnip = pcall(require, 'luasnip');
			if not ok then err('no luasnip') end
			luasnip.lsp_expand(args.body)
		end,
	},

	sources = {
		{ name = 'nvim_lsp' },
		{ name = 'nvim_lsp_signature_help' },
		{ name = 'luasnip' },
		{ name = 'path' },
		{ name = 'buffer' },
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



	-- Set configuration for specific filetype.
	-- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
	cmp.setup.filetype('gitcommit', {
		sources = cmp.config.sources({
			{ name = 'git' },
		}, {
			{ name = 'buffer' },
		})
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
			{ name = 'cmdline' , option = { ignore_cmds = { 'Man', '!', 'w', }}}
		}),
		matching = { disallow_symbol_nonprefix_matching = false }
	})
