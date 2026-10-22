local Maps = require('genja.map-plugin')

---@type LazySpec
return {
		-- run tasks from makefiles?
		'stevearc/overseer.nvim', -- v2, needs neovim 0.11+
		cmd = { 'OverseerRun', 'OverseerShell', 'OverseerToggle', 'OverseerOpen', 'OverseerClose', 'OverseerTaskAction' },
		keys = Maps:keys(),
		---@type overseer.SetupOpts
		opts = { -- lazy passes this to require('overseer').setup()
				-- Every lua/overseer/template/**/*.lua is a template now; this one is only a helper.
				disable_template_modules = { 'overseer.template.user.php_test' },
		},
}
