-- dial.nvim: <C-a>/<C-x> on more than numbers (idea 29a). Keys: lua/genja/map-plugin/dial.lua.
-- Groups follow LazyVim's dial extra: one group per filetype, `default` otherwise.
-- `~` (lua/genja/ext/tilde.lua) still swaps a single word; dial adds counts, dates and cycles.
local Maps = require('genja.map-plugin')

---@type LazySpec
return {
	'monaqa/dial.nvim',
	keys = Maps:keys(),
	config = function()
		local augend = require('dial.augend')

		local weekdays = augend.constant.new({
			elements = { 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday' },
			word = true,
			cyclic = true,
		})
		local months = augend.constant.new({
			elements = {
				'January', 'February', 'March', 'April', 'May', 'June',
				'July', 'August', 'September', 'October', 'November', 'December',
			},
			word = true,
			cyclic = true,
		})
		local logical = augend.constant.new({ elements = { '&&', '||' }, word = false, cyclic = true })
		local and_or = augend.constant.new({ elements = { 'and', 'or' }, word = true, cyclic = true })
		local on_off = augend.constant.new({ elements = { 'on', 'off' }, word = true, cyclic = true })
		local yes_no = augend.constant.new({ elements = { 'yes', 'no' }, word = true, cyclic = true })
		local ordinals = augend.constant.new({
			elements = { 'first', 'second', 'third', 'fourth', 'fifth', 'sixth', 'seventh', 'eighth', 'ninth', 'tenth' },
			word = true,
			cyclic = false,
		})

		local default = {
			augend.integer.alias.decimal_int, -- -1, 0, 1, …
			augend.integer.alias.hex, -- 0x1f
			augend.date.alias['%Y-%m-%d'], -- 2026-10-23
			augend.date.alias['%H:%M'],
			augend.constant.alias.bool, -- true / false
			augend.semver.alias.semver, -- 1.2.3
			weekdays,
			months,
			ordinals,
			logical,
			and_or,
			on_off,
			yes_no,
		}

		---@param extra table[]
		---@return table[]
		local function with_default(extra)
			local list = vim.list_extend({}, default)
			return vim.list_extend(list, extra)
		end

		require('dial.config').augends:register_group({
			default = default,
			lua = with_default({
				augend.constant.new({ elements = { '==', '~=' }, word = false, cyclic = true }),
			}),
			typescript = with_default({
				augend.constant.new({ elements = { 'let', 'const' } }),
				augend.constant.new({ elements = { '===', '!==' }, word = false, cyclic = true }),
			}),
			go = with_default({
				augend.constant.new({ elements = { '==', '!=' }, word = false, cyclic = true }),
			}),
			php = with_default({
				augend.constant.new({ elements = { '===', '!==' }, word = false, cyclic = true }),
				augend.constant.new({ elements = { 'public', 'protected', 'private' }, word = true, cyclic = true }),
			}),
			css = with_default({
				augend.hexcolor.new({ case = 'lower' }), -- #a0b1c2
			}),
			markdown = with_default({
				augend.misc.alias.markdown_header, -- # -> ## -> ###
				augend.constant.new({ elements = { '[ ]', '[x]' }, word = false, cyclic = true }),
			}),
			yaml = with_default({}),
			json = with_default({}),
		})
	end,
}
