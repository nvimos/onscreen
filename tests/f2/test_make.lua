-- f2 make.lua: parsing `make -rRpq`, makefile prefixes, task order and labels.
-- Pure functions; runs in the test process.

local eq = MiniTest.expect.equality
local make = require('genja.f2.collect.make')

-- trimmed `make -rRpq` dump: the parts parse_targets reads
local DUMP = table.concat({
	'# GNU Make 4.4.1',
	'MAKEFILE_LIST :=  Makefile Makefile.lazy.mk',
	'# Files',
	'',
	'# Not a target:',
	'Makefile:',
	'#  Implicit rule search has not been done.',
	'',
	'all: sync',
	'#  Phony target (prerequisite of .PHONY).',
	'',
	'sync:',
	'#  recipe to execute (from \'Makefile.lazy.mk\', line 3):',
	'\tnvim --headless "+Lazy! sync" +qa',
	'',
	'refresh-spell:',
	'',
	'.PHONY: all sync',
	'',
	'%.o: %.c',
	'',
	'Makefile.lazy.mk:',
	'',
	'# Finished Make data base on Mon Oct 19 2026',
	'after-the-end:',
}, '\r\n') -- make on Windows may print CRLF

local T = MiniTest.new_set()

T['parse_targets'] = MiniTest.new_set()

T['parse_targets']['keeps real targets only'] = function()
	local targets = make._parse_targets(DUMP)
	eq(targets, { 'all', 'sync', 'refresh-spell' })
end

T['parse_targets']['returns MAKEFILE_LIST'] = function()
	local _, makefiles = make._parse_targets(DUMP)
	eq(makefiles, { 'Makefile', 'Makefile.lazy.mk' })
end

T['makefile_prefix'] = function()
	eq(make._makefile_prefix('Makefile'), '')
	eq(make._makefile_prefix('GNUmakefile'), '')
	eq(make._makefile_prefix('Makefile.lazy.mk'), 'lazy')
	eq(make._makefile_prefix('Makefile-gitea.mk'), 'gitea')
	eq(make._makefile_prefix('tools.mk'), 'tools')
	eq(make._makefile_prefix('sub/Makefile.lazy.mk'), 'lazy')
end

T['sorted_tasks: main Makefile first, then by prefix and name'] = function()
	local tasks = make._sorted_tasks(
		{ 'sync', 'all', 'refresh-spell', 'push' },
		{ sync = 'lazy', all = '', ['refresh-spell'] = '', push = 'gitea' },
		'C:/cfg'
	)
	local labels = {}
	for _, t in ipairs(tasks) do
		table.insert(labels, t.label)
	end
	eq(labels, { 'all', 'refresh-spell', 'gitea: push', 'lazy: sync' })
end

T['sorted_tasks: task fields'] = function()
	local t = make._sorted_tasks({ 'sync' }, { sync = 'lazy' }, 'C:/cfg')[1]
	eq({ t.group, t.label, t.cmd, t.cwd, t.order }, { 'make', 'lazy: sync', { 'make', 'sync' }, 'C:/cfg', 1 })
end

return T
