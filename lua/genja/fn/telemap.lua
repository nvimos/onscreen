---The `map` that telescope passes to attach_mappings(prompt_bufnr, map).
---action: an action name, a telescope action (callable table) or fun(prompt_bufnr).
---@alias genja.TelescopeMap fun(mode: 'i'|'n'|('i'|'n')[], lhs: string, action: string|table|fun(prompt_bufnr: integer), opts?: vim.keymap.set.Opts)

---Shared picker keys: <esc> closes, <F2>/<F3> move the selection.
---@param map genja.TelescopeMap
local function Telemap(map)
	map({ 'i', 'n' }, '<esc>',  require'telescope.actions'.close,                   { desc = 'Telescope: close' })
	map({ 'i', 'n' }, '<F3>',   require'telescope.actions'.move_selection_previous, { desc = 'Telescope: prev' })
	map({ 'i', 'n' }, '<S-F3>', require'telescope.actions'.move_selection_previous, { desc = 'Telescope: prev' })
	map({ 'i', 'n' }, '<F2>',   require'telescope.actions'.move_selection_next,     { desc = 'Telescope: next' })
	map({ 'i', 'n' }, '<S-F2>', require'telescope.actions'.move_selection_next,     { desc = 'Telescope: next' })
end

return {
	Telemap = Telemap,
}
