-- Right-click menu entries per filetype (idea 30/31), rebuilt on MenuPopup.
--   everywhere: Morning
--   GUI:        frameless (nvim-qt window frame on/off)
--   markdown:   toggle checkbox, open link, F2 menu
--   oil:        git add (entry under the cursor), open in tab
--   LSP buffer: code action, rename, references
-- The fixed entries (ToggleWrap, Actions (g.)) stay in lua/genja/fn.vim.
-- Loaded from plugin/popup-menu.lua.

local SRC = 'lua/genja/popup-menu.lua: '

local M = {}

---@class genja.PopupEntry
---@field label string menu text
---@field run fun()

---Entries added on the last MenuPopup, removed on the next one.
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
		table.insert(list, { label = 'LSP: code action', run = function() vim.lsp.buf.code_action() end })
		table.insert(list, { label = 'LSP: rename', run = function() vim.lsp.buf.rename() end })
		table.insert(list, { label = 'LSP: references', run = function() vim.lsp.buf.references() end })
	end
	table.insert(list, { label = 'Morning', run = function() require('genja.morning').open() end })
	if vim.fn.has('gui_running') == 1 and vim.fn.exists('*GuiWindowFrameless') == 1 then
		table.insert(list, { label = 'frameless', run = function() require('genja.ui.gui-func-state').GuiWindowFrameless():advance() end })
	end
	return list
end

---Menu path for `label`: spaces and dots escaped.
---@param label string
---@return string
local function menu_name(label)
	return 'PopUp.' .. label:gsub('([ .\\])', '\\%1')
end

---Run entry `i` of the menu shown last.
---@param i integer
function M.run(i)
	local entry = current[i]
	if entry then
		entry.run()
	end
end

---Replace the per-filetype entries; called on MenuPopup.
function M.refresh()
	for _, name in ipairs(shown) do
		pcall(vim.cmd, 'aunmenu ' .. name)
	end
	shown = {}
	current = entries()
	for i, entry in ipairs(current) do
		local name = menu_name(entry.label)
		vim.cmd('anoremenu ' .. name .. ' <Cmd>lua require("genja.popup-menu").run(' .. i .. ')<CR>')
		table.insert(shown, name)
	end
end

function M.setup()
	vim.api.nvim_create_autocmd('MenuPopup', {
		group = vim.api.nvim_create_augroup('genja_popup_menu', { clear = true }),
		callback = function() M.refresh() end,
	})
end

return M
