

  -- elseif vim.fn.has("win32") == 1 then
  --   if vim.fn.executable("rundll32") == 1 then
  --     return { "rundll32", "url.dll,FileProtocolHandler", path }
  --   else
  --     return nil, "rundll32 not found"
  --   end




local vote_movielens = {
  desc = "Vote on movielens",
  callback = function()

	local oil = require('oil')
    local entry = oil.get_cursor_entry()

	local name = StripSceneTags(entry.name)
    local jid = vim.fn.jobstart({
		"rundll32", "url.dll,FileProtocolHandler",
		'https://movielens.org/explore?q='..name },
		{ detach = false })
    assert(jid > 0, "Failed to start job")
  end
  }

local move_category = {
	desc = "Move to _category",
	callback = function () MoveCat() end
}

local open_external = {
  desc = "Open (shell)",
  callback = function()
	local get_open_cmd = function(path)
		if vim.fn.has("mac") == 1 then return { "open", path }
		elseif vim.fn.executable("explorer.exe") == 1 then return { "explorer.exe", path }
		elseif vim.fn.executable("xdg-open") == 1 then return { "xdg-open", path }
		else return nil, "no handler found"; end
	end

	local oil = require('oil')
    local entry = oil.get_cursor_entry()
    local dir = oil.get_current_dir()
    if not entry or not dir then
      return
    end
    local path = dir .. entry.name
    -- TODO use vim.ui.open once this is resolved
    -- https://github.com/neovim/neovim/issues/24567
    local cmd, err = get_open_cmd(path)
    if not cmd then
      vim.notify(string.format("Could not open %s: %s", path, err), vim.log.levels.ERROR)
      return
    end
    local jid = vim.fn.jobstart(cmd, { detach = false }) -- original is "true"
    assert(jid > 0, "Failed to start job")
  end,
}

-- local open_browser = {
--   desc = "Search in movielens",
--   callback = function()
-- 	local oil = require('oil')
--     local entry = oil.get_cursor_entry()
--     local dir = oil.get_current_dir()
--     if not entry or not dir then
--       return
--     end
--     local path = dir .. entry.name
--     -- TODO use vim.ui.open once this is resolved
--     -- https://github.com/neovim/neovim/issues/24567
--     local cmd, err = get_open_cmd(path)
--     if not cmd then
--       vim.notify(string.format("Could not open %s: %s", path, err), vim.log.levels.ERROR)
--       return
--     end
--     local jid = vim.fn.jobstart(cmd, { detach = false }) -- original is "true"
--     assert(jid > 0, "Failed to start job")
--   end,
-- }

------

return {
	{ 'stevearc/oil.nvim',
	event = 'UIEnter',
	cmd = 'Oil',
	opts = {
		skip_confirm_for_simple_edits = true,

		float = {
			-- Padding around the floating window
			padding = 4,
			max_width = 0,
			max_height = 0,
			border = "rounded",
			win_options = {
				winblend = 0,
			},
			-- This is the config that will be passed to nvim_open_win.
			-- Change values here to customize the layout
			override = function(conf)
				return conf
			end,
		},

		keymaps = {
			["gX"] = open_external,
			-- ["xb"] = open_browse jr,  -- exec via browser
			-- ["xc"] = open_browser,
			['<LocalLeader>x'] = open_external,
			['<LocalLeader>,'] = vote_movielens,
			-- ['<localleader>j'] = {desc = "Move to _category", callback = function() MoveCat(); vim.cmd[[e %:p]]; end}
			['<localleader>j'] = move_category,
		},
		win_options = {
			wrap = false,
			signcolumn = "yes",
			cursorcolumn = false,
			foldcolumn = "2",
			spell = false,
			list = false,
			conceallevel = 3,
			concealcursor = "nvic",
		},
		default_file_explorer = true, -- instead of netrw
		columns = {
			"size",
			{ "icon", add_padding = false}, },


	}, dependencies = { "nvim-tree/nvim-web-devicons" }, }
}
