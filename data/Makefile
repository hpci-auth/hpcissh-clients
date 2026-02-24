DATA = known_hosts-HPCI-SSH_CA.txt \
	oidc-agent_hpci-main.conf \
	oidc-agent_hpci-sub.conf \
	oidc-agent-v4_hpci-pubclients.config

include ../config.mk

all build: Makefile
	$(MKDIR_P) build
	for f in $(DATA); do \
		$(do_subst) < $$f > build/$$f ; \
	done

install: install-DATA

install-DATA: $(DATA)
	$(MKDIR_P) ${DESTDIR}$(pkgdatadir)
	for f in $(DATA); do \
		$(INSTALL_DATA) build/$$f $(DESTDIR)$(pkgdatadir)/$$f ; \
	done

uninstall:
	for f in $(DATA); do \
		$(RM) -f $(DESTDIR)$(pkgdatadir)/$$f ; \
	done
	-$(RMDIR) $(DESTDIR)$(pkgdatadir)

test:

syntax:

clean:
	$(RM) -rf build
