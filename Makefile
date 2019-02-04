.PHONY: all
all:;

.PHONY: clean
clean:
	for dir in */; do \
	   [ "$$dir" != "system" ] && for a in $$(ls -aA $$dir); do \
		[ "$$a" != ".config" ] && rm -rf $(HOME)/$$a || rm -rf $(HOME)/$$a/$$dir; \
	   done \
	done

.PHONY: install
install: install-home install-system

.PHONY: install-home
install-home:
	for dir in */; do \
	    [ -d $$dir ] && [ "$$dir" != "system" ] && stow $$dir; \
	done

.PHONY: install-system
install-system:
	@sudo stow -t / system
