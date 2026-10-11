return {
	-- {
	-- 	'github/copilot.vim',
	-- 	cmd = 'Copilot',
	-- 	config = function()
	-- 		-- vim.cmd [[ set b:copilot_enabled = 1 ]]
	--
	-- 		vim.keymap.set('i', '<C-J>', 'copilot#Accept("\\<CR>")', {
	-- 			expr = true,
	-- 			replace_keycodes = false
	-- 		})
	--
	-- 		vim.g.copilot_no_tab_map = false
	--
	-- 		vim.api.nvim_create_autocmd('ColorScheme', {
	-- 			pattern = 'solarized',
	-- 			-- group = ...,
	-- 			callback = function()
	-- 				vim.api.nvim_set_hl(0, 'CopilotSuggestion', {
	-- 					fg = '#555555',
	-- 					ctermfg = 8,
	-- 					force = true
	-- 				})
	-- 			end
	-- 		})
	-- 	end
	-- },

	-- copilot experiment. 2024-10-11
	--
	-- original seems to be working better.
	-- needs more cmp?
	--
	--        zbirenbaum/copilot-cmp: Integration with nvim-cmp.
	--

	-- AndreM222/copilot-lualine: Integration with lualine.nvim.


	{
		'zbirenbaum/copilot-cmp',
		config = function ()
			require('copilot_cmp').setup()
		end,
		dependencies = {
			{ "zbirenbaum/copilot.lua" }
		}
	},


	{
		'zbirenbaum/copilot.lua',
	enabled = false,
		cmd = 'Copilot',
		event = 'InsertEnter',
		config = function()
			require('copilot').setup({
				suggestion = { enabled = false }, -- not with copilot-cmp
				panel = { enabled = false }, -- not with copilot-cmp
				--
				filetypes = {
					yaml = true,
					markdown = true,
					help = false,
					gitcommit = false,
					gitrebase = false,
					hgcommit = false,
					svn = false,
					cvs = false,
					["."] = false,
					-- ["*"] = false, -- disable for all other filetypes and ignore default `filetypes`
				},
			})
		end,
	},



	-- tiktoken not available for windows?
	-- need to setup luarocks?
	-- {
	-- 	"CopilotC-Nvim/CopilotChat.nvim",
	-- 	branch = "canary",
	-- 	dependencies = {
	-- 		{ "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
	-- 		{ "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
	-- 	},
	-- 	-- build = "make tiktoken", -- Only on MacOS or Linux
	-- 	-- sudo luarocks install --lua-version 5.1 tiktoken_core.
	-- 	-- C:\\Program Files\\Neovim\\bin\\
	-- 	-- https://github.com/gptlang/lua-tiktoken/releases
	-- 	-- -- nothing for windows.
	-- 	opts = {
	-- 		-- debug = true, -- Enable debugging
	-- 		-- See Configuration section for rest
	-- 	},
	-- 	-- See Commands section for default commands if you want to lazy load on them
	-- },
}

-- require('copilot').setup({
--   panel = {
--     enabled = true,
--     auto_refresh = false,
--     keymap = {
--       jump_prev = "[[",
--       jump_next = "]]",
--       accept = "<CR>",
--       refresh = "gr",
--       open = "<M-CR>"
--     },
--     layout = {
--       position = "bottom", -- | top | left | right
--       ratio = 0.4
--     },
--   },
--   suggestion = {
--     enabled = true,
--     auto_trigger = false,
--     hide_during_completion = true,
--     debounce = 75,
--     keymap = {
--       accept = "<M-l>",
--       accept_word = false,
--       accept_line = false,
--       next = "<M-]>",
--       prev = "<M-[>",
--       dismiss = "<C-]>",
--     },
--   },
--   filetypes = {
--     yaml = false,
--     markdown = false,
--     help = false,
--     gitcommit = false,
--     gitrebase = false,
--     hgcommit = false,
--     svn = false,
--     cvs = false,
--     ["."] = false,
--   },
--   copilot_node_command = 'node', -- Node.js version must be > 18.x
--   server_opts_overrides = {},
-- })

-- :Copilot panel
-- require("copilot.panel").accept()
-- require("copilot.panel").jump_next()
-- require("copilot.panel").jump_prev()
-- require("copilot.panel").open({position, ratio})
-- require("copilot.panel").refresh()


-- suggestion
-- When auto_trigger is true, copilot starts suggesting as soon as you enter insert mode.
--
-- When auto_trigger is false, use the next or prev keymap to trigger copilot suggestion.
--
-- To toggle auto trigger for the current buffer, use require("copilot.suggestion").toggle_auto_trigger().
--
-- Copilot suggestion is automatically hidden when popupmenu-completion is open. In case you use a custom menu for completion, you can set the copilot_suggestion_hidden buffer variable to true to have the same behavior. For example, with nvim-cmp:
--
-- cmp.event:on("menu_opened", function()
--   vim.b.copilot_suggestion_hidden = true
-- end)
--
-- cmp.event:on("menu_closed", function()
--   vim.b.copilot_suggestion_hidden = false
-- end)
--
-- The copilot.suggestion module exposes the following functions:

-- require("copilot.suggestion").is_visible()
-- require("copilot.suggestion").accept(modifier)
-- require("copilot.suggestion").accept_word()
-- require("copilot.suggestion").accept_line()
-- require("copilot.suggestion").next()
-- require("copilot.suggestion").prev()
-- require("copilot.suggestion").dismiss()
-- require("copilot.suggestion").toggle_auto_trigger()


-- require("copilot").setup {
-- 	filetypes = {
-- 		markdown = true, -- overrides default
-- 		terraform = false, -- disallow specific filetype
-- 		sh = function ()
-- 			if string.match(vim.fs.basename(vim.api.nvim_buf_get_name(0)), '^%.env.*') then
-- 				-- disable for .env files
-- 				return false
-- 			end
-- 			return true
-- 		end,
-- 	},
-- }



