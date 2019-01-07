.PHONY: all
all:;

.PHONY: clean
clean:
	for dir in */; do \
	   for a in $$(ls -aA $$dir); do \
		[ "$$a" != ".config" ] && rm -rf $(HOME)/$$a || rm -rf $(HOME)/$$a/$$dir; \
	   done \
	done

.PHONY: install
install:
	for dir in */; do \
	    [ -d $$dir ] && stow $$dir; \
	done
