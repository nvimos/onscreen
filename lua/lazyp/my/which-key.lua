---@type LazySpec
return {
	{
		'folke/which-key.nvim',
		event = "VeryLazy",
		-- other specs append to opts.spec; without this lazy would replace the list:
		-- { 'folke/which-key.nvim', optional = true, opts = { spec = { ... } } }
		-- (e.g. lua/lazyp/explorer/oil.lua)
		opts_extend = { 'spec' },

		dependencies = {
			'nvim-mini/mini.icons',
			'nvim-tree/nvim-web-devicons',
		},

		init = function()
			vim.o.timeout = true

			-- To override opt.lua for this setup, uncomment one line below.
			-- vim.o.timeoutlen = 800
			-- vim.o.timeoutlen = 200
			-- vim.o.timeoutlen = 1
		end,
		---@type wk.Opts
		---@type wk.Opts
		opts = {
			-- preset = "helix",
			-- keep ':' mappings (map-zero.lua's :w<CR>) out of the tree, so ':' never
			-- becomes a which-key trigger and opens the cmdline as usual
			filter = function(mapping)
				return not vim.startswith(mapping.lhs or '', ':')
			end,
			-- group labels; the mappings themselves live elsewhere
			-- empty groups are hidden, so labelling both modes is harmless
			-- one nested entry: opts_extend keeps only list items, so `mode` sits inside it
			spec = { {

				mode = { 'n', 'v' },

				{ '<leader>j.',       group = 'Cd…' },
				{ '<leader>j/',       group = 'Find' },
				{ '<leader>A',        group = 'Edit: alignment' },
				{ '<leader>a',        group = 'AI: companion' },
				{ '<leader>b',        group = 'Buffer: alternate' },
				{ '<leader>c',        group = 'Code: lsp' },
				{ '<leader>cA',       group = 'Code: php' },
				{ '<leader>cW',       group = 'Code: workspace' },
				{ '<leader>cc',       group = 'Diag: float' },
				{ '<leader>cd',       group = 'Diag: list' },
				{ '<leader>d',        group = 'Debug' },
				{ '<leader>e',        group = 'Edit: dirs, files' },
				{ '<leader>f',        group = 'Find: telescope' },
				{ '<leader>fm',       group = 'Fun: automaton' },
				-- { '<leader>g',        group = 'Go: env' },
				{ '<leader>cG',        group = 'Go: env' },
				{ '<leader>gE',       group = 'Env: ecolog' },
				{ '<leader>h',        group = 'Git: hunk, blame, diff, quickfix' },
				{ '<leader>i',        group = 'Insert: chars' },
				{ '<leader>j',        group = 'Jump: pickers, cd, start dirs' },
				{ '<leader>m',        group = 'UI: panels, git, claude, gui' },
				{ '<leader>mG',       group = 'UI: git log, commit' },
				{ '<leader>mQ',       group = 'GUI: nvim-qt toggles' },
				{ '<leader>mx',       group = 'UI: Close' },
				{ '<leader>o',        group = 'Outline: sidebar, nav' },
				{ '<leader>p',        group = 'AI: claude, pplx' },
				{ '<leader>r',        group = 'Code: format' },
				{ '<leader>s',        group = 'Dirs: start dirs' },
				{ '<leader><space>s', group = 'Spell: check, add' },
				{ '<leader>t',        group = 'Tab: move, toggle' },
				{ '<leader>tt',       group = 'Toggle: diag, hints' },
				{ '<leader>w',        group = 'Text: wrap, trim; window resize' },
				{ '<leader>W',        group = 'Resize: window (loop: <leader>wr)' },
				{ '<leader>ws',       group = 'Text: strip' },
				{ '<leader>ww',       group = 'Fold: wrap in markers' },
				{ '<leader>y',        group = 'Yank: clipboard' },
				{ '<leader>z',        group = 'Zen: and write' },

			} },
			sort = { 'local', 'buffer-local', 'desc', 'natural', 'mod' },
			-- same keys as the pickers: <F2> down, <F3> up (default <c-d>, <c-u>)
			keys = {
				scroll_down = '<F2>',
				scroll_up = '<F3>',
			},
		}
	},

}

--[[

'timeoutlen' (ms), set to 300 in lua/genja/opt.lua.

To make a shorter map that is also a prefix (<leader>f vs <leader>ff) fire almost at once, set it low (1-200).
Slow multi-key sequences then get cut off; suits fast typing and few overlapping maps.

To have time to finish long sequences (<leader>f, pause, f), set it high (500-1000).
The shorter overlapping map then waits that long.

To change when the which-key popup opens, set which-key's opts.delay; 'timeoutlen' does not affect it.

]]
