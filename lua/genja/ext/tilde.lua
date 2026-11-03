--[[

Tilde or ~ toggles switches (value or expression) under the cursor
or fall back to default ~ behavior if nothing matches, which
switching the case of a character.

This is a lua port of TildeToggleUnderCursor from vimrc.almalinux.vim.

The key is mapped in map-zero.lua (Toggles).

Flip switches

    - true/false
    - on/off
    - 1/0
    - +/-
    - </>


Markdown

Toggle checkmark

    - on a `- [ ]` line with no switch under the cursor
    - cycles the box:
        - blank: open
        - x: done
        - n: wont-fix
        - .: wip
        - ~: partially-done


Alternative / similar ideas:

    - dial.nvim (<C-a>/<C-x>, lua/lazyp/new/dial.lua)
        - covers numbers, dates and longer cycles.

]] --

local M = {}

-- word -> its opposite; both directions are added below. Lowercase only:
-- `True` and `TRUE` keep their case.
---@type table<string, string>
local word_pairs = {
    ['true'] = 'false',
    ['on'] = 'off',
    ['yes'] = 'no',
    ['enable'] = 'disable',
    ['enabled'] = 'disabled',
    ['and'] = 'or',
    ['0'] = '1',
    ['left'] = 'right',
    ['up'] = 'down',
    ['min'] = 'max',
    ['first'] = 'last',
}

---@type table<string, string>
local char_pairs = {
    ['+'] = '-',
    ['<'] = '>',
}

---@param pairs_tbl table<string, string>
---@return table<string, string>
local function both_ways(pairs_tbl)
    local out = {}
    for a, b in pairs(pairs_tbl) do
        out[a] = b
        out[b] = a
    end
    return out
end

local words = both_ways(word_pairs)
local chars = both_ways(char_pairs)

--- Copy the case of `like` onto `word`: all upper, first upper, else lower.
---@param word string
---@param like string
---@return string
local function same_case(word, like)
    -- has letters and all of them upper case
    local function upper(s)
        return s:upper() == s and s:lower() ~= s
    end
    if upper(like) then
        return word:upper()
    end
    if upper(like:sub(1, 1)) then
        return word:sub(1, 1):upper() .. word:sub(2)
    end
    return word
end

---@param line string
---@param col integer 1-based
---@return integer? first, integer? last 1-based bounds of the [%w_] run under col
local function word_bounds(line, col)
    if not line:sub(col, col):match('[%w_]') then
        return nil, nil
    end
    local first = col
    while first > 1 and line:sub(first - 1, first - 1):match('[%w_]') do
        first = first - 1
    end
    local last = col
    while last < #line and line:sub(last + 1, last + 1):match('[%w_]') do
        last = last + 1
    end
    return first, last
end

---@param row integer 1-based
---@param first integer 1-based
---@param last integer 1-based
---@param text string
local function replace(row, first, last, text)
    vim.api.nvim_buf_set_text(0, row - 1, first - 1, row - 1, last, { text })
end

-- markdown checkbox state -> next state
---@type table<string, string>
local check_next = {
    [' '] = 'x',
    ['x'] = 'n',
    ['n'] = '.',
    ['.'] = '~',
    ['~'] = ' ',
}

--- Markdown: cycle the `- [ ]` box on this line, cursor anywhere on it.
---@param row integer 1-based
---@param line string
---@return boolean done
local function toggle_checkbox(row, line)
    if vim.bo.filetype ~= 'markdown' then
        return false
    end
    local prefix, state = line:match('^(%s*[-*+] %[)(.)%]')
    if not prefix then
        prefix, state = line:match('^(%s*%d+[.)] %[)(.)%]')
    end
    if not prefix or not check_next[state] then
        return false
    end
    local col = #prefix + 1
    replace(row, col, col, check_next[state])
    return true
end

--- Toggle the switch under the cursor; plain `~` (with count) when there is none.
function M.toggle()
    local count = vim.v.count1
    local row, col0 = unpack(vim.api.nvim_win_get_cursor(0))
    local col = col0 + 1
    local line = vim.api.nvim_get_current_line()

    local ch = line:sub(col, col)
    if count == 1 and chars[ch] then
        replace(row, col, col, chars[ch])
        return
    end

    local first, last = word_bounds(line, col)
    if count == 1 and first and last then
        local word = line:sub(first, last)
        local other = words[word:lower()]
        if other then
            local new = same_case(other, word)
            replace(row, first, last, new)
            -- cursor on the word's last char, like the alma version
            vim.api.nvim_win_set_cursor(0, { row, first - 1 + #new - 1 })
            return
        end
    end

    -- after the switches: a word or char under the cursor wins over the box
    if count == 1 and toggle_checkbox(row, line) then
        return
    end

    vim.cmd('normal! ' .. count .. '~')
end

return M
