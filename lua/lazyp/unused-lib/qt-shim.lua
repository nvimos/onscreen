
-- equalsraf/neovim-gui-shim is a VimL plugin that defines standard Gui* commands
-- (like :GuiFont, :GuiTabline) for Neovim GUIs. GUIs such as neovim-qt implement
-- these commands via RPC. The plugin provides a common interface so your config
-- works across different GUIs without being tied to one.
---@type LazySpec
return {
	-- neovim-qt fancy context mouse menu popup
	-- not used: 2026-10
	'equalsraf/neovim-gui-shim',
	enabled = false
}
