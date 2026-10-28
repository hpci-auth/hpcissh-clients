# Makefile for hpcissh

SUBDIRS = script data
SHELLCHECK = shellcheck -o all -s bash -x

.PHONY: all build install uninstall test clean syntax $(SUBDIRS)

all build install uninstall test clean syntax:
	@for dir in $(SUBDIRS); do \
		echo "[=== Entering directory: $$dir (target: $@) ===]"; \
		$(MAKE) -C $$dir $@ || exit 1; \
		echo "[=== Leaving directory: $$dir ===]"; \
	done
	@if [ "$@" = "syntax" ]; then \
		$(SHELLCHECK) run-tests.sh || exit 1; \
		$(SHELLCHECK) docker/entrypoint.sh || exit 1; \
	fi
