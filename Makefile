# Makefile for hpcissh

SUBDIRS = script data

.PHONY: all build install uninstall test clean syntax $(SUBDIRS)

all build install uninstall test clean syntax:
	@for dir in $(SUBDIRS); do \
		echo "[=== Entering directory: $$dir (target: $@) ===]"; \
		$(MAKE) -C $$dir $@ || exit 1; \
		echo "[=== Leaving directory: $$dir ===]"; \
	done
	@if [ "$@" = "syntax" ]; then \
		shellcheck run-tests.sh || exit 1; \
		shellcheck docker/entrypoint.sh || exit 1; \
	fi
