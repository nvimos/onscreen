# which-key sorting options

Checked against which-key.nvim 3aab214 (2025-10-28), `lua/which-key/view.lua`.

## In a lazy spec

```lua
---@type LazySpec
return {
	'folke/which-key.nvim',
	event = 'VeryLazy',
	opts = {
		-- default: { 'local', 'order', 'group', 'alphanum', 'mod' }
		sort = {
			'local',
			'group',
			-- case-insensitive description; plain 'desc' is case-sensitive
			function(item) return (item.desc or '~'):lower() end,
		},
	},
}
```

Sorters are applied in the order listed. Each one only decides between items
that the earlier sorters left tied. `natural` and `case` are always added at
the end as tie-breakers, then the raw key.

The popup fills each column top to bottom before starting the next one
(`a d g / b e h / c f i`); no option needed.

## Sorters

| Sorter | Effect |
|---|---|
| `local` | Buffer-local mappings first |
| `order` | Uses the item's `order` field, set by plugin pickers like marks and registers |
| `group` | Groups last |
| `alphanum` | Plain letter/number keys before symbol keys |
| `mod` | `<...>` keys (`<C-x>`, `<F1>`) before plain keys. The config comment says "last", but the code returns 0 for them, which sorts first |
| `manual` | Order the mappings were defined in |
| `case` | Lowercase keys before uppercase |
| `desc` | By description, case-sensitive. Items without one go last |
| `natural` | By key, case-insensitive, with numbers compared as numbers (`2` before `10`) |
| function | `function(item) return value end`. Smaller values sort first |

The upstream README also lists `lower` and `icase`; they are not defined in
this version's code and are ignored.

## Groups

A group is an entry that opens another level of the popup instead of running
a command. `Node:is_group()` in `lua/which-key/node.lua` is true when the key:

- is a prefix of other mappings (`<leader>f` when `<leader>ff`, `<leader>fg`
  exist), or
- has `proxy`, `expand`, or comes from a plugin (marks, registers), so it can
  expand into children.

Naming a group is optional and only sets its label:

```lua
require('which-key').add({
	{ '<leader>f', group = 'file' },
	{ '<leader>w', proxy = '<c-w>', group = 'windows' },
})
```

A prefix with no `group` name is still a group; its label falls back to
`N keymaps`. Groups are shown with the `icons.group` symbol (default `+`)
before the label, highlighted `WhichKeyGroup`. `expand = n` in `opts`
inlines groups that have at most `n` mappings.
