<#
.SYNOPSIS
Measure how long lua_ls takes to attach and to answer its first completion.

.DESCRIPTION
nvim with the real config opens a temp copy of tests/comps011/samples/ready-lua/main.lua
and waits for lua_ls to attach and to complete `hello` (tests/helpers/lsp-hello.lua).
The same check runs as `make test D=comps011 G=ready` in tests/.

Output, one line per run:
  total   nvim start to done, config load and exit included
  attach  opening the file to lua_ls attached
  ready   opening the file to the first completion with `hello`
  tries   completion requests sent; lua_ls answers empty lists while it indexes

.PARAMETER Runs
How many times to start nvim. The first run is cold, the rest warm. Default 1.

.PARAMETER TimeoutMs
Give up on a run after this many ms. Default 30000.

.PARAMETER NoLib
Set GENJA_LUA_NO_LIB=1, as the tests do: lazydev off, no workspace.library (lang/lua.lua).
Without it the variable is cleared, so a value left in the shell doesn't skew the numbers.

.PARAMETER Help
Show this help.

.EXAMPLE
pwsh -File tests/manual/measure-lua-ls.ps1 -Runs 3

.EXAMPLE
pwsh -File tests/manual/measure-lua-ls.ps1 -Runs 3 -NoLib
#>
param(
	[int]$Runs = 1,
	[int]$TimeoutMs = 30000,
	[switch]$NoLib,
	[switch]$Help
)
$ErrorActionPreference = 'Stop'

# the help text is the comment block above
if ($Help) {
	Get-Help $PSCommandPath -Detailed
	exit 0
}

# set or cleared either way, so a value left in the calling shell doesn't skew the numbers
if ($NoLib) {
	$env:GENJA_LUA_NO_LIB = '1'
} else {
	$env:GENJA_LUA_NO_LIB = $null
}

$tests = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path -replace '\\', '/'
$helper = "$tests/helpers/lsp-hello.lua"
$sample = Join-Path $tests 'comps011/samples/ready-lua'

# mason's bin first, as the tests do: in a fresh nvim mason may not have set PATH yet
$env:PATH = (Join-Path $env:LOCALAPPDATA 'nvim-data/mason/bin') + ';' + $env:PATH

for ($i = 1; $i -le $Runs; $i++) {
	# a temp copy, outside any .git: lua_ls runs in single-file mode, as in the tests
	$dir = Join-Path ([IO.Path]::GetTempPath()) "measure-lua-ls-$PID-$i"
	Copy-Item -Recurse $sample $dir
	$file = (Join-Path $dir 'main.lua') -replace '\\', '/'

	$lua = "lua local r = dofile('$helper').measure('$file', 'hello', $TimeoutMs); io.stdout:write(vim.json.encode(r) .. '\n')"
	$watch = [Diagnostics.Stopwatch]::StartNew()
	$out = nvim --headless --cmd 'let g:genja_lsp_no_install = v:true' -c $lua -c 'qa!' 2>&1
	$total = $watch.ElapsedMilliseconds
	Remove-Item -Recurse -Force $dir

	$json = $out | Where-Object { $_ -like '{*' } | Select-Object -Last 1
	if (-not $json) {
		Write-Output "run ${i}: no result, nvim said: $out"
		continue
	}
	$r = $json | ConvertFrom-Json
	if ($r.error) {
		Write-Output ("run {0}: {1} (total {2} ms, attach {3} ms, {4} tries)" -f $i, $r.error, $total, $r.attach_ms, $r.tries)
	} else {
		Write-Output ("run {0}: total {1,5} ms   attach {2,5} ms   ready {3,5} ms   {4} tries" -f $i, $total, $r.attach_ms, $r.ready_ms, $r.tries)
	}
}
