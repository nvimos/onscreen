-- :CheckHealthSimpleMinuet (plugin/minuet-status.lua): minuet's provider, model, API key and frontends in a float.
-- Modelled on :CheckHealthSimpleLsp (plug-wip/genja-completion011.nvim/lua/genja/lsp/check.lua).
--
--   PASS  the current provider answered the test request (always the same: complete
--         `return a` in `def add(a, b):`, expecting `+ b`)
--   FAIL  minuet missing, key unset, ollama down, model not pulled, or a wrong or no answer
-- The float opens with the static checks; the test request fills in its line when it returns.
--
-- Shows nothing about API keys except that one is not set.
local SRC = 'lua/genja/ext/minuet-status.lua: '

local M = {}

local NS = vim.api.nvim_create_namespace('genja.minuet-status')

---@class genja.CheckHealthSimpleMinuet.Report
---@field lines string[]
---@field highlights (string|false)[] one per line; false: no highlight
---@field verdict 'PASS'|'FAIL'
---@field verdict_hl string
---@field answer_line integer|nil 1-based line the test request fills in; nil: no request

-- The test request: same question every time, through minuet's backend for the current provider.
local TEST = {
    lines_before = 'def add(a, b):\n    return a',
    lines_after = '\n\n\nprint(add(2, 3))\n',
    expect = '%+%s*b', -- Lua pattern the answer must contain
    shown = 'def add(a, b): return a|  ->  expects + b',
}

---Is a key set? Only the answer is shown, never the key or where it comes from.
---@param api_key string|function|nil env var name or function, as in minuet's config
---@return boolean
local function key_set(api_key)
    local value = nil
    if type(api_key) == 'function' then
        local ok, v = pcall(api_key)
        if ok then
            value = v
        end
    elseif type(api_key) == 'string' then
        value = vim.env[api_key]
    end
    return type(value) == 'string' and value ~= ''
end

---Base URL of a local server (localhost or 127.0.0.1), else nil.
---@param end_point string|nil
---@return string|nil
local function local_base(end_point)
    if type(end_point) ~= 'string' then
        return nil
    end
    return end_point:match('^(https?://localhost:%d+)') or end_point:match('^(https?://127%.0%.0%.1:%d+)')
end

---Models of a local ollama, or nil and the reason.
---@param base string
---@return string[]|nil models, string|nil err
local function ollama_models(base)
    local r = vim.system({ 'curl', '-s', '--max-time', '2', base .. '/api/tags' }, { text = true }):wait(3000)
    if r.code ~= 0 then
        return nil, ('no answer from %s (curl exit %s); is `ollama serve` running?'):format(base, tostring(r.code))
    end
    local ok, data = pcall(vim.json.decode, r.stdout or '')
    if not ok or type(data) ~= 'table' or type(data.models) ~= 'table' then
        return nil, base .. '/api/tags: not an ollama answer'
    end
    local names = {}
    for _, m in ipairs(data.models) do
        table.insert(names, m.name)
    end
    return names, nil
end

---@return genja.CheckHealthSimpleMinuet.Report
function M.check()
    local lines, highlights = {}, {}
    local function add(text, hl)
        lines[#lines + 1] = text
        highlights[#highlights + 1] = hl or false
    end

    -- require loads the plugin through lazy.nvim, which runs setup()
    local ok, minuet = pcall(require, 'minuet')
    ---@cast minuet { config: table|nil }
    if not ok or minuet.config == nil then
        add('FAIL  minuet-ai.nvim is not installed or not set up', 'DiagnosticError')
        add('  spec: lua/lazyp/langs-comps/minuet.lua', 'Comment')
        return { lines = lines, highlights = highlights, verdict = 'FAIL', verdict_hl = 'DiagnosticError' }
    end
    local config = minuet.config
    local provider = config.provider
    local opts = config.provider_options[provider] or {}

    local problems = {}
    local has_key = key_set(opts.api_key)
    local base = local_base(opts.end_point)
    local server_text = nil
    if base then
        -- a local server needs no real key; the server and the model matter
        local models, err = ollama_models(base)
        if models == nil then
            server_text = err
            table.insert(problems, err)
        elseif vim.tbl_contains(models, opts.model) then
            server_text = ('%s answers, %s is pulled'):format(base, opts.model)
        else
            server_text = ('%s answers, but has no %s: ollama pull %s'):format(base, opts.model, opts.model)
            table.insert(problems, 'model not pulled')
        end
    elseif not has_key then
        table.insert(problems, 'API key not set')
    end

    local verdict, verdict_hl, detail
    if #problems == 0 then
        verdict, verdict_hl = 'PASS', 'DiagnosticOk'
        detail = ('%s can answer'):format(provider)
    else
        verdict, verdict_hl = 'FAIL', 'DiagnosticError'
        detail = ('%s: %s'):format(provider, table.concat(problems, '; '))
    end

    add(verdict .. '  ' .. detail, verdict_hl)
    add('')

    add('Current provider', 'Title')
    add('  provider: ' .. provider)
    if opts.name then
        add('  name: ' .. opts.name)
    end
    add('  model: ' .. tostring(opts.model))
    add('  end point: ' .. tostring(opts.end_point or 'provider default'))
    if base == nil and not has_key then
        add('  api key: NOT SET (lua/genja/local/secrets.lua)', 'DiagnosticError')
    end
    if server_text then
        add('  server: ' .. server_text, #problems > 0 and 'DiagnosticError' or 'DiagnosticOk')
    end
    -- the spec's curl_extra_args holds the timeout and retry per provider
    local extra = config.curl_extra_args
    if type(extra) == 'function' then
        local ok_args, value = pcall(extra)
        extra = ok_args and value or {}
    end
    if type(extra) == 'table' and #extra > 0 then
        add('  curl: ' .. table.concat(extra, ' '))
    end
    if config.request_timeout and config.request_timeout > 0 then
        add('  request timeout: ' .. tostring(config.request_timeout) .. ' s')
    end

    add('Test request', 'Title')
    add('  asked: ' .. TEST.shown)
    local answer_line = nil
    if #problems == 0 then
        add('  answer: waiting ...', 'Comment')
        answer_line = #lines
    else
        add('  answer: not sent, fix the above first', 'Comment')
    end

    add('Frontends', 'Title')
    local blink_auto = config.blink and config.blink.enable_auto_complete
    add('  blink: ' .. (blink_auto and 'auto-complete on' or '<M-y> only') .. '  (<leader>aM toggles)')
    local vt = vim.b.minuet_virtual_text_auto_trigger
    add('  ghost text, this buffer: ' .. (vt and 'on' or 'off') .. '  (<leader>am toggles)')

    add('Other providers', 'Title')
    local names = vim.tbl_keys(config.provider_options)
    table.sort(names)
    for _, name in ipairs(names) do
        if name ~= provider then
            local o = config.provider_options[name]
            local text = ''
            local hl = nil ---@type string|nil
            if not key_set(o.api_key) then
                text = 'key not set'
                hl = 'Comment' -- dim: can't be used as is
            end
            add(('  %-22s %-28s %s'):format(name, tostring(o.model), text), hl)
        end
    end
    add('')
    add('  switch: :Minuet change_model <provider>:<model>   (this session only)', 'Comment')

    return {
        lines = lines,
        highlights = highlights,
        verdict = verdict,
        verdict_hl = verdict_hl,
        answer_line = answer_line,
    }
end

---Replace line `lnum` (1-based) of the float and its highlight.
---@param buf integer
---@param lnum integer
---@param text string
---@param hl string|nil
local function set_line(buf, lnum, text, hl)
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, lnum - 1, lnum, false, { text })
    vim.bo[buf].modifiable = false
    vim.api.nvim_buf_clear_namespace(buf, NS, lnum - 1, lnum)
    if hl then
        vim.api.nvim_buf_set_extmark(buf, NS, lnum - 1, 0, { end_col = #text, hl_group = hl })
    end
end

---Readable part of a minuet error notice: the API's "code: message", else the notice itself.
---@param notice string
---@return string
local function error_text(notice)
    local message = notice:match('"message":%s*"(.-)"%s*[,}\'\n]')
    if message == nil then
        return (notice:gsub('%s+', ' '))
    end
    local code = notice:match('"code":%s*(%d+)')
    if code then
        return ('%s: %s'):format(code, message)
    end
    return message
end

---Send the test request and write the answer into the float.
---@param report genja.CheckHealthSimpleMinuet.Report
---@param buf integer
---@param win integer
local function test_request(report, buf, win)
    local config = require('minuet').config
    local backend = require('minuet.backends.' .. config.provider)
    local context = {
        lines_before = TEST.lines_before,
        lines_after = TEST.lines_after,
        opts = { is_incomplete_before = false, is_incomplete_after = false },
    }
    -- minuet reports errors only through utils.notify, the callback just gets no items;
    -- catch the notices while the request runs (they still show as usual)
    local utils = require('minuet.utils')
    local notify = utils.notify
    local notices = {}
    utils.notify = function(msg, ...)
        table.insert(notices, msg)
        return notify(msg, ...)
    end
    local restored = false
    local function restore()
        if not restored then
            restored = true
            utils.notify = notify
        end
    end
    vim.defer_fn(restore, 20000) -- in case the callback never comes

    local start = vim.uv.hrtime()
    local ok, err = pcall(backend.complete, context, vim.schedule_wrap(function(items)
        restore()
        if not vim.api.nvim_buf_is_valid(buf) then
            return
        end
        local ms = math.floor((vim.uv.hrtime() - start) / 1e6)
        local first = items and items[1]
        local verdict, hl, text
        if first == nil or first == '' then
            verdict, hl = 'FAIL', 'DiagnosticError'
            if #notices > 0 then
                text = ('  answer: none after %d ms: %s'):format(ms, error_text(notices[#notices]))
            else
                text = ('  answer: none after %d ms (timeout or empty; see :messages)'):format(ms)
            end
        else
            local shown = vim.trim(first):gsub('\n', '\\n')
            if first:find(TEST.expect) then
                verdict, hl = 'PASS', 'DiagnosticOk'
            else
                verdict, hl = 'FAIL', 'DiagnosticWarn'
            end
            text = ('  answer: %s  (%d ms)'):format(shown, ms)
        end
        set_line(buf, report.answer_line, text, hl)
        set_line(buf, 1, ('%s  %s %s'):format(verdict, config.provider,
            verdict == 'PASS' and 'answered the test request' or 'did not answer the test request as expected'), hl)
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_set_config(win, { title = { { (' Minuet: %s '):format(verdict), hl } }, title_pos = 'center' })
        end
    end))
    if not ok then
        restore()
        error(err, 0)
    end
end

---Show a report in a float. q or <Esc> closes it.
---@param report genja.CheckHealthSimpleMinuet.Report
---@return integer buf, integer win
local function show(report)
    local lines = report.lines
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    for i, hl in ipairs(report.highlights) do
        if hl then
            vim.api.nvim_buf_set_extmark(buf, NS, i - 1, 0, { end_col = #lines[i], hl_group = hl })
        end
    end
    vim.bo[buf].bufhidden = 'wipe'
    vim.bo[buf].modifiable = false

    -- sized to the content; the height counts wrapped lines
    local longest = 0
    for _, text in ipairs(lines) do
        longest = math.max(longest, vim.fn.strdisplaywidth(text))
    end
    local max_width = math.max(20, math.floor(vim.o.columns * 0.85))
    local width = math.min(math.max(longest + 2, 50), max_width)
    local height = 0
    for _, text in ipairs(lines) do
        height = height + math.max(1, math.ceil(vim.fn.strdisplaywidth(text) / width))
    end
    height = math.max(1, math.min(height, math.floor(vim.o.lines * 0.6)))

    local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = width,
        height = height,
        row = math.max(0, math.floor((vim.o.lines - height) / 2) - 1),
        col = math.max(0, math.floor((vim.o.columns - width) / 2)),
        style = 'minimal',
        border = 'rounded',
        title = { { (' Minuet: %s '):format(report.verdict), report.verdict_hl } },
        title_pos = 'center',
    })
    vim.wo[win].wrap = true

    for _, lhs in ipairs({ 'q', '<Esc>' }) do
        vim.keymap.set('n', lhs, '<cmd>close<CR>', { buffer = buf, silent = true, nowait = true })
    end
    return buf, win
end

function M.open()
    -- check first: the float changes the current buffer, and vim.b is per buffer
    local ok, report = pcall(M.check)
    if not ok then
        vim.notify(SRC .. tostring(report), vim.log.levels.ERROR)
        return
    end
    local buf, win = show(report)
    if report.answer_line then
        local sent, err = pcall(test_request, report, buf, win)
        if not sent then
            set_line(buf, report.answer_line, '  answer: ' .. tostring(err), 'DiagnosticError')
        end
    end
end

return M
