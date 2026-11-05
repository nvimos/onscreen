local Maps = require('genja.map-plugin')

-- The local checkout (its own repo, ignored here) when present; a fresh clone gets the published fork.
local Wip = require('genja.plug-wip')

---@type LazySpec
return {
	'tox2ik/keymaps.nvim', -- fork of abdul-hamid-achik/keymaps.nvim
	branch = 'genja-desc-builtins', -- the fork's main stays upstream's
	name = 'abdul-keymaps.nvim',
	dir = Wip.dir('abdul-keymaps.nvim'),
	dependencies = {
		"nvim-telescope/telescope.nvim", -- optional, for fuzzy finding
	},
	-- opts = { -- your configuration (see below) },
	-- require("keymaps").setup({ })
	---@type KeymapsConfig
	opts = {
		-- Main keybinding to open the cheatsheet (set to "" to disable)
		key = "<leader>?",

		-- Use telescope if available, fallback to floating window
		telescope = false,

		-- Show nerd font icons (requires a nerd font)
		icons = true,

		-- Include vim builtin keymaps; false: only the ones remapped with a desc (below)
		include_builtins = false,

		-- Still show builtin keys remapped with a desc, e.g. map-zero.lua's 'Fold: …'
		-- self-maps; works only with include_builtins = false. Option of the local clone.
		include_builtins_with_desc = true,

		-- Lua patterns (against lhs) that mark a key as builtin; this list replaces
		-- the default list in plug-wip/abdul-keymaps.nvim/lua/keymaps/config.lua
		-- (copied from there, so it is complete)
		builtin_patterns = {
			'^[hjkl]$',
			'^[wWeEbB]$',
			'^[0%$%^]$',
			'^[gG]$',
			'^[iIaAoO]$',
			'^[dDcCyYpP]$',
			'^[uU]$',
			'^<C%-r>$',
			'^<Esc>$',
			'^<CR>$',
			'^<BS>$',
			'^<Tab>$',
			'^<Space>$',
			'^:$',
			'^/$',
			'^%?$',
			'^n$',
			'^N$',
			'^%*$',
			'^#$',
			'^%%$',
			'^f.$',
			'^F.$',
			'^t.$',
			'^T.$',
			'^;$',
			'^,$',
			'^r.$',
			'^~$',
			'^%.$',
			'^@.$',
			-- '^q.$',
			'^m.$',
			"^'.$",
			'^`.$',
			'^".$',
			'^z[zoOcCaAmMrRfF]$',
			'^<C%-[a-zA-Z]>$',
		},

		-- Include buffer-local keymaps (from netrw, help, etc.)
		-- Set to false to hide noisy internal keymaps
		include_buffer_local = true,

		-- Include standard Vim motions and commands (h/j/k/l, w/e/b, text objects, etc.)
		-- These are merged with your custom keymaps for a complete reference
		include_motions = false,

		-- Enable usage tracking
		track_usage = true,

		-- Auto-refresh when config files change
		auto_refresh = true,

		-- Cache timeout in seconds (0 = no cache)
		cache_timeout = 20,

		-- Checked first, in this order; the first category with a matching pattern wins.
		-- Only decides which category a key lands in; the popup still sorts sections by name.
		-- The rest (incl. the plugin's defaults: Editing, Folds, ...) follow sorted by name.
		-- Option of the local clone.
		category_order = { 'Fold', 'LSP', 'Editing', },

		-- Category patterns for auto-categorization
		-- Keys are matched against these patterns to determine category
		category_patterns = {
			["LSP"] = {
				"^g[dDrRiItT]",
				"^<leader>l",
				"^<leader>c[aAdDfFrRsS]",
				"hover", "diagnostic", "definition", "references",
			},
			["Git"] = {
				"^<leader>g",
				"^<leader>h",
				"gitsigns", "fugitive", "neogit", "lazygit",
			},
			["Navigation"] = {
				"^<C%-[hjkl]>",
				"^<leader>w",
				"^<leader>b",
				"buffer", "window", "split",
			},

			-- map-zero.lua's fold keys, desc 'Fold: …'; matched lowercased in lhs/rhs/desc.
			-- First in category_order, so 'Fold: delete' is not claimed by Editing ('delete').
			["Fold"] = { "Fold: " },

			["Harpoon"] = { "harpoon", "^<leader>a" },
			["Telescope"] = { "telescope", "^<leader>f", "^<leader>s" },
			["File Explorer"] = { "^<leader>e", "nvim%-tree", "neo%-tree", "oil" },
			["Editing"] = { "yank", "paste", "delete", "surround" },
			["Comments"] = { "^gc", "^gb", "comment" },
			["Debugging"] = { "dap", "debug", "breakpoint" },
			["Testing"] = { "^<leader>t", "neotest", "test" },
			["Terminal"] = { "terminal", "toggleterm" },
			-- Add your own!
			["Custom"] = { "my_pattern" },

			-- ["EasyAlign"] = { "^<leader>A[a,:=]", },
			["z Edit EasyAlign"] = {
				"align on", -- your descs: "Align on spaces", "Align on , all", "Align on = 1st", "Align on : last"
				"gaip", -- rhs: :norm gaip*\ , gaip*, gaip1= , gaip*= , gaip1:
				"easy%-?align",
			},

		},

		-- Patterns to exclude from display
		exclude_patterns = {
			"^<Plug>",
			"^<SNR>",
		},

		-- Icons for categories (requires nerd font)
		category_icons = {
			["LSP"] = "",
			["Git"] = "",
			["Navigation"] = "",
			["Harpoon"] = "󱡀",
			["Telescope"] = "",
			["File Explorer"] = "",
			["Editing"] = "",
			["Comments"] = "",
			["Debugging"] = "",
			["Testing"] = "",
			["Terminal"] = "",
			["Other"] = "",
		},

		-- Icons for modes
		-- mode letters instead of nerd font glyphs
		mode_icons = {
			n = "n", -- Normal
			i = "i", -- Insert
			v = "v", -- Visual
			x = "x", -- Visual only (v: Visual + Select)
			s = "s", -- Select
			o = "o", -- Operator
			c = "c", -- Command
			t = "t", -- Terminal
		},

	},
	keys = Maps:keys(),
	-- track_usage wraps keymaps from startup on, not only after the first <leader>?
	event = 'VeryLazy',

	-- explicit: the dir name (abdul-keymaps.nvim) no longer matches the module name (keymaps)
	---@param opts KeymapsConfig
	config = function(_, opts)
		require('keymaps').setup(opts)
	end,
}
