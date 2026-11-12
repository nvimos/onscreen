-- relay (github.com/nvimos/relay): the Neovim side of the Ops desktop app; :NvimosServe lets Ops
-- connect, :NvimosServeStop stops listening. The local checkout when present, else a clone.
local checkout = vim.fs.normalize('~/es/nvimos-poc-backend')

---@type LazySpec
return {
	'nvimos/relay',
	name = 'relay',
	dir = vim.fn.isdirectory(checkout) == 1 and checkout or nil,
	lazy = false,
}
