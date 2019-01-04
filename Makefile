.PHONY: all
all:;

.PHONY: clean
clean:
	for dir in */; do \
	   for a in $$(ls -aA $$dir); do \
		rm $(HOME)/$$a; \
	   done \
	done

.PHONY: install
install:
	for dir in */; do \
	    stow $$dir; \
	done
