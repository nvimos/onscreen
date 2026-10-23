-- ask backend: paste into this project's claude floaterm (lua/genja/claude.lua) and submit.
-- The answer shows in that terminal; the popup only confirms.

---@type genja.ask.Backend
return {
	name = 'floaterm',
	models = {},
	efforts = {},
	sessions = false,
	sync = true, -- answers right away; no process to wait for

	run = function(_, prompt, _, on_done)
		require('genja.claude').send(prompt)
		on_done(nil, '(sent to the claude floaterm; the answer shows there)')
		return nil
	end,
}
