
-- vim.api.nvim_create_autocmd(
--     { "BufWritePre" },
--     { pattern = { "*.py" }, command = "!your_command_here" }
-- )


-- vim.api.nvim_create_autocmd("VimEnter", {
--     pattern = "*",
--     command = "MRU"
--     -- command = "if vim.fn.argc() == 0 then vim.cmd('Dashboard') end"
-- })


--[[ EXAMPLE 
				vim.api.nvim_create_autocmd('UIEnter', {
				  group = vim.api.nvim_create_augroup('Dashboard', { clear = true }),
				  callback = function(ev)  --  buf, event, file, group, id, match
					if "nerdtree" == vim.bo[ev.buf].filetype then ... end
					if vim.fn.argc() == 0 and vim.api.nvim_buf_get_name(0) == '' then
					  require('dashboard'):instance()
					end
					vim.cmd("MRU")
				  end,
				})

				augroup Inits
					autocmd!
					" TODO: Fix so that lsp shows, it is updated correctly at right time
					autocmd BufEnter * lua require'statusline'.statusline_init()
					autocmd WinEnter,BufEnter * lua require'statusline'.activeLine()
					autocmd WinLeave,BufLeave * lua require'statusline'.inActiveLine()
					autocmd WinEnter,BufEnter,WinLeave,BufLeave NvimTree lua require'statusline'.simpleLine()
					autocmd WinEnter,BufEnter * lua require'statusline'.tabline_init()
				augroup END
--]]


	  -- vim.schedule_wrap(function() end)

--[[ reset the search register after  - cursor movement in insert mode.
                                      - leaving nerdtree ]]--
local clear_search = vim.api.nvim_create_augroup('ClearSearch', { clear = true })
vim.api.nvim_create_autocmd('CursorMovedI', { group = clear_search,
												callback = function() vim.fn.setreg('/@', '') end, })
vim.api.nvim_create_autocmd({ "WinLeave", 
                              "BufLeave" }, { group = clear_search,
												callback = function(ev) vim.fn.setreg('/@', '') end,
												pattern = 'NERD_tree*', })

--[[x]]--
