-- Init for mini.test, used by the test runner and by each child nvim.
-- Run from the config root:
--   nvim --headless --noplugin -u tests/minimal_init.lua -c "lua MiniTest.run()"
-- One file: -c "lua MiniTest.run_file('tests/f2/test_registry.lua')"

-- this file is <config>/tests/minimal_init.lua
local root = vim.fs.dirname(vim.fs.dirname(vim.fs.normalize(debug.getinfo(1, 'S').source:sub(2))))

-- children start with --clean, so the config is not on the rtp by default
vim.opt.rtp:prepend(root)
vim.opt.rtp:prepend(vim.fn.stdpath('data') .. '/lazy/mini.test')
-- require('helpers.timing') etc. from tests/helpers/
package.path = root .. '/tests/?.lua;' .. package.path

require('mini.test').setup()
