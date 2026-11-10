-- map-plugin: miss records, the miss log and :checkhealth genja.map-plugin
-- (doc-wip/readme.2026-10-24.map-plugin-health.md, test steps 1-3).
-- Fresh child nvim per case; the log goes to a temp XDG_STATE_HOME.

local C = require('helpers.child')
local eq = MiniTest.expect.equality

local state_home = vim.fs.normalize(vim.fn.tempname()) .. '/state'
local old_state_home = vim.env.XDG_STATE_HOME

local child, T = C.fresh([[
	vim.fn.mkdir(vim.fn.stdpath('log'), 'p')
	vim.fn.delete(vim.fs.joinpath(vim.fn.stdpath('log'), 'genja-map-plugin.log'))
	-- notifications while the definition files load
	_G.notes = {}
	vim.notify = function(msg, level) table.insert(notes, { msg = msg, level = level }) end
	_G.Maps = require('genja.map-plugin')
	_G.config = vim.fs.normalize(vim.fn.stdpath('config'))
	-- health.check() output, without the :checkhealth buffer
	_G.health_lines = function()
		local lines = {}
		local h = vim.health
		local orig = { start = h.start, ok = h.ok, warn = h.warn, info = h.info, error = h.error }
		for kind in pairs(orig) do
			h[kind] = function(msg) table.insert(lines, kind .. ': ' .. msg) end
		end
		require('genja.map-plugin.health').check()
		for kind, fn in pairs(orig) do
			h[kind] = fn
		end
		return lines
	end
]], {
		pre_once = function()
			vim.fn.mkdir(state_home, 'p')
			-- the child inherits this, so stdpath('log') points into the temp dir
			vim.env.XDG_STATE_HOME = state_home
		end,
		post_once = function()
			vim.env.XDG_STATE_HOME = old_state_home
			vim.fn.delete(vim.fs.dirname(state_home), 'rf')
		end,
})

T['definition files load without a notification'] = function()
	eq(child.lua([[return notes]]), {})
end

T['log is in the temp state dir'] = function()
	local log = child.lua([[return vim.fs.normalize(Maps:status().log)]])
	eq(vim.startswith(log:lower(), state_home:lower()), true)
end

-- step 1: keys whose spec is only in lua/lazyp/no/ show as "no spec asked for"
T['registered keys without an active spec: only genja-splitpad'] = function()
	local got = child.lua([[
		local out = {}
		for _, name in ipairs(Maps:status().keys_unasked) do
			local specs = vim.fs.find(name .. '.lua', { path = config .. '/lua/lazyp', limit = math.huge })
			local active = false
			for _, spec in ipairs(specs) do
				if not vim.fs.normalize(spec):find('/lua/lazyp/no/', 1, true) then
					active = true
				end
			end
			if not active then
				table.insert(out, name)
			end
		end
		return out
	]])
	eq(got, { 'genja-splitpad' })
end

T['health: no misses after a clean load'] = function()
	local lines = child.lua([[return health_lines()]])
	eq(lines[2], 'ok: every Maps:keys() / Maps:mappings() call found its entry')
end

-- step 2: a mappings entry leaves "not used yet" once it has run
T['mappings: run once, then not listed as unused'] = function()
	local got = child.lua([[
		local seen = nil
		Maps:add_mappings('fake-plugin', function(opts) seen = opts end)
		local before = vim.tbl_contains(Maps:status().mappings_unasked, 'fake-plugin')
		Maps:mappings(nil, 'fake-plugin')
		local after = vim.tbl_contains(Maps:status().mappings_unasked, 'fake-plugin')
		return { before, after, seen }
	]])
	eq(got, { true, false, {} })
end

T['keys: asked for, then not listed as unasked'] = function()
	local got = child.lua([[
		Maps:add_keys('fake-plugin', { { '<leader>xx', '<cmd>echo<cr>', desc = 'Fake: key' } })
		local before = vim.tbl_contains(Maps:status().keys_unasked, 'fake-plugin')
		local keys = Maps:keys('fake-plugin')
		local after = vim.tbl_contains(Maps:status().keys_unasked, 'fake-plugin')
		return { before, after, #keys }
	]])
	eq(got, { true, false, 1 })
end

-- step 3: zenmode.lua gone (here: its entry dropped), the real spec file asks for keys
local load_zen_spec_without_keys = [[
	Maps._keys.zenmode = nil
	_G.spec = dofile(config .. '/lua/lazyp/ui/zenmode.lua')
]]

T['missing keys: spec gets nil keys, miss names the spec file'] = function()
	child.lua(load_zen_spec_without_keys)
	eq(child.lua([[return spec.keys == nil]]), true)
	eq(child.lua([[return Maps:status().missed]]), {
		{ kind = 'keys', name = 'zenmode', file = 'lua/lazyp/ui/zenmode.lua' },
	})
end

T['missing keys: no notification'] = function()
	child.lua(load_zen_spec_without_keys)
	eq(child.lua([[return notes]]), {})
end

T['missing keys: health warns with the calling file'] = function()
	child.lua(load_zen_spec_without_keys)
	local lines = child.lua([[return health_lines()]])
	eq(vim.tbl_contains(lines, "warn: no keys for 'zenmode', called from lua/lazyp/ui/zenmode.lua"), true)
end

T['missing keys: one log line, also when asked twice'] = function()
	child.lua(load_zen_spec_without_keys)
	child.lua([[dofile(config .. '/lua/lazyp/ui/zenmode.lua')]])
	local lines = child.lua([[return vim.fn.readfile(Maps:status().log)]])
	eq(#lines, 1)
	MiniTest.expect.no_equality(
		lines[1]:find("^%d%d%d%d%-%d%d%-%d%d %d%d:%d%d:%d%d no keys for 'zenmode' %(lua/lazyp/ui/zenmode%.lua%)$"),
		nil
	)
	eq(#child.lua([[return Maps:status().missed]]), 1)
end

return T
