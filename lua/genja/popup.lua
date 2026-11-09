-- The right-click menu (nvim's `PopUp` menu, :h popup-menu), all of it.
--   defaults:   nvim's own items (Open in web browser ... Select All) removed and defined again here, plus an LSP submenu
--               (Inspect, Inspect Tree, Go to definition; Inspect and Go to definition left the top level, and the
--               per-buffer Code action, Rename, References join them); nvim's How-to-disable-mouse item is not
--               defined again; nvim's own greying autocmd is replaced by enable_context_items()
--   fixed:      ToggleWrap, Actions (g.), Reload Genja, Quit all (through :Unsaved qa)
--   everywhere: Morning
--   GUI:        frameless (nvim-qt window frame on/off)
--   markdown:   toggle checkbox, open link, F2 menu
--   oil:        git add (entry under the cursor), open in tab
--   LSP buffer: code action, rename, references
--   visual:     paste search of the selection: current provider, or pick one (genja-paste-ai)
-- The per-buffer entries are rebuilt on every MenuPopup. nvim's own items (Inspect, Cut, Copy, ...) are not ours.
-- Submenus: nvim's right-click menu does not nest (activating an item with children fails with E335). An entry with
-- `submenu = 'Name'` goes into a hidden menu `]Name submenu`, and a plain PopUp item `Name actions` pops that up with `:popup`.
-- Loaded by Safeload in lua/genja/init.lua.

local SRC = 'lua/genja/popup.lua: '

local M = {}

---@class genja.PopupEntry
---@field label string menu text
---@field run fun()
---@field visual? boolean only in visual mode (vnoremenu)
---@field submenu? string put the entry in this submenu of PopUp

---Menu names added on the last MenuPopup (an entry, or the whole submenu), removed on the next one.
---@type string[]
local shown = {}

---@type genja.PopupEntry[]
local current = {}

---Toggle `- [ ]` / `- [x]` on the cursor line; a plain list item gets `[ ]`.
local function toggle_checkbox()
	local line = vim.api.nvim_get_current_line()
	local new = nil
	if line:match('^%s*[-*+] %[ %]') then
		new = line:gsub('%[ %]', '[x]', 1)
	elseif line:match('^%s*[-*+] %[[xX]%]') then
		new = line:gsub('%[[xX]%]', '[ ]', 1)
	elseif line:match('^%s*[-*+] ') then
		new = line:gsub('^(%s*[-*+] )', '%1[ ] ', 1)
	end
	if new then
		vim.api.nvim_set_current_line(new)
	else
		vim.notify(SRC .. 'not a list item', vim.log.levels.INFO)
	end
end

---git add the oil entry under the cursor.
local function oil_git_add()
	local oil = require('oil')
	local entry = oil.get_cursor_entry()
	local dir = oil.get_current_dir()
	if not entry or not dir then
		vim.notify(SRC .. 'no file under the cursor', vim.log.levels.INFO)
		return
	end
	local path = vim.fs.joinpath(dir, entry.name)
	vim.system({ 'git', 'add', '--', path }, { cwd = dir, text = true }, vim.schedule_wrap(function(res)
		if res.code == 0 then
			vim.notify(SRC .. 'git add ' .. entry.name)
		else
			vim.notify(SRC .. 'git add failed: ' .. vim.trim(res.stderr or ''), vim.log.levels.WARN)
		end
	end))
end

---Entries for the current buffer.
---@return genja.PopupEntry[]
local function entries()
	local list = {}
	local ft = vim.bo.filetype
	if ft == 'markdown' then
		table.insert(list, { label = 'Markdown: toggle checkbox', run = toggle_checkbox })
		table.insert(list, { label = 'Markdown: open link', run = function() vim.cmd('normal gx') end })
		table.insert(list, { label = 'Markdown: F2 menu', run = function() require('genja.map-telescope.fn').context_picker() end })
	elseif ft == 'oil' then
		table.insert(list, { label = 'Oil: git add', run = oil_git_add })
		table.insert(list, { label = 'Oil: open in tab', run = function() require('oil').select({ tab = true }) end })
	end
	if #vim.lsp.get_clients({ bufnr = 0 }) > 0 then
		table.insert(list, { submenu = 'LSP', label = 'Code action', run = function() vim.lsp.buf.code_action() end })
		table.insert(list, { submenu = 'LSP', label = 'Rename', run = function() require('genja.ext.rename-inline').rename() end })
		table.insert(list, { submenu = 'LSP', label = 'References', run = function() vim.lsp.buf.references() end })
	end
	table.insert(list, { label = 'Lookup: paste search selection', visual = true, run = function() require('genja-paste-ai').selection() end })
	table.insert(list, { label = 'Lookup: paste search with provider', visual = true, run = function() require('genja-paste-ai').selection_pick() end })
	table.insert(list, { label = 'Morning', run = function() require('genja.ext.morning').open() end })
	if vim.fn.has('gui_running') == 1 and vim.fn.exists('*GuiWindowFrameless') == 1 then
		table.insert(list, { label = 'frameless', run = function() require('genja.ui.gui-func-state').GuiWindowFrameless():advance() end })
	end
	return list
end

---A menu name part with spaces, dots and backslashes escaped.
---@param text string
---@return string
local function escape(text)
	return (text:gsub('([ .\\])', '\\%1'))
end

---The hidden menu of a submenu: a leading ] keeps a menu off the menu bar, `:popup` still shows it.
---@param name string e.g. 'LSP'
---@return string menu path, escaped, e.g. ']LSP\ submenu'
local function hidden_menu(name)
	return ']' .. escape(name .. ' submenu')
end

---Text of the PopUp item for a submenu, when it is not "<name> actions".
local leaf_labels = { CopyPasta = 'CopyPasta' }

---The PopUp item that opens the hidden menu of a submenu.
---@param name string e.g. 'LSP'
---@return string menu path, escaped, e.g. 'PopUp.LSP\ actions'
local function leaf_item(name)
	return 'PopUp.' .. escape(leaf_labels[name] or (name .. ' actions'))
end

---Menu path of an entry: PopUp.<label>, or <hidden menu of the submenu>.<label>.
---@param entry genja.PopupEntry
---@return string
local function menu_name(entry)
	if entry.submenu then
		return hidden_menu(entry.submenu) .. '.' .. escape(entry.label)
	end
	return 'PopUp.' .. escape(entry.label)
end

---Where the right-click landed: window and cursor, saved when the first menu opens. nvim's right click has moved
---the cursor onto the clicked word by then. Clicking an item of a second menu can move the cursor again (the
---click may reach the text under the menu), so the items of hidden menus run from here.
---@type { win: integer, cursor: integer[] }|nil
local origin = nil

---True while a hidden menu is being popped up: its MenuPopup is not a new right click.
local opening_submenu = false

local function save_origin()
	origin = { win = vim.api.nvim_get_current_win(), cursor = vim.api.nvim_win_get_cursor(0) }
end

local function restore_origin()
	if not origin or not vim.api.nvim_win_is_valid(origin.win) then
		return
	end
	vim.api.nvim_set_current_win(origin.win)
	pcall(vim.api.nvim_win_set_cursor, origin.win, origin.cursor) -- the buffer may have shrunk meanwhile
end

---Go back to where the right-click landed, then run an Ex command.
---@param cmd string
function M.at_origin(cmd)
	restore_origin()
	vim.cmd(cmd)
end

---Menu right-hand side that runs `cmd` from the right-click position.
---@param cmd string
---@return string
local function at_origin_rhs(cmd)
	return ('<Cmd>lua require("genja.popup").at_origin(%q)<CR>'):format(cmd)
end

---Pop up the hidden menu of a submenu. Called from the PopUp item, so the right-click menu is still on its way
---out: `:popup` right then is dropped (the first menu just disappears), hence the short delay.
---@param name string
function M.open_submenu(name)
	opening_submenu = true
	vim.defer_fn(function()
		-- popup!: at the mouse pointer, where the item was clicked; without the bang it opens at the text cursor
		local ok, err = pcall(vim.cmd, 'popup! ' .. hidden_menu(name))
		opening_submenu = false -- `:popup` returns when the menu is gone (or failed)
		if not ok then
			vim.notify(SRC .. 'popup failed: ' .. tostring(err), vim.log.levels.WARN)
		end
	end, 30)
end

---Run entry `i` of the menu shown last.
---@param i integer
function M.run(i)
	local entry = current[i]
	if entry then
		if entry.submenu then
			restore_origin()
		end
		entry.run()
	end
end

---What nvim's own "Mouse popup menu" autocmd did (runtime/lua/vim/_core/defaults.lua), for our item paths:
---grey out the items that do nothing here. Go to definition is on whenever a client is attached.
local function enable_context_items()
	vim.cmd([[
		amenu disable ]LSP\ submenu.Go\ to\ definition
		amenu disable PopUp.Open\ in\ web\ browser
		amenu disable PopUp.Show\ Diagnostics
		amenu disable PopUp.Show\ All\ Diagnostics
		amenu disable PopUp.Configure\ Diagnostics
	]])
	-- private nvim function: if it goes away, the web item stays disabled
	local ok, urls = pcall(function() return require('vim.ui')._get_urls() end)
	local url = ok and urls[1] or nil
	if url and vim.startswith(url, 'http') then
		vim.cmd([[amenu enable PopUp.Open\ in\ web\ browser]])
	end
	if #vim.lsp.get_clients({ bufnr = 0 }) > 0 then
		vim.cmd([[anoremenu enable ]LSP\ submenu.Go\ to\ definition]])
	end
	local lnum = vim.fn.getcurpos()[2] - 1
	local diagnostic_here = next(vim.diagnostic.get(0, { lnum = lnum })) ~= nil
	if diagnostic_here then
		vim.cmd([[anoremenu enable PopUp.Show\ Diagnostics]])
	end
	if diagnostic_here or next(vim.diagnostic.count(0)) ~= nil then
		vim.cmd([[
			anoremenu enable PopUp.Show\ All\ Diagnostics
			anoremenu enable PopUp.Configure\ Diagnostics
		]])
	end
end

---Submenus that default_entries() builds, leaf item included: their per-buffer entries are removed one by one.
local static_submenus = { LSP = true, CopyPasta = true }

---Replace the per-buffer entries; called on MenuPopup.
function M.refresh()
	enable_context_items()
	for _, name in ipairs(shown) do
		pcall(vim.cmd, 'aunmenu ' .. name)
	end
	shown = {}
	current = entries()
	for i, entry in ipairs(current) do
		local name = menu_name(entry)
		local cmd = 'anoremenu '
		if entry.visual then
			cmd = 'vnoremenu '
		end
		vim.cmd(cmd .. name .. ' <Cmd>lua require("genja.popup").run(' .. i .. ')<CR>')
		if entry.submenu and not static_submenus[entry.submenu] then
			-- the PopUp item that opens the submenu, once; the hidden menu goes with its last entry
			local leaf = leaf_item(entry.submenu)
			if not vim.tbl_contains(shown, leaf) then
				local open = ' <Cmd>lua require("genja.popup").open_submenu("' .. entry.submenu .. '")<CR>'
				vim.cmd('anoremenu ' .. leaf .. open)
				table.insert(shown, leaf)
				table.insert(shown, hidden_menu(entry.submenu))
			end
		else
			table.insert(shown, name)
		end
	end
end

---Names of nvim's own PopUp items (runtime/lua/vim/_defaults.lua), removed first and defined again below.
---Same names as nvim's, so its MenuPopup autocmd ("Mouse popup menu") still enables and disables them.
local nvim_default_items = {
	'Open\\ in\\ web\\ browser', 'Inspect', 'Go\\ to\\ definition', 'Show\\ Diagnostics', 'Show\\ All\\ Diagnostics',
	'Configure\\ Diagnostics', '-1-', 'Cut', 'Copy', 'Paste', 'Delete', 'Select\\ All', '-2-', 'How-to\\ disable\\ mouse',
	'LSP\\ >', 'LSP\\ actions', 'LSP', -- ours; the first and the last are earlier versions of the LSP item
	'Back', 'Forward', 'CopyPasta',
}

---nvim's default items, written out as nvim defines them (nvim 0.13), then the LSP submenu below Select All.
---The "How-to disable mouse" item and the separator above it are left out.
local function default_entries()
	for _, name in ipairs(nvim_default_items) do
		vim.cmd('silent! aunmenu PopUp.' .. name)
	end
	vim.cmd([[silent! aunmenu ]CopyPasta\ submenu]]) -- the hidden menus, for a reload
	vim.cmd([[silent! aunmenu ]LSP\ submenu]])
	vim.cmd([[silent! aunmenu ]LSP]]) -- and its first version

	vim.cmd([[amenu PopUp.Open\ in\ web\ browser gx]])
	vim.cmd([[anoremenu PopUp.Show\ Diagnostics <Cmd>lua vim.diagnostic.open_float()<CR>]])
	vim.cmd([[anoremenu PopUp.Show\ All\ Diagnostics <Cmd>lua vim.diagnostic.setqflist()<CR>]])
	vim.cmd([[anoremenu PopUp.Configure\ Diagnostics <Cmd>help vim.diagnostic.config()<CR>]])
	vim.cmd([[anoremenu PopUp.-1- <Nop>]])
	vim.cmd([[vnoremenu PopUp.Cut "+x]])
	vim.cmd([[vnoremenu PopUp.Copy "+y]])
	vim.cmd([[vnoremenu PopUp.Delete "_x]])

	-- Back / Forward: the jump list (<C-o> / <C-i>, which is <Tab>). Go to definition, then right-click, Back.
	vim.cmd([[anoremenu PopUp.Back <Cmd>execute "normal! \<C-o>"<CR>]])
	vim.cmd([[anoremenu PopUp.Forward <Cmd>execute "normal! \<Tab>"<CR>]])


	-- "submenu": nvim's right-click menu has no nesting (activating a menu with children gives E335), so the
	-- LSP actions item is a plain item that pops up a second menu, the hidden `]LSP submenu` (`:popup {name}`
	-- shows any menu). Inspect and Go to definition moved here from the top level; the per-buffer LSP
	-- entries (code action, rename, references) join them from entries().
	vim.cmd([[anoremenu PopUp.LSP\ actions <Cmd>lua require("genja.popup").open_submenu("LSP")<CR>]])
	-- the items run from the right-click position (at_origin_rhs), not from wherever the click on them left the cursor
	vim.cmd([[anoremenu ]LSP\ submenu.Go\ to\ definition ]] .. at_origin_rhs('lua vim.lsp.buf.definition()'))
	vim.cmd([[anoremenu ]LSP\ submenu.Inspect ]] .. at_origin_rhs('Inspect'))
	vim.cmd([[anoremenu ]LSP\ submenu.Inspect\ Tree ]] .. at_origin_rhs('InspectTree'))


	-- CopyPasta: Paste and Select All, nvim's definitions moved into their own hidden menu. The visual variants
	-- keep nvim's commands: they act on the selection, which a restored cursor would not bring back.
	vim.cmd([[anoremenu PopUp.CopyPasta <Cmd>lua require("genja.popup").open_submenu("CopyPasta")<CR>]])
	vim.cmd([[anoremenu ]CopyPasta\ submenu.Paste ]] .. at_origin_rhs('normal! "+gP'))
	vim.cmd([[vnoremenu ]CopyPasta\ submenu.Paste "+P]])
	vim.cmd([[nnoremenu ]CopyPasta\ submenu.Select\ All ]] .. at_origin_rhs('normal! ggVG'))
	vim.cmd([[vnoremenu ]CopyPasta\ submenu.Select\ All gg0oG$]])
	vim.cmd([[inoremenu ]CopyPasta\ submenu.Select\ All <C-Home><C-O>VG]])
	-- nvim's MenuPopup autocmd greys items by their top-level names, and Go to definition is gone from there:
	-- it would fail on every right-click. enable_context_items() does its job for our paths.
	pcall(vim.api.nvim_del_augroup_by_name, 'nvim.popupmenu')
	vim.cmd([[anoremenu PopUp.-2- <Nop>]])
end

---The items that are always there, in every buffer.
local function fixed_entries()
	-- ToggleWrap is a function in lua/genja/fn.vim
	vim.cmd([[amenu PopUp.ToggleWrap :call ToggleWrap()<CR>]])
	-- g. action menu (lua/genja/ext/actions.lua); telescope: click selects, double-click runs
	vim.cmd([[amenu PopUp.Actions\ (g\.) <Cmd>lua require('genja.ext.actions').open()<CR>]])
	-- priority is one number per menu level, dot separated (:h sub-menu-priority); PopUp's own is unused,
	-- so `.9999` is "last": the entries above are added later, on MenuPopup, at the default 500
	vim.cmd([[amenu .9997 PopUp.Reload\ Genja <Cmd>ReloadLuaGenja<CR>]])
	vim.cmd([[amenu .9998 PopUp.-QuitSep- <Nop>]])
	-- :Unsaved qa (lua/genja/ext/unsaved.lua): modified buffers get the telescope picker first, then it quits
	vim.cmd([[amenu .9999 PopUp.Quit\ all <Cmd>Unsaved qa<CR>]])
end

---True from MenuPopup until the next wheel event that finds no menu on screen; there is no event for the menu closing.
local menu_open = false

---Mouse wheel while the right-click menu is open: wheel down selects the next item, wheel up the previous one.
---Anywhere else the wheel key is passed on unchanged (a mapping that feeds the same key without remapping it).
---@param arrow string key that moves the selection
---@param wheel string the wheel key itself
---@return fun(): string
local function wheel_in_menu(arrow, wheel)
	return function()
		if menu_open and vim.fn.pumvisible() == 1 then
			return arrow
		end
		menu_open = false
		return wheel
	end
end

local function wheel_keys()
	local opts = { expr = true, replace_keycodes = true, desc = 'PopUp: wheel moves the selected item' }
	vim.keymap.set({ 'n', 'v', 'i', 'o' }, '<ScrollWheelDown>', wheel_in_menu('<Down>', '<ScrollWheelDown>'), opts)
	vim.keymap.set({ 'n', 'v', 'i', 'o' }, '<ScrollWheelUp>', wheel_in_menu('<Up>', '<ScrollWheelUp>'), opts)
end

function M.setup()
	default_entries()
	fixed_entries()
	wheel_keys()
	vim.api.nvim_create_autocmd('MenuPopup', {
		group = vim.api.nvim_create_augroup('genja_popup_menu', { clear = true }),
		callback = function()
			menu_open = true
			if opening_submenu then
				return -- a hidden menu: same right click, same entries, same origin
			end
			save_origin()
			M.refresh()
		end,
	})
end

return M
