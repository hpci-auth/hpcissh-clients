# Makefile for scripts inspired by Automake :p
# Time-stamp: <2024-07-01 21:08:15 sakane>

bin_SCRIPTS = hpcissh hpciscp hpcisftp hpcissh-version \
	hpci-get-userinfo hpci-parse-token hpci-token \
	oidc-sshconf oidc-sshconf-hpci oidc-token-hpci \
	test-hpcissh
pkglibexec_SCRIPTS = hpcissh-lib

prefix = /usr/local
bindir = ${prefix}/bin
pkglibexecdir = ${prefix}/libexec

SED = sed
MKDIR_P = mkdir -p
INSTALL = install -c
INSTALL_SCRIPT = ${INSTALL}
INSTALL_DATA = ${INSTALL} -m 644

do_subst = $(SED) -e 's,[@]bindir[@],$(bindir),g' \
		-e 's,[@]pkglibexecdir[@],${pkglibexecdir},g'

all: Makefile
	-mkdir build
	for f in $(bin_SCRIPTS); do \
		$(do_subst) < $$f > build/$$f ; \
	done

install: install-binSCRIPTS install-pkglibexecSCRIPTS

install-binSCRIPTS: $(bin_SCRIPTS)
	-$(MKDIR_P) ${DESTDIR}$(bindir)
	for f in $(bin_SCRIPTS); do \
		$(INSTALL_SCRIPT) build/$$f $(DESTDIR)$(bindir)/$$f ; \
	done

install-pkglibexecSCRIPTS: $(pkglibexec_SCRIPTS)
	-$(MKDIR_P) ${DESTDIR}$(pkglibexecdir)
	$(INSTALL_DATA) hpcissh-lib ${DESTDIR}$(pkglibexecdir)/hpcissh-lib

clean:
	-rm -rf build
