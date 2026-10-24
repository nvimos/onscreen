# mini.test runner for every test dir under tests/ (f2 and map-plugin also have their own Makefile).
#   make            all tests
#   make dir D=telescope-keymaps
# Runs from the config root, where tests/minimal_init.lua expects to be.

ROOT := ..
NVIM_TEST := nvim --headless --noplugin -u tests/minimal_init.lua
D ?= *
TESTS := lua MiniTest.run({ collect = { find_files = function() return vim.fn.globpath('tests/$(D)', 'test_*.lua', true, true) end } })

.DEFAULT_GOAL := test
.PHONY: test dir

test:
	cd $(ROOT) && $(NVIM_TEST) -c "$(TESTS)"

dir: test
