
" Frameless only when the nvim-qt window fills its monitor's work area (screen minus taskbar) {{{
lua << EOF
local SRC = 'ginit.vim: '
-- Largest visible top-level window of nvim-qt (our parent process) vs its monitor's work area.
local function fills_work_area()
	local ffi = require('ffi')
	pcall(ffi.cdef, [[
		typedef struct { long left, top, right, bottom; } GENJA_RECT;
		typedef struct { unsigned long cbSize; GENJA_RECT rcMonitor; GENJA_RECT rcWork; unsigned long dwFlags; } GENJA_MONITORINFO;
		typedef int (__stdcall *GENJA_ENUMPROC)(void *hwnd, intptr_t lparam);
		int EnumWindows(GENJA_ENUMPROC cb, intptr_t lparam);
		unsigned long GetWindowThreadProcessId(void *hwnd, unsigned long *pid);
		int IsWindowVisible(void *hwnd);
		int GetWindowRect(void *hwnd, GENJA_RECT *rect);
		void *MonitorFromWindow(void *hwnd, unsigned long flags);
		int GetMonitorInfoW(void *monitor, GENJA_MONITORINFO *info);
	]])
	local user32 = ffi.load('user32')
	local gui_pid = vim.uv.os_getppid()
	local pid = ffi.new('unsigned long[1]')
	local rect = ffi.new('GENJA_RECT')
	local best_hwnd = nil
	local best_area = 0

	local cb = ffi.cast('GENJA_ENUMPROC', function(hwnd)
		user32.GetWindowThreadProcessId(hwnd, pid)
		if pid[0] == gui_pid and user32.IsWindowVisible(hwnd) ~= 0 and user32.GetWindowRect(hwnd, rect) ~= 0 then
			local area = (rect.right - rect.left) * (rect.bottom - rect.top)
			if area > best_area then
				best_area = area
				best_hwnd = hwnd
			end
		end
		return 1
	end)
	user32.EnumWindows(cb, 0)
	cb:free()

	if best_hwnd == nil then
		return false
	end
	user32.GetWindowRect(best_hwnd, rect)
	local info = ffi.new('GENJA_MONITORINFO')
	info.cbSize = ffi.sizeof(info)
	local MONITOR_DEFAULTTONEAREST = 2
	if user32.GetMonitorInfoW(user32.MonitorFromWindow(best_hwnd, MONITOR_DEFAULTTONEAREST), info) == 0 then
		return false
	end

	-- Win10/11 rects include ~7px invisible borders, so a full-size window is a bit larger than the work area.
	local tol = 16
	local work = info.rcWork
	local w_ok = (rect.right - rect.left) >= (work.right - work.left) - tol
	local h_ok = (rect.bottom - rect.top) >= (work.bottom - work.top) - tol
	return w_ok and h_ok
end

-- Deferred: nvim-qt may still be applying its saved geometry when ginit.vim runs.
vim.defer_fn(function()
	if jit.os ~= 'Windows' or vim.fn.exists('*GuiWindowFrameless') == 0 then
		return
	end
	local ok, result = pcall(fills_work_area)
	if not ok then
		vim.notify(SRC .. 'window size check failed: ' .. tostring(result), vim.log.levels.WARN)
		return
	end
	if result then
		vim.fn.GuiWindowFrameless(1)
	end
end, 100)
EOF
" }}}
