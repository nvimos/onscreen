-- minuet in gitcommit buffers: the staged diff goes along with each request, the way
-- `git commit -v` shows it below the message, so the ghost text is about the changes.
-- Used by lua/lazyp/langs-comps/minuet.lua: fim_template() for the FIM providers
-- (codestral, openai_fim_compatible), chat_input() for the chat ones (gemini, openai, ...).

local M = {}

---Diff characters sent; minuet's own context_window (512) is the buffer part.
local DIFF_MAX = 4000
---The diff is read again after this many ms; typing must not run git per request.
local CACHE_MS = 10000
local SCISSORS = '# ------------------------ >8 ------------------------'

---@type table<integer, { time: integer, text: string }>
local cache = {}

---Staged diff for the current gitcommit buffer, '' elsewhere or without one.
---Repo dir: genja-commit's popup dir, else nvim's cwd (git starts the editor in the work tree).
---@return string
function M.staged_diff()
    local buf = vim.api.nvim_get_current_buf()
    if vim.bo[buf].filetype ~= 'gitcommit' then
        return ''
    end
    local now = vim.uv.now()
    local hit = cache[buf]
    if hit and now - hit.time < CACHE_MS then
        return hit.text
    end
    local dir = vim.b[buf].genja_commit_dir or vim.fn.getcwd()
    local res = vim.system({ 'git', 'diff', '--cached', '--no-color' }, { cwd = dir, text = true }):wait()
    local text = ''
    if res.code == 0 and res.stdout then
        text = res.stdout:sub(1, DIFF_MAX)
    end
    cache[buf] = { time = now, text = text }
    return text
end

---Text after the cursor plus the diff below git's scissors line; unchanged outside gitcommit
---and when the buffer already has a scissors line (`git commit -v`).
---@param after string
---@return string
local function with_diff(after)
    local diff = M.staged_diff()
    if diff == '' or after:find(SCISSORS, 1, true) then
        return after
    end
    return after .. '\n' .. SCISSORS .. '\n' .. diff
end

---FIM template: minuet's default prompt, the suffix gets the diff.
---@return table minuet.FIMTemplate
function M.fim_template()
    local default = require('minuet.config').default_fim_template
    return {
        prompt = default.prompt,
        suffix = function(before, after, opts)
            return with_diff(default.suffix(before, after, opts))
        end,
    }
end

---Chat input: minuet's default, the context after the cursor gets the diff.
---@return table minuet.ChatInput
function M.chat_input()
    local input = vim.deepcopy(require('minuet.config').default_chat_input)
    local after_default = input.context_after_cursor
    input.context_after_cursor = function(before, after, opts)
        return with_diff(after_default(before, after, opts))
    end
    return input
end

return M
