bin_SCRIPTS = hpcissh hpciscp hpcisftp hpcissh-version \
	hpci-get-userinfo hpci-parse-token hpci-token \
	oidc-sshconf oidc-sshconf-hpci oidc-token-hpci \
	hpcissh-config-show \
	test-hpcissh
pkglibexec_SCRIPTS = hpcissh-lib

include ../config.mk

all build: Makefile
	$(MKDIR_P) build
	for f in $(bin_SCRIPTS) $(pkglibexec_SCRIPTS); do \
		$(do_subst) < $$f > build/$$f ; \
	done

install: install-binSCRIPTS install-pkglibexecSCRIPTS

install-binSCRIPTS: $(bin_SCRIPTS)
	$(MKDIR_P) ${DESTDIR}$(bindir)
	for f in $(bin_SCRIPTS); do \
		$(INSTALL_SCRIPT) build/$$f $(DESTDIR)$(bindir)/$$f ; \
	done

install-pkglibexecSCRIPTS: $(pkglibexec_SCRIPTS)
	$(MKDIR_P) ${DESTDIR}$(pkglibexecdir)
	for f in $(pkglibexec_SCRIPTS); do \
		$(INSTALL_DATA) build/$$f $(DESTDIR)$(pkglibexecdir)/$$f ; \
	done

uninstall:
	for f in $(bin_SCRIPTS); do \
		rm -f $(DESTDIR)$(bindir)/$$f ; \
	done
	for f in $(pkglibexec_SCRIPTS); do \
		rm -f $(DESTDIR)$(pkglibexecdir)/$$f ; \
	done

test:
	$(prefix)/bin/test-hpcissh

clean:
	$(RM) -rf build
