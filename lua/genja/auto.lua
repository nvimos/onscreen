
local aucmd = vim.api.nvim_create_autocmd
local err = vim.api.nvim_err_writeln

--[[ reset the search register after  - cursor movement in insert mode.
                                      - leaving nerdtree ]]--
local clear_search = vim.api.nvim_create_augroup('ClearSearch', { clear = true })
aucmd('CursorMovedI', { group = clear_search,
						callback = function() vim.fn.setreg('/@', '') end, })
aucmd({ "WinLeave", "BufLeave" }, { group = clear_search,
									callback = function(ev) vim.fn.setreg('/@','') end,
									pattern = {'TelescopePrompt', 'NERD_tree*',}})




---- local autoOpenDir = vim.api.nvim_create_augroup('AutoOpenDir', { clear = true })
---- aucmd({ 'BufEnter',  'BufWinEnter', 'BufNew', },
---- 	{ group = autoOpenDir,
---- 	  pattern = { 'nerdtree', 'netrw', "NetrwTreeListing" },
---- 	  callback = function(ev)
---- 		--[[
----         :let key = nvim_replace_termcodes("<C-o>", v:true, v:false, v:true)
----         :call nvim_feedkeys(key, 'n', v:false)
---- 		]]--
---- 		--[[
---- 			In VimL's double-quoted strings, as described in the :h string, \<xxx> represents a special key.
---- 				:exe "lua vim.api.nvim_feedkeys('\<esc>oa', 'm', true)"
---- 			wil run..
---- 				lua vim.api.nvim_feedkeys('^[oa', 'm', true)
---- 			:lua vim.api.nvim_feedkeys(vim.api.nvim_eval('"\\<esc>oa"'), 'm', ture)
---- 		]]--
---- 		vim.bo[ev.buf].modifiable = true
---- 		vim.bo[ev.buf].modified = true
---- 		local ft = vim.bo[ev.buf].filetype
---- 		-- err('HeLLLoooooooooooooo? '.. vim.inspect(ev))
---- 		-- vim.cmd [[m`/lazy-plug<cr>o<cr>let /@=''<cr>g`]]
---- 		-- vim.schedule_wrap(function()
---- 			-- local me = ev
---- 			-- err("LATER")
---- 		-- end)
---- 		vim.notify("«EV.MA»".. ft .. ":"..ev.event..":«" ..ev.match.."»")
---- 		-- vim.cmd [[/lazy-plug<cr>]]  -- o<cr>let /@=''<cr>g`']]
---- 		----local cr = vim.api.nvim_replace_termcodes("<cr>", true, false, true)
---- 		---- local cr = vim.api.nvim_replace_termcodes("<Return>", true, false, true)
---- 		---- local cr = vim.api.nvim_eval('"\\<cr>"')
---- 		-- vim.api.nvim_feedkeys('/lazy-plug'..crv, 'n', false)
---- 		-- vim.cmd[[:norm <cr>]]
---- 		----vim.api.nvim_feedkeys(cr, 'n', false)
---- 		vim.bo[ev.buf].modifiable = false
---- 		vim.bo[ev.buf].modified = false
---- 	  end
----     })


--[[x]]--


-- vim.schedule_wrap(function() end)

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
