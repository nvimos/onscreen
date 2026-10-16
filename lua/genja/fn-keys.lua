function Close_nerdtree_wins() -- <space> ee | e. | et
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		-- local ft = vim.api.nvim_buf_get_option(buf, 'filetype') DEPRECATED
		local ft = vim.bo[buf].filetype
		if ft == 'nerdtree' then
			vim.api.nvim_win_close(win, true)
		end
	end
end

function CheckAndRunMRU() -- <S-F1>
	if vim.bo.filetype == "mru" then
		vim.cmd("quit")
	else
		-- os.execute("A:\\bin\\uniq-vim-mru-files.exe")
		-- vim.cmd("MRU")
		vim.fn.jobstart("A:\\bin\\uniq-vim-mru-files.exe", {
			on_exit = function()
				vim.cmd("MRU")
			end
		})
	end
end

-- local function SubstituteVisualSelection()
-- 	-- Vimscript equivalent (no escaping):
-- 	-- xnoremap <leader>r "ly:%s/<C-r>l//g<Left><Left>
-- 	vim.cmd('normal! "ly')
-- 	local s = vim.fn.escape(vim.fn.getreg('l'), [[\/]]):gsub('\n', [[\n]])
-- 	local keys = ':%s/\\V' .. s .. '//g' .. vim.api.nvim_replace_termcodes('<Left><Left>', true, false, true)
-- 	vim.api.nvim_feedkeys(keys, 'n', false)
-- end


function EditFindNotes()
	local places = {}
	table.insert(places, 'J:\\notes')
	table.insert(places, vim.env.HOME .. '/notes')
	table.insert(places, vim.env.HOME .. '/Notez')
	table.insert(places, vim.env.HOME .. '/Notez26')
	table.insert(places, vim.env.HOME)
	for _, e in ipairs(places) do
		if IsDir(e) then
			vim.cmd('edit ' .. e)
			break
		end
	end
end

return {
	EditFindNotes = EditFindNotes,
	Close_nerdtree_wins = Close_nerdtree_wins,
	CheckAndRunMRU = CheckAndRunMRU,
	-- SubstituteVisualSelection = SubstituteVisualSelection,
}
