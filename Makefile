include Makefile.lazy.mk Makefile.gitea.mk

# explicit: the includes come first, so their first target (lazy's `all`) would win
.DEFAULT_GOAL := refresh-spell

.PHONY: refresh-spell install-ungit

refresh-spell:
	{ curl -s https://raw.githubusercontent.com/Traap/nvim/master/spell/en.utf-8.add ;\
	  cat spell/en.utf-8.add; } | sort -u  > o.tmp; mv o.tmp spell/en.utf-8.add

install-ungit:
	npm install -g ungit
