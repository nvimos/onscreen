-- Shared LSP settings.
--
-- optional per-environment overrides go in lua/genja/lsp/local.lua
-- It has the same shape, is merged over this file, and is meant to
-- stay out of git. Example:
--
--		return { enabled = { php = true, python = false } }
--		return { enabled = { php = true, powershell = false } }

return {
	-- Keys are file names in lua/genja/lang/ sans «.lua»
	-- false or absent: the language is skipped and nothing is installed for it.
	-- i.e you need to add a lang-key here after installing a new language
	enabled = {
		-- shells
		powershell = false,
		bash = true,
		lua = true,

		-- langs
		typescript = false,
		c_cpp = false,
		go = false,

		-- scrapt itropretor langs
		python = false,
		php = false,
	},

	-- Passed to require('mason').setup().
	mason = {
		ui = { border = 'double' },
	},
}
