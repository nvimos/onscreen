-- revert to previous versions of edits; key in lua/genja/map-zero.lua
---@type LazySpec
return {
	'mbbill/undotree',
	cmd = 'UndotreeToggle',
	init = function()
		-- undotree shells out to `diff`; Windows has none on PATH, Git for Windows ships one.
		if vim.fn.has('win32') ~= 1 or vim.fn.executable('diff') == 1 then
			return
		end

		local candidates = {}
		local git = vim.fn.exepath('git') -- ...\Git\cmd\git.exe or ...\Git\mingw64\bin\git.exe
		if git ~= '' then
			for dir in vim.fs.parents(git) do
				table.insert(candidates, vim.fs.joinpath(dir, 'usr', 'bin', 'diff.exe'))
			end
		end
		table.insert(candidates, 'C:/Program Files/Git/usr/bin/diff.exe')
		table.insert(candidates, vim.fn.expand('~/scoop/apps/git/current/usr/bin/diff.exe'))

		for _, diff in ipairs(candidates) do
			if vim.fn.executable(diff) == 1 then
				-- undotree runs `system(cmd .. ' ' .. tmp1 .. ' ' .. tmp2)` unquoted and splits
				-- on whitespace for its executable() check, so the path must have no spaces.
				local short = vim.fn.fnamemodify(diff, ':8') -- C:\PROGRA~1\Git\...
				if not short:find(' ') then
					vim.g.undotree_DiffCommand = short
				else
					-- 8.3 names disabled on this volume: expose the dir on PATH instead
					vim.env.PATH = vim.env.PATH .. ';' .. vim.fs.dirname(diff)
				end
				return
			end
		end
	end,
}
