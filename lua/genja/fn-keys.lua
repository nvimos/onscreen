
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

function EditFindNotes()
	local places = {}
	table.insert(places, 'J:\\notes')
	table.insert(places, vim.env.user_home_dir .. '/notes')
	table.insert(places, vim.env.user_home_dir .. '/Notez')
	table.insert(places, vim.env.user_home_dir .. '/Notez26')
	table.insert(places, vim.env.user_home_dir)
	for _, e in ipairs(places) do
		if IsDir(e) then
			vim.cmd('edit ' .. e)
			break
		end
	end
end

---The `map` that telescope passes to attach_mappings(prompt_bufnr, map).
---action: an action name, a telescope action (callable table) or fun(prompt_bufnr).
---@alias genja.TelescopeMap fun(mode: 'i'|'n'|('i'|'n')[], lhs: string, action: string|table|fun(prompt_bufnr: integer), opts?: vim.keymap.set.Opts)

---Shared picker keys: <esc> closes, <F2>/<F3> move the selection.
---@param map genja.TelescopeMap
local function Telemap(map)
	map({ 'i', 'n' }, '<esc>',  require'telescope.actions'.close,                   { desc = 'Telescope: close' })
	map({ 'i', 'n' }, '<F3>',   require'telescope.actions'.move_selection_previous, { desc = 'Telescope: prev' })
	map({ 'i', 'n' }, '<S-F3>', require'telescope.actions'.move_selection_previous, { desc = 'Telescope: prev' })
	map({ 'i', 'n' }, '<F2>',   require'telescope.actions'.move_selection_next,     { desc = 'Telescope: next' })
	map({ 'i', 'n' }, '<S-F2>', require'telescope.actions'.move_selection_next,     { desc = 'Telescope: next' })
end


return {
	EditFindNotes = EditFindNotes,
	Close_nerdtree_wins = Close_nerdtree_wins,
	CheckAndRunMRU = CheckAndRunMRU,
	Telemap = Telemap,
}

