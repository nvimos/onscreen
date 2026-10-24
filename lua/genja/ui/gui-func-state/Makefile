# Tests for the GuiFuncs picker state (mini.test).
# Runs from the config root, where tests/minimal_init.lua expects to be.

ROOT := ../../../../..
NVIM_TEST := nvim --headless --noplugin -u tests/minimal_init.lua
# nvim-qt forwards the args after -- to nvim; the report stays open in the window
NVIM_QT_TEST := nvim-qt -- --noplugin -u tests/minimal_init.lua
DIR := lua/genja/ui/gui-func-state

.DEFAULT_GOAL := test
.PHONY: test test-gui

# test_state.lua: discover_styles
test:
	cd $(ROOT) && $(NVIM_TEST) -c "lua MiniTest.run_file('$(DIR)/test_state.lua')"

# test_state_gui.lua: style list and cycling against a real nvim-qt
test-gui:
	cd $(ROOT) && $(NVIM_QT_TEST) -c "lua MiniTest.run_file('$(DIR)/test_state_gui.lua')"
