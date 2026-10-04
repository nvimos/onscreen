

refresh-spell:
	{ curl -s https://raw.githubusercontent.com/Traap/nvim/master/spell/en.utf-8.add ;\
	  cat spell/en.utf-8.add; } | sort -u  > ~/tmp/o; mv ~/tmp/o spell/en.utf-8.add

install-ungit:
	npm install -g ungit

