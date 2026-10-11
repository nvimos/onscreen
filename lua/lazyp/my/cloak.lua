---@type LazySpec
return {

	{ 'laytan/cloak.nvim',               -- hide sensitive info in config files
		cmd = { 'CloakDisable', 'CloakToggle', 'CloakPreviewLine', 'CloakEnable' },
		config = function()
			--[[ The plugin automatically activates when
			     a file matched by the patterns is opened.
			     You do have to call the setup() function. ]]
			require("cloak").setup({
				enabled = true,
				cloak_character = "*",
				highlight_group = "Comment",
				patterns = {
					{ file_pattern = { ".env*", "wrangler.toml", ".dev.vars", }, cloak_pattern = "=.+" },
					{ file_pattern = { ".yml", ".yaml", }, cloak_pattern = { ":.+", "-.+" } },
				}}) end,
		lazy = true,
		},

}
