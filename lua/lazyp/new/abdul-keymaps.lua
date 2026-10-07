return {
	"abdul-hamid-achik/keymaps.nvim",
	dependencies = {
		"nvim-telescope/telescope.nvim", -- optional, for fuzzy finding
	},
	-- opts = { -- your configuration (see below) },
	-- require("keymaps").setup({ })
	opts = {
		-- Main keybinding to open the cheatsheet (set to "" to disable)
		key = "<leader>?",

		-- Use telescope if available, fallback to floating window
		telescope = false,

		-- Show nerd font icons (requires a nerd font)
		icons = true,

		-- Include vim builtin keymaps
		include_builtins = false,

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
		cache_timeout = 300,

		-- Category patterns for auto-categorization
		-- Keys are matched against these patterns to determine category
		category_patterns = {
			["a LSP"] = {
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
		mode_icons = {
			n = "󰰓", -- Normal
			i = "󰰄", -- Insert
			v = "󰰫", -- Visual
			x = "󰰵", -- Visual Block
			s = "󰰢", -- Select
			o = "󰰑", -- Operator
			c = "󰯲", -- Command
			t = "󰰥", -- Terminal
		},

	},
	keys = {
		{ "<leader>?", "<cmd>Keymaps<cr>", desc = "Show Keymaps" },
	},
}
