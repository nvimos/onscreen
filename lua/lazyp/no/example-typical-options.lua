return {
		'example/typical-plugspec-options',
		cmd = 'MyPlug',
		keys = { { '<leader>XXX', '<plug>(bar)', desc = 'Do the doo' }, },
		lazy = true, -- depends on event ora keys ora cmd
		event = 'VimEnter',
		enabled = true,
		build = function(LazyPlugin)
				-- function or string or false or 
				-- a list, of build commands See Building for more information.
		end,
		config = function()
				require('bar').setup {
						baz = false
				}
		end
}
