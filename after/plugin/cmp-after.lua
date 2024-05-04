
local err = vim.api.nvim_err_writeln; 

local ok, cmp = pcall(require, 'cmp');
if not ok then
	err("no cmp module!")
end

vim.g.mycmp = 1


cmp.setup({
	sources = {
		{ name = 'nvim_lsp' },
		{ name = 'buffer', option = {
			-- get_bufnrs = function() return vim.api.nvim_list_bufs() end
			get_bufnrs = function() -- only visible buffers, as opposed to all
				local buf = vim.api.nvim_get_current_buf()
				local byte_size = vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf))
				if byte_size > 3 * 1024 * 1024 then -- 3 Megabyte max
					return {}
				end
				local bufs = {}
				for _, win in ipairs(vim.api.nvim_list_wins()) do
					bufs[vim.api.nvim_win_get_buf(win)] = true
				end
				return vim.tbl_keys(bufs)
			end,
			keyword_pattern = [[\k\+]], } },
		},
		mapping = cmp.mapping.preset.insert({
			['<CR>'] = cmp.mapping.confirm({select = false}),
			['<C-Space>'] = cmp.mapping.complete(),
			['<Tab>'] = function(fallback) if cmp.visible() then cmp.select_next_item() else fallback() end end,
		}),
		snippet = {
			expand = function(args)
				local ok, luasnip = pcall(require, 'luasnip');
				if ok then
					luasnip.lsp_expand(args.body)
				else
					err('no luasnip')

				end
			end,
		},
		sorting = {
			comparators = {
				function(...) 
					ok, cmp_b = pcall(require, 'cmp_buffer')
					if ok then
						return cmp_b:compare_locality(...)
					end
					return nil
				end,
				-- The rest of your comparators...
			}
		}
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
