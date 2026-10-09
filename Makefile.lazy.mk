
all: sync
log:; nvim --headless "+Lazy! log" +qa
check:; nvim --headless "+Lazy! check" +qa
# :TSUpdate is async on nvim-treesitter main; :wait() keeps headless nvim open until parsers are built.
update: update-treesitter
	nvim --headless "+Lazy! update" +qa
sync: update-treesitter
	nvim --headless "+Lazy! sync" +qa


update-treesitter:
	nvim --headless "+lua require('nvim-treesitter').update():wait(300000)" +qa
