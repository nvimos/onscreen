# Tests for map-plugin (mini.test): miss log and :checkhealth genja.map-plugin.
# Runs from the config root, where tests/minimal_init.lua expects to be.

ROOT := ../../..
NVIM_TEST := nvim --headless --noplugin -u tests/minimal_init.lua
TESTS := lua MiniTest.run({ collect = { find_files = function() return vim.fn.globpath('tests/map-plugin', 'test_*.lua', true, true) end } })

.DEFAULT_GOAL := test
.PHONY: test

test:
	cd $(ROOT) && $(NVIM_TEST) -c "$(TESTS)"
