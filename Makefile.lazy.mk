
all: sync
log:;   nvim --headless "+Lazy! log"   +qa
check:; nvim --headless "+Lazy! check" +qa

update: update-treesitter; nvim --headless "+Lazy! update" +qa
sync:   update-treesitter; nvim --headless "+Lazy! sync" +qa
mason: kill-luals;          nvim --headless "+Lazy! sync" "+MasonToolsInstallSync" +qa
update-treesitter:;         nvim --headless "+lua require('nvim-treesitter').update():wait(300000)" +qa # old. tool-installer does same


# a running lua_ls locks its mason folder: the update deletes half of it and stops (no receipt)
kill-luals:;                pwsh.exe -NoProfile -NoLogo -Command "Get-Process lua-language-server -ErrorAction SilentlyContinue | Stop-Process -Force -PassThru | Wait-Process -Timeout 5 -ErrorAction SilentlyContinue; exit 0"
mason-luals: kill-luals;    nvim --headless "+MasonInstall --force lua-language-server" +qa
mason-make:;                nvim --headless "+MasonInstall --force autotools-language-server" +qa # python installation moved from home to wingent install Python.Python.3.13 --scope machine
