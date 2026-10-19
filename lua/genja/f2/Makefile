# Tests for the <F2> context picker (mini.test); see readme.testing.md.
# Runs from the config root, where tests/minimal_init.lua expects to be.

ROOT := ../../..
NVIM_TEST := nvim --headless --noplugin -u tests/minimal_init.lua
F2_TESTS := lua MiniTest.run({ collect = { find_files = function() return vim.fn.globpath('tests/f2', 'test_*.lua', true, true) end } })

.DEFAULT_GOAL := test
.PHONY: test test-file

# all f2 tests
test:
	cd $(ROOT) && $(NVIM_TEST) -c "$(F2_TESTS)"

# one file: make test-file F=registry
test-file:
	cd $(ROOT) && $(NVIM_TEST) -c "lua MiniTest.run_file('tests/f2/test_$(F).lua')"
