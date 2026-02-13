# Makefile for hpcissh

SUBDIRS = script data

.PHONY: all build install uninstall test clean $(SUBDIRS)

all build install uninstall test clean:
	@for dir in $(SUBDIRS); do \
		echo "[=== Entering directory: $$dir (target: $@) ===]"; \
		$(MAKE) -C $$dir $@ || exit 1; \
		echo "[=== Leaving directory: $$dir ===]"; \
	done
