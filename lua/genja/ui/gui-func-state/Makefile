# Tests for the GuiFuncs picker state (mini.test).
# Runs from this folder; tests/minimal_init.lua finds the config root from its own path.

INIT := ../../../../tests/minimal_init.lua
NVIM_TEST := nvim --headless --noplugin -u $(INIT)
# nvim-qt forwards the args after -- to nvim; the report stays open in the window
NVIM_QT_TEST := nvim-qt -- --noplugin -u $(INIT)

.DEFAULT_GOAL := test
.PHONY: test test-gui

# test_state.lua: discover_styles
test:
	$(NVIM_TEST) -c "lua MiniTest.run_file('test_state.lua')"

# test_state_gui.lua: style list and cycling against a real nvim-qt
# run_gui.lua writes gui-report.txt and quits nvim-qt; fails if any case failed
test-gui:
	rm -f gui-report.txt
	$(NVIM_QT_TEST) -c "luafile run_gui.lua"
	@cat gui-report.txt
	@if grep -q '^Fail' gui-report.txt; then exit 1; fi
