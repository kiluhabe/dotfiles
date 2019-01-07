.PHONY: all
all:;

.PHONY: clean
clean:
	for dir in */; do \
	   for a in $$(ls -aA $$dir); do \
		[ "$$a" != ".config" ] && echo $(HOME)/$$a; \
	   done \
	done

.PHONY: install
install:
	for dir in */; do \
	    [ -d $$dir ] && stow $$dir; \
	done
