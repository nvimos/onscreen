# mini.test runner for every test dir under tests/ (f2 and map-plugin also have their own Makefile).
# Recipes are PowerShell (pwsh 7); each line runs in its own pwsh, so Set-Location and $env: don't leak.
# Runs from the config root, where tests/minimal_init.lua expects to be.
# `make help` prints the `##` lines below in file order: `## text` as is, `target: ## text` as a target row.

## mini.test runner for tests/<dir>/test_*.lua
##
## variables:
##   D=<dir>    select subdir under tests
##   G=<group>  select group
##     unset    default: every case except the slow ones
##     gather   every case, slow ones too: refreshes all recorded times
##     fast     only cases that have not been flagged as slow
##     slow     only cases flagged as slow
##     mason warmup lsp ready cmp lint   one area of comps011, slow ones included
##     lua_ls typos ...           one case name of comps011
##   V=1 V=2    verbose, more verbose
##   GENJA_LUA_NO_LIB=1  lua_ls skips libraries: no lazydev, no workspace.library
##
## targets:

SHELL := pwsh.exe
.SHELLFLAGS := -NoProfile -NoLogo -NonInteractive -Command

ROOT := ..
NVIM_TEST := nvim --headless --noplugin -u tests/minimal_init.lua
# the real config, as the tests' child boots it (mason installs nothing)
NVIM_REAL := nvim --headless --cmd 'let g:genja_lsp_no_install = v:true'
D ?=
G ?=
V ?=
# set by the failed target only
FAILED ?=

# tests check that lua_ls works, not its libraries; read by lang/lua.lua and the lazydev spec
GENJA_LUA_NO_LIB ?= 1
export GENJA_LUA_NO_LIB

.DEFAULT_GOAL := test
.PHONY: test gather failed plan slow status list list-sh timings help

test: ## run tests (default)
	Set-Location $(ROOT); $$env:TEST_DIR = '$(D)'; $$env:TEST_GROUP = '$(G)'; $$env:TEST_VERBOSE = '$(V)'; $$env:TEST_FAILED = '$(FAILED)'; $(NVIM_TEST) -c 'luafile tests/helpers/run-tests.lua'

# G set for this target only; make passes it on to test's recipe
gather: G = gather
gather: test ## run all tests, slow ones too

failed: FAILED = 1
failed: V = 1
failed: test ## rerun the tests that failed last time

plan: ## show which tests would run or skip, and why
	@Set-Location $(ROOT); $$env:TEST_DIR = '$(D)'; $$env:TEST_GROUP = '$(G)'; $(NVIM_REAL) -c 'luafile tests/helpers/plan.lua' -c 'qa!'

slow: ## show the tests left out as slow
	@Set-Location $(ROOT); $$env:TEST_DIR = '$(D)'; $(NVIM_TEST) -c 'luafile tests/helpers/slow-tests.lua' -c 'qa!'

status: ## show languages, servers, tools, linters: installed or missing
	@Set-Location $(ROOT); $(NVIM_REAL) -c 'luafile tests/helpers/status.lua' -c 'qa!'

list: ## show dirs and groups
	Set-Location $(ROOT); $(NVIM_TEST) -c 'luafile tests/helpers/list-tests.lua' -c 'qa!'

list-sh: ## print a make command for every dir and group
	@Set-Location $(ROOT); $$env:LIST_MODE = 'sh'; $(NVIM_TEST) -c 'luafile tests/helpers/list-tests.lua' -c 'qa!'

timings: ## show recorded test times, slowest last
	Set-Location $(ROOT); $$env:TEST_VERBOSE = '$(V)'; nvim --headless --clean -l tests/helpers/show-timings.lua

help: ## this help
	@Get-Content '$(firstword $(MAKEFILE_LIST))' | ForEach-Object { if ($$_ -match '^([a-zA-Z0-9_-]+):.*## (.*)') { '  {0,-10} {1}' -f $$Matches[1], $$Matches[2] } elseif ($$_ -match '^## ?(.*)') { $$Matches[1] } }
