# mini.test runner for every test dir under tests/ (f2 and map-plugin also have their own Makefile).
#   make                          all tests (default group: cases found slow are left out)
#   make dir D=telescope-keymaps  one dir
#   make dir D=comps011 G=lsp     one group: lsp cmp lint fast slow gather all (tests/helpers/timing.lua)
#   make timings                  show the recorded case times
# Runs from the config root, where tests/minimal_init.lua expects to be.

ROOT := ..
NVIM_TEST := nvim --headless --noplugin -u tests/minimal_init.lua
D ?= *
G ?=
FILTER := function(c) return require('helpers.timing').keep(c) end
TESTS := lua MiniTest.run({ collect = { find_files = function() return vim.fn.globpath('tests/$(D)', 'test_*.lua', true, true) end, filter_cases = $(FILTER) } })

.DEFAULT_GOAL := test
.PHONY: test dir timings

test:
	cd $(ROOT) && TEST_GROUP=$(G) $(NVIM_TEST) -c "$(TESTS)"

dir: test

timings:
	cd $(ROOT) && nvim --headless --clean -l tests/helpers/show-timings.lua
