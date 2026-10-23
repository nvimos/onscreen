-- :checkhealth genja.map-plugin: what lua/genja/map-plugin/init.lua saw this session.
-- Reads only the module's own records, not the log file. init.lua skips this file when it
-- loads the definition files.

local M = {}

function M.check()
	local status = require('genja.map-plugin'):status()
	local h = vim.health

	h.start('Lookups that found nothing (this session)')
	if #status.missed == 0 then
		h.ok('every Maps:keys() / Maps:mappings() call found its entry')
	end
	for _, miss in ipairs(status.missed) do
		h.warn('no ' .. miss.kind .. " for '" .. miss.name .. "', called from " .. miss.file,
			{ 'add lua/genja/map-plugin/' .. miss.name .. '.lua, or drop the call from the spec' })
	end
	h.info('log of all sessions: ' .. status.log)

	h.start('Registered, not asked for yet')
	if #status.keys_unasked == 0 then
		h.ok('every keys entry was asked for')
	else
		h.warn('keys no spec asked for (spec disabled, renamed, or keys = missing): '
			.. table.concat(status.keys_unasked, ', '))
	end
	if #status.mappings_unasked == 0 then
		h.ok('every mappings entry has run')
	else
		-- mappings() runs in a spec's config, so a plugin that hasn't loaded shows here
		h.info('mappings not used yet (plugin not loaded, or its spec is disabled): '
			.. table.concat(status.mappings_unasked, ', '))
	end
end

return M
