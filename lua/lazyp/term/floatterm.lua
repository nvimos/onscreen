-- FloatermNew --name=foo bash
-- :LazygitFterm :PythonFterm :BashFterm :RangerFterm are in lua/genja/auto-alias.vim
---@type LazySpec
return {
		'voldikss/vim-floaterm',
		cmd = { 'FloatermNew', 'FloatermToggle', 'FloatermShow', 'FloatermHide', 'FloatermKill', 'FloatermSend', 'FloatermUpdate' },
}
