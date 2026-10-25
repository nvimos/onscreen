
all: sync
log:;   nvim --headless "+Lazy! log"   +qa
check:; nvim --headless "+Lazy! check" +qa

update:; update-treesitter; nvim --headless "+Lazy! update" +qa
sync:;   update-treesitter; nvim --headless "+Lazy! sync" +qa
mason:;                     nvim --headless "+Lazy! sync" "+MasonToolsInstallSync" +qa
mason-luals:;               nvim --headless "+MasonInstall --force lua-language-server" +qa
update-treesitter:;         nvim --headless "+lua require('nvim-treesitter').update():wait(300000)" +qa # old. tool-installer does same
