
all: sync
log:; nvim --headless "+Lazy! log" +qa
check:; nvim --headless "+Lazy! check" +qa
update:; nvim --headless "+Lazy! update" +qa
sync:; nvim --headless "+Lazy! sync" +qa
