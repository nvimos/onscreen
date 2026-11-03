
all: sync
log:;   nvim --headless "+Lazy! log"   +qa
check:; nvim --headless "+Lazy! check" +qa

update: update-treesitter; nvim --headless "+Lazy! update" +qa
sync:   update-treesitter; nvim --headless "+Lazy! sync" +qa
mason:;                     nvim --headless "+Lazy! sync" "+MasonToolsInstallSync" +qa
update-treesitter:;         nvim --headless "+lua require('nvim-treesitter').update():wait(300000)" +qa # old. tool-installer does same


mason-luals:;               nvim --headless "+MasonInstall --force lua-language-server" +qa # random failure
mason-make:;                nvim --headless "+MasonInstall --force autotools-language-server" +qa # python installation moved from home to wingent install Python.Python.3.13 --scope machine
